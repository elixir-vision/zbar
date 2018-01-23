defmodule Zbar.Symbol do
  @moduledoc """
  The `Zbar.Symbol` struct represents a barcode that has been detected by `zbar`.

  It has the following fields:

  * `type`: The type of barcode that has been detected, as a string. Possible
    values are listed in `t:type_enum/0`

  * `quality`: An integer metric representing barcode scan confidence.

    Larger values are better than smaller values, but only the ordered
    relationship between two values is meaningful. The values themselves
    are not defined and may change in future versions of the library.

  * `points`: The list of coordinates (encoded as `{x, y}` tuples) where a
    barcode was located within the source image.

    The structure of the points depends on the type of barcode being scanned.
    For example, for the `QR-Code` type, the points represent the bounding
    rectangle, with the first point indicating the top-left positioning pattern
    of the QR-Code if it had not been rotated.

  * `data`: The actual barcode data, as a binary string.

    Note that this is a string that may contain arbitrary binary data,
    including non-printable characters.
  """

  defstruct type: :UNKNOWN, quality: 0, points: [], data: nil

  @type type_enum ::
        :CODE_39
        | :CODE_128
        | :EAN_8
        | :EAN_13
        | :I2_5
        | :ISBN_10
        | :ISBN_13
        | :PDF417
        | :QR_Code
        | :UPC_A
        | :UPC_E
        | :UNKNOWN

  @type point :: {non_neg_integer(), non_neg_integer()}

  @typedoc @moduledoc
  @type t :: %__MODULE__{
    type: type_enum(),
    quality: non_neg_integer(),
    points: [point()],
    data: binary()
  }

end
