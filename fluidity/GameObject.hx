
package fluidity;

import evsm.FState;

import haxe.ds.StringMap;
 
import fluidity.utils.Vec2;
import fluidity.backends.Backend;

class GameObject{

    public var name:String;

    public var state:FState<GameObject,GameEvent>;

    public var position:Vec2 = new Vec2(0,0);
    public var velocity:Vec2 = new Vec2(0,0);

    public var worldAngle(get,never):Float;
    public var worldScale(get,never):Float;
    public var worldPosition(get,never):Vec2;
    public var worldFlip(get,never):Bool;

    public var angle:Float = 0;
    public var angularVelocity:Float = 0;

    public var parent:GameObject;
    public var hasParent:Bool = false;

    public var z:Float = 1;
    public var scale:Float = 1;

    public var physicsManaged = false;

    public var currentAnimationTime = 0;


    public var graphic:Graphic;

    public var collisions:Array<Collision> = [];
    
    public var collider:Collider;
    public var type:ObjectType;
    public var solid:Bool = true;

    public var flip:Bool = false;

    public var scene:GameScene;
    private var events:Array<GameEvent> = [];

    public function new(n:String = 'unnamedGameObject')
    {
        name = n;
        Backend.physics.newObject(this);
    }

    private function processEvents()
    {
        for(e in events)
        {
            if(state != null)
            {
                state.processEvent(this,e);
            }
        }
        events = [];
        return;
    }

    public function processEvent(?e:GameEvent, ?s:String)
    {
        var event:GameEvent;
        if(e == null && s == null)
        {
            trace("No argument given to processEvent on state " + name);
            return this;
        }
        if(e != null && s != null)
        {
            trace("Too many arguments given to processEvent on state " + name);
            return this;
        }

        if(e != null)
        {
            event = e;
        }
        if(s != null)
        {
            event = new GameEvent(s);
        }
        return this;

        if(scene != null && scene.inUpdate && state != null)
        {
            state.processEvent(this,event);
        }
        else
        {
            events.push(event);
        }
        return this;
    }

    public function toggleFlip():GameObject
    {
        flip = !flip;
        return this;
    }

    public function setFlip(f:Bool):GameObject
    {
        flip = f;
        // Backend.graphics.objectChanged(this);
        return this;
    }

    public function setX(x:Float):GameObject
    {
        position.x = x;
        Backend.physics.objectChanged(this);
        return this;
    }

    public function setY(y:Float):GameObject
    {
        position.y = y;
        Backend.physics.objectChanged(this);
        return this;
    }

    public function setAngle(r:Float):GameObject
    {
        angle = r;
        Backend.physics.objectChanged(this);
        return this;
    }

    public function translateX(x:Float):GameObject
    {
        position.x += x;
        Backend.physics.objectChanged(this);
        return this;
    }

    public function translateY(y:Float):GameObject
    {
        position.y += y;
        Backend.physics.objectChanged(this);
        return this;
    }

    public function translate(v:Vec2):GameObject
    {
        position.addeq(v);
        Backend.physics.objectChanged(this);
        return this;
    }
    public function rotate(r:Float):GameObject
    {
        angle += r;
        Backend.physics.objectChanged(this);
        return this;
    }

    public function setVelocityX(x:Float):GameObject
    {
        velocity.x = x;
        Backend.physics.objectChanged(this);
        return this;
    }

    public function setVelocityY(y:Float):GameObject
    {
        velocity.y = y;
        Backend.physics.objectChanged(this);
        return this;
    }

    public function setAngularVel(r:Float):GameObject
    {
        angularVelocity = r;
        return this;
    }

    public function setPosition(v:Vec2):GameObject
    {
        position.set(v.copy());
        Backend.physics.objectChanged(this);
        return this;
    }

    public function setVelocity(v:Vec2):GameObject
    {
        velocity.set(v);
        Backend.physics.objectChanged(this);
        return this;
    }

    public function setZ(z:Float):GameObject
    {
        this.z = z;
        Backend.physics.objectChanged(this);
        return this;
    }
    public function setScale(s:Float):GameObject
    {
        scale = s;
        Backend.physics.objectChanged(this);
        return this;
    }

    public function setAttribute(attrib:String, value:Dynamic):GameObject
    {
        attributes.set(attrib,value);
        return this;
    }

    public function getAttribute(attrib:String):Dynamic
    {
        return attributes.get(attrib);
    }

    public function setGraphic(g:Graphic):GameObject
    {
        currentAnimationTime = 0;
        Backend.graphics.objectSet(this,g);
        graphic = g;
        return this;
    }

    public function setCollider(c:Collider):GameObject
    {
        Backend.physics.objectSet(this,c);
        collider = c;
        return this;
    }

    public function setType(t:ObjectType):GameObject
    {
        if(type != null)
        {
            type.removeObject(this);
        }
        if(t != null)
        {
            t.addObject(this);
        }
        type = t;
        Backend.physics.objectSetType(this,t);
        return this;
    }

    public function isType(t:ObjectType):Bool
    {
        return (type == t);
    }

    public function setParent(obj:GameObject)
    {
        parent = obj;
        return this;
    }

    public function get_worldFlip():Bool
    {
        if(parent == null)
        {
            return flip;
        }
        else
        {
            if(parent.worldFlip)
            {
                return !flip;
            }
            return flip;
        }
    }

    public function get_worldAngle()
    {
        if(parent == null)
        {
            if(flip)
            {
                return -angle;
            }
            return angle;
        }
        else
        {
            if(flip)
            {
                return parent.worldAngle - angle;
            }
            return parent.worldAngle + angle;
        }
    }

    public function get_worldScale()
    {
        if(parent == null)
        {
            return scale;
        }
        else
        {
            return parent.worldScale * scale;
        }
    }

    public function get_worldPosition()
    {
        if(parent == null)
        {
            return position;
        }
        else
        {
            var worldPos = position.copy();
            if(parent.worldFlip)
            {
                worldPos.x *= -1;
            }
            return worldPos.rotate(parent.worldAngle).muleq(parent.worldScale).addeq(parent.worldPosition);
        }
    }

    public function setState(s:FState<GameObject,GameEvent>)
    {
        if(state == null)
        {
            state = new FState<GameObject,GameEvent>();
        }
        state.switchTo(this,s,new GameEvent(""));
        return this;
    }

    public function update()
    {
        processEvents();
        Backend.physics.objectUpdate(this);
        Backend.graphics.objectUpdate(this);
        if(state != null)
        {
            state.update(this);
        }

        currentAnimationTime += 1;
    }

    public function addEventTrigger(eventName:String,func:GameObject->Bool)
    {
        eventTriggers.push({eventName: eventName, func: func});
    }   

    private var attributes:StringMap<Dynamic> = new StringMap<Dynamic>();
    private var eventTriggers:Array<{eventName:String,func:GameObject->Bool}> = [];

}