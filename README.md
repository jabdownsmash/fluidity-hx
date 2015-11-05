# fluidity-hx

Fluidity is a new approach to game development that uses [evsm](https://github.com/sepharoth213/evsm-hx) to provide a state-machine based framework.


    // states don't need to be initialized, and are always accessed via states.get

    states.get('object-normal')

        // this start function will be run as soon as an object switches to this state
        // setStart, setUpdate, and setEnd take a function as a parameter. this function
        // will be passed the object that is in this state, so multiple objects can
        // utilize the same state machine at once.
       
        .setStart(function(obj:GameObject)
            {
                obj
                    .setGraphic(Image("assets/walking.png"))
                    .setVelocityX(2)
                ;
            })

        // when an object receives the 'hit' event, it will switch to the 'object-hit' state 

        .addTransition(states.get('object-hit'),'hit')
    ;


    // states are all created at once and accessed after they are created, so you can
    // declare states in any order

    states.get('object-hit')

        // this state will inherit all behavior from the 'object-gravity' state

        .addParent(states.get('object-gravity'))


        .setStart(function(obj:GameObject,e:GameEvent)
            {

                // everything in the main API will have chainable syntax like this to
                // better organize code and improve readability

                obj
                    .setGraphic(Image("assets/hit.png"))
                    .setVelocity(
                        Vec2.fromPolar(
                            10,
                            30/180*Math.PI
                        ))

                    // attributes are saved per-object and can be used to store
                    // additional state. here a timer attribute is used to switch states
                    // after 20 frames

                    .setAttribute('timer',20)
                ;

            })
        .setUpdate(function(obj:GameObject)
            {
                obj.setAttribute('timer',obj.getAttribute('timer') - 1);

                if(obj.getAttribute('timer') <= 0)
                {
                    // to switch states, an event is sent that matches the transition
                    // below. all state transitions require an event to occur.

                    obj.processEvent(new GameEvent('hitstun-end'));
                }
            })
        .addTransition(states.get('object-flying'),'hitstun-end')
    ;


    // any state that inherits this state will have gravity behavior included. 

    states.get('object-gravity')
        .setUpdate(function(obj:GameObject))
            {
                obj.setVelocityY(obj.velocity.y += .01);
            })
    ;


    // once hitstun is over, the object can be hit again. note that this state
    // has the 'object-hit' transition and 'object-hit' does not. here states
    // are utilized to prevent an object from being hit multiple times from the
    // same active hitbox.

    states.get('object-flying')
        .addParent(states.get('object-gravity'))
        .setStart(function(obj:GameObject)
            {
                obj.setGraphic(Image("assets/flying.png"));
            })
        .addTransition(states.get('object-hit'),'hit')

        // once the object reaches the ground, switch to a 'dead' state

        .addTransition(states.get('object-ground'),'ground')
    ;


    // in this state, a timer is used to delete the object after a delay

    states.get('object-ground')
        .setStart(function(obj:GameObject)
            {
                obj
                    .setGraphic(Image("assets/object-dead.png"))
                    .setVelocity(new Vec2(0,0))
                    .setAttribute('timer',200)
                ;
            })
        .setUpdate(function(obj:GameObject)
            {
                obj
                    .setAttribute('timer',obj.getAttribute('timer') - 1)
                ;
                if(obj.getAttribute('timer') <= 0)
                {
                    delete(obj);
                }
            })
    ;
    
For a full example, look at the [monster](https://github.com/sepharoth213/monster) repository.

Documentation is currently being developed, and can be viewed here: http://sepharoth213.github.io/fluidity-hx/

To install, run:

    git clone https://github.com/sepharoth213/fluidity-hx
    haxelib dev fluidity fluidity-hx
