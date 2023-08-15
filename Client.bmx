Rem 
		main client-side game application
EndRem
Strict

Framework openb3d.b3dglgraphics
Import Brl.Gnet

Graphics3D 800,600, 0, 3

Include "createTerrain.bmx"
Include "player.bmx"
Include "PlayerNet.bmx"

'variables
Const GroupEnvironment% = 2
Const GroupCharacters% = 3

Const GRAVITY:Float = 0.1
Const  ENERGY:Float = 1.5
Const  MOTION:Int   = 20
Global YAcceleration:Float
Global PlayerTime:Int
Global playerjumped:Int

						' instance of network objects
						Global Host:TGNetHost=CreateGNetHost()
						Global Client:Int = GNetConnect(Host,"medievaldreams.io",43594)						
' Light the world, todo;maybe put the lighting in bmx zone file. for now it is in main.
Local light:TLight=CreateLight()
RotateEntity light,90,0,0

If Host
   Print "Host created."
Else
   Print "Couldnt create local host."
EndIf

If(Client = True)
Print "Host has connected to the server successfully"
	Else
				Print"Host was not able to connect to server"
				CloseGNetHost(Host)
Print "host closed"
			Return
	EndIf
						Global localplayer:TPlayer = TPlayer.AddMe("client")
Include "camera.bmx"
	localplayer.SendX()
		localplayer.SendY()
				localplayer.SendZ()
					'send player position after tplayer GNetobject is created
' debug entity landmark
	Local c:TEntity = CreateCylinder()
	ScaleEntity c, 0.2,10,0.2
   	PositionEntity c, 12,0.00000000001,-12
' set collision
Collisions(GroupCharacters,GroupEnvironment,2,2)


Repeat


CameraFunction()

   GNetSync(Host)
	ScanGnet()
	
	If KeyDown( KEY_D )=True
	MoveEntity localplayer.Pivot,0.1,0,0
	EndIf
	If KeyDown( KEY_S )=True
	MoveEntity localplayer.Pivot,0,0,-0.1
	EndIf
	If KeyDown( KEY_A )=True
	MoveEntity localplayer.Pivot,-0.1,0,0
	EndIf
	If KeyDown( KEY_W )=True
	MoveEntity localplayer.Pivot,0,0,0.1
	EndIf
	If KeyDown( key_UP )=True
	MoveEntity localplayer.Pivot,0,0.1,0
	EndIf
	If KeyDown( key_Down )=True
	MoveEntity localplayer.Pivot,0,-0.1,0
	EndIf
			'Update player location and rotation upon changes
	If EntityX(localplayer.pivot) <> localplayer.X() Then localplayer.SendX()
		If EntityY(localplayer.pivot) <> localplayer.Y() Then localplayer.SendY()
			If EntityZ(localplayer.pivot) <> localplayer.Z() Then localplayer.SendZ()
			
				If EntityPitch(localplayer.pivot) <> localplayer.Pitch() Then localplayer.SendPitch()
		If EntityYaw(localplayer.pivot) <> localplayer.Yaw() Then localplayer.SendYaw()
			If EntityRoll(localplayer.pivot) <> localplayer.Roll() Then localplayer.SendRoll()
	
		If KeyDown(key_SPACE) And PlayerIsOnGround = True Then
					YAcceleration=ENERGY
			EndIf
		
		
	If (KeyHit(KEY_R)) 'print coordinates for reference
Print EntityX(localplayer.pivot)
Print EntityY(localplayer.pivot)
Print EntityZ(localplayer.pivot)
EndIf


' Gravity and jumping function
If  PlayerTime<MilliSecs() 'And YAcceleration<>0
	PlayerTime = MilliSecs()+ MOTION
	 	YAcceleration = YAcceleration - GRAVITY
	MoveEntity localplayer.Pivot, 0,YAcceleration,0
	'Print EntityY(Pivot)
	If EntityY(localplayer.Pivot)<0.1
		'  auto floor collision or:
		 'PositionEntity localplayer.Pivot, EntityX(localplayer.Pivot), 1 , EntityZ(localplayer.Pivot)
		YAcceleration=0
	EndIf
EndIf

Local WhoCollided:TEntity = EntityCollided(localplayer.pivot,GroupEnvironment)
If WhoCollided=terrain
     'Print "Entity has collided with the terrain"
PlayerIsOnGround = True
Else

PlayerIsOnGround = False
'Print "player isnt colliding with anything"
	EndIf
	
	UpdateWorld
	RenderWorld
		Flip

'Text 0,0,"Use cursor keys to move about the terrain"




Until AppTerminate() Or KeyHit(KEY_ESCAPE)
CloseGNetObject(localplayer.GObj)
Delay 100
Print"Player object closed"
CloseGNetHost(Host)
Delay 100
Print "host closed"