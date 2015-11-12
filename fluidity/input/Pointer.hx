
package fluidity.input;

import fluidity.utils.Vec2;


class Pointer {

    public var active:Bool = true;

    public var buttons:Array<Bool> = [false,false,false,false,false];

    public var position(get,never):Vec2;
    public var windowPosition(get,never):Vec2;
    public var movement(get,never):Vec2;

    public static var mousePosition:Vec2 = new Vec2();
    public static var mouseMovement:Vec2 = new Vec2();

    public var onMoveEvents:Array<PointerEventType> = [];
    public var onReleaseEvents:Array<PointerEventType> = [];

    private var scene:GameScene;

    public function new(s:GameScene)//position:Vec2, movement:Vec2)
    {
        scene = s;
        // this.id = id;
        // this.position = position;
        // this.movement = movement;
    }

    public function get_position()
    {
        var unscaledPosition = mousePosition.sub(scene.layer.position).sub(scene.layer.sceneOffset);
        trace(unscaledPosition.x,unscaledPosition.y);
        return new Vec2(unscaledPosition.x*scene.layer.vWidth/scene.layer.width, unscaledPosition.y*scene.layer.vHeight/scene.layer.height);
    }

    public function get_windowPosition()
    {
        return mousePosition;
    }

    public function get_movement()
    {
        return mouseMovement;
    }
}