# Fancy Styleboxes
An addon for godot that allows for more complex panel designs without creating images

<img src="Assets/cover.png" width=1000>

## Usage
<img src="Assets/properties.png" width=400>

StyleBoxFancy comes with similar properties as StyleBoxFlat such as:
* `Color`
* `Skew`
* `Corner radius` / `Corner detail`
* `Shadow`
* `Antialiasing`

So here are differences with it
### Texture
Allows you to apply a `Texture2D` to your panel, it is compatible with rounded corners and antialiasing. A common use for this is creating a rounded panel with a `GradientTexture2D` which is not possible using Godot's StyleBoxes

If a texture is set its color will be multiplied by the `color` property, so if you don't want to modify the texture's color then set `color` to white.
