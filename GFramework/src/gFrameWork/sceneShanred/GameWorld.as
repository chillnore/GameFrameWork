package gFrameWork.sceneShanred
{
	import flash.display.Sprite;
	
	import gFrameWork.IDisabled;

	/**
	 * 游戏的世界 
	 * @author JT
	 * 
	 */	
	public class GameWorld
	{
		
		/**
		 * 当前游戏的场景 
		 */		
		private static var mCurScene:SharedScene;
		
		public function GameWorld()
		{
			
		}
		
		/**
		 * 游戏场景切换 
		 * @param sharedScene
		 * 
		 */		
		public static function runScene(sharedScene:SharedScene):void
		{
			if(mCurScene)
			{
				mCurScene.dispose();
			}
			
			mCurScene = sharedScene;
			mCurScene.initScene();
		}
		
		public static function get sharedScene():SharedScene
		{
			return mCurScene;
		}
		
	}
}