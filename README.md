# UnityShaders
Collection of shaders created in Unity game engine. Each shader has example scene to demonstrate effect/visual appearance.

## Fish Motion Shader
Example showing vertex position modification shader used to implement realistic fish swimming motion. Shader consists of horizontal translation, yaw rotation around
mesh pivot, roll rotation, waving motion and "squish" waving rotation. When all effects are combined they form realistic fish swimming motion. Example scene shows 
shader in usage on fish and hammerhead shark models using either vertex colors or textures for albedo color.

![Fish shader example](ExampleVideos/FishShaderExample.gif)

## Wind indicator Shader
Example of vertex position modification shader used to implement wind indicator. Shader animates wind indicator rotation based on wind speed, having it lowered when 
there is little or no wind and having it horizontal and waving at full wind speed. Wind speed is float parameter which can be easilly controlled through the script.
Additionally, shader has a max wind speed value which will restrict all wind speeds higher than max to this value.

![Wind indicator example](ExampleVideos/WindIndicatorExample.gif)

## 2D Interactive Water Shader
Example of animating 2D water surface to simulate waves based on precalculated waves motions. Waves motions are precalculated using physics simulation of spring joints and saved
to separate textures for up/down wave animations. Shader uses these textures to visualize waves on water impact in realtime without needed computations. Waves can have 
different amplitude and radiuses. One water block is currently restricted to maximum of 4 simultaneous waves for ease of implementation (each wave stored in one channel of
a color property). Example scene visualizes usage by spawning waves based on "ImpactTester" X position when user presses "Space" key on the keyboard.

![Interactive water example](ExampleVideos/InteractiveWaterExample.gif)
