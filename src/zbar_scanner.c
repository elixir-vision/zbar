#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <err.h>

#include <jpeglib.h>
#include <zbar.h>

#include "base64.h"

#define zbar_fourcc(a, b, c, d)                 \
        ((unsigned long)(a) |                   \
         ((unsigned long)(b) << 8) |            \
         ((unsigned long)(c) << 16) |           \
         ((unsigned long)(d) << 24))

int main (int argc, char **argv)
{
  if (argc != 2)
    errx(EXIT_FAILURE, "Usage: %s filename.jpg", argv[0]);

  struct jpeg_decompress_struct cinfo;
  struct jpeg_error_mgr jerr;
  unsigned long bmp_size;
  unsigned char *bmp_buffer;
  unsigned char *scanline_buffer;
  uint16_t width, height;
  uint8_t pixel_size;

  cinfo.err = jpeg_std_error(&jerr);
  jpeg_create_decompress(&cinfo);

  FILE * file = fopen(argv[1], "rb");
  if (file == NULL)
    errx(EXIT_FAILURE, "Could not open file %s", argv[1]);

  jpeg_stdio_src(&cinfo, file);

  if (jpeg_read_header(&cinfo, TRUE) != 1)
    exit(EXIT_FAILURE);

  jpeg_start_decompress(&cinfo);

  width = cinfo.output_width;
  height = cinfo.output_height;
  pixel_size = cinfo.output_components;

  bmp_size = width * height;
  bmp_buffer = (unsigned char*) malloc(bmp_size);

  uint32_t scanline_size = width * pixel_size;
  scanline_buffer = (unsigned char*) malloc(scanline_size);

  uint16_t row = 0, col = 0;
  uint8_t r, g, b, lum;
  while (row < height) {
    if (jpeg_read_scanlines(&cinfo, &scanline_buffer, 1) == 1) {
      for(col = 0; col < width; col++) {
        r = scanline_buffer[3 * col];
        g = scanline_buffer[3 * col + 1];
        b = scanline_buffer[3 * col + 2];
        lum = ((66 * r + 129 * g + 25 * b + 128) >> 8) + 16;
        bmp_buffer[row * width + col] = lum;
      }
      row++;
    }
  }

  jpeg_finish_decompress(&cinfo);
  jpeg_destroy_decompress(&cinfo);
  fclose(file);

  zbar_image_t *image = zbar_image_create();
  zbar_image_set_size(image, width, height);
  zbar_image_set_format(image, zbar_fourcc('Y', '8', '0', '0'));
  zbar_image_set_data(image, bmp_buffer, width * height, NULL);

  zbar_image_scanner_t *scanner = zbar_image_scanner_create();
  zbar_image_scanner_set_config(scanner, 0, ZBAR_CFG_ENABLE, 1);
  zbar_scan_image(scanner, image);

  const zbar_symbol_t *symbol = zbar_image_first_symbol(image);
  for(; symbol; symbol = zbar_symbol_next(symbol)) {
    printf(
      "type:%s quality:%i points:",
      zbar_get_symbol_name(zbar_symbol_get_type(symbol)),
      zbar_symbol_get_quality(symbol)
    );
    unsigned int point_count = zbar_symbol_get_loc_size(symbol);
    for(int i = 0; i < point_count; i++) {
      printf(
        "%i,%i",
        zbar_symbol_get_loc_x(symbol, i),
        zbar_symbol_get_loc_y(symbol, i)
      );
      if (i+1 < point_count) printf(";");
    }
    const char *data = zbar_symbol_get_data(symbol);
    unsigned int data_length = zbar_symbol_get_data_length(symbol);
    int base64_length;
    char * base64_data = base64(data, data_length, &base64_length);
    printf(" data:%s\n", base64_data);
    free(base64_data);
  }

  zbar_image_destroy(image);
  zbar_image_scanner_destroy(scanner);

  return(0);
}
