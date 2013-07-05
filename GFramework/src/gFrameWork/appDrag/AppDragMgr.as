package gFrameWork.appDrag
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * 
	 * 应用中对像移位交互的管理控制处理 
	 * @author JT
	 * 
	 */	
	public class AppDragMgr
	{
		
		/**
		 * 单例 
		 */		
		private static var mInstance:AppDragManager;
		
		
		/**
		 * 事件派发 
		 */		
		private static var eventDispatch:EventDispatcher;
		
		
		public function AppDragMgr()
		{
			
		}
		
		/**
		 * 鼠标粘贴要被移动的对像 
		 * @param targetObj			被移动的原型
		 * @param itemData			被移动的原型的数据
		 * @param dragImg			被移动时显示的图形,如果此值为空则以原型的外观复本显示
		 * 
		 */		
		public static function clingyItem(targetObj:DisplayObject,itemData:Object = null,dragImg:DisplayObject = null):void
		{
			instance.clingyItem(targetObj,itemData,dragImg);
		}
		
		public static function addEventListener(type:String,callFunc:Function,useCapture:Boolean=false,priority:int = 0,useWeakReference:Boolean=false):void
		{
			edispatch.addEventListener(type,callFunc,useCapture,priority,useWeakReference);
		}
		
		public static function removeEventListener(type:String,listener:Function,useCapture:Boolean = false):void
		{
			edispatch.removeEventListener(type,listener,useCapture);
		}
		
		public static function dispatchEvent(event:AppDragEvent):void
		{
			edispatch.dispatchEvent(event);
		}
		
		private static function get instance():AppDragManager
		{
			if(!mInstance)
			{
				mInstance = new AppDragManager();
			}
			return mInstance;
		}
		
		private static function get edispatch():EventDispatcher
		{
			if(!eventDispatch)
			{
				eventDispatch = new EventDispatcher();
			}
			return eventDispatch;
		}
		
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import gFrameWork.GFrameWork;
import gFrameWork.appDrag.AppDragEvent;
import gFrameWork.appDrag.AppDragMgr;

import mx.core.FlexGlobals;
import mx.core.UIComponent;

import spark.components.Application;

class AppDragManager
{
	
	/**
	 * 是否正在执行操作中 
	 */	
	private var mDragIn:Boolean = false;
	
	/**
	 * 正在粘住的对像 
	 */	
	private var mClingyDisplay:DisplayObject;
	
	/**
	 * 相关的数据信息 
	 */	
	private var mItemData:Object = null;
	
	/**
	 * 绘制当前被粘住的对像 
	 */	
	private var mDrawClingy:Sprite = null;
	
	private var mDelayID:int = 0;
	
	public function AppDragManager()
	{
		
	}
	
	/**
	 * 粘贴鼠标移动 
	 * @param targetObj			被移动的原型
	 * @param itemData			被移动的原型的数据
	 * @param dragImg			被移动时显示的图形,如果此值为空则以原型的外观复本显示
	 * 
	 */	
	public function clingyItem(targetObj:DisplayObject,itemData:Object = null,dragImg:DisplayObject = null):void
	{
		
		if(mDragIn) return;
		
		if(targetObj)
		{
			if(mClingyDisplay == targetObj) return;
			mDragIn = true;
			
			mClingyDisplay = targetObj;
			mItemData = itemData;
			drawClingy(dragImg);
			invlaidateListMouseClingy();
		}
	}
	
	private function invlaidateListMouseClingy():void
	{
		
		var func:Function = function():void
		{
			appMain.addEventListener(MouseEvent.CLICK,enterClingyHandler,false,0,true);
		}
		
		if(mDelayID > 0)
		{
			clearTimeout(mDelayID);
			mDelayID = 0;
		}
		
		mDelayID = setTimeout(func,1000 / 24);
	}
	
	/**
	 * 绘制被粘住的对像 
	 */	
	private function drawClingy(dragImg:DisplayObject):void
	{
		
		if(!mDrawClingy)
		{
			mDrawClingy = new Sprite();
			mDrawClingy.alpha = 0.5;
		}
		
		if(dragImg)
		{
			mDrawClingy.addChild(dragImg);
			mDrawClingy.x = appMain.mouseX - dragImg.width / 2;
			mDrawClingy.y = appMain.mouseY - dragImg.height / 2;
		}
		else
		{
			var bitData:BitmapData = new BitmapData(mClingyDisplay.width,mClingyDisplay.height,true,0);
			bitData.draw(mClingyDisplay);
			
			var bitMap:Bitmap = new Bitmap(bitData);
			
			mDrawClingy.addChild(bitMap);
			mDrawClingy.x = appMain.mouseX - dragImg.width / 2;
			mDrawClingy.y = appMain.mouseY - dragImg.height / 2;
		}
		
		mDrawClingy.startDrag();
		appMain.addChild(mDrawClingy);
		
	}
	
	/**
	 * 确认当前被击点的对像处理
	 * @param event
	 * 
	 */	
	private function enterClingyHandler(event:MouseEvent):void
	{
		var appDragEvent:AppDragEvent = new AppDragEvent(AppDragEvent.CLINGY,mClingyDisplay,mItemData,new Point(event.stageX,event.stageY));
		AppDragMgr.dispatchEvent(appDragEvent);
		
		if(mDrawClingy)
		{
			appMain.removeChild(mDrawClingy);
			mDrawClingy = null;
		}
		
		appMain.removeEventListener(MouseEvent.CLICK,enterClingyHandler);
		mClingyDisplay = null;
		mItemData = null;
		mDragIn = false;
		
	}
	
	
	private function get appMain():DisplayObjectContainer
	{
		return GFrameWork.getInstance().root;
	}
}