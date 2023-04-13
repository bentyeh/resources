# Syntax / Interpreter

## Input and Output Arguments

See https://www.mathworks.com/help/matlab/input-and-output-arguments.html.

### Validating arguments

See the built-in `inputParser` class. https://www.mathworks.com/help/matlab/ref/inputparser.html
Also see:
- https://stackoverflow.com/questions/2775263/how-to-deal-with-name-value-pairs-of-function-arguments-in-matlab/2776238
- https://github.com/brazilbean/bean-matlab-toolkit/blob/master/default_param.m

### Variable number of arguments

Specify `varargin` as the last argument of a function to accept any number of input arguments. `varargin` is a 1-by-N cell array, where N is the number of inputs that the function receives after the explicitly declared inputs.

## Miscellaneous

Parsing/evaluating `<` and `>` symbols in series: `a < b < c` is interpreted as `(a < b) < c`.

### `gradient()` v. `diff()`

`G = gradient(A)`
- Interior points are calulated using a central difference: `G(:,j) = 0.5*(A(:,j+1) - A(:,j-1));`
- Edge points are calculated using a single-sided difference: `G(:,1) = A(:,2) - A(:,1); G(:,N) = A(:,N) - A(:,N-1);`
- `size(G)` is identical to `size(A)`

`D = diff(A)`
- All points are calculated as adjacent differences: `D(i) = A(i+1) - A(i)`
- `size(D)` will be smaller than `size(A)` by 1 in each dimension.

# Toolboxes

## Image Processing Toolbox

### `imshow()` v. `image()`

`imshow()` only works properly with matrices of `unit8` or `unit16` data.
- For an easy way to apply your own transformations to an image, copy MATLAB's built-in rgb2gray.m file (`edit('rgb2gray.m')`) and modify the `coef` variable.

`image()` displays all matrices, regardless of data type, but without proper axis scaling or colormap
- Type `colormap` in the command window, or go to the corresponding Figure > Edit > Colormap to view the current colormap.
- Use `axis image` to get proper scaling.
- To use a built-in colormap, use `colormap(<map>(n))` where `<map>` is a built-in colormap, and `n` is the number of levels to use.
  - Example: `colormap(gray(256))` sets the colormap of the current figure to a 256-level grayscale map.
  - See https://www.mathworks.com/help/matlab/ref/colormap.html#buc3wsn-1-map for a list of built-in colormaps.

# References

Release notes: https://www.mathworks.com/help/matlab/release-notes.html