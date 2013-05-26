package flashUI.controls
{
	import fl.controls.Button;
	import fl.core.UIComponent;
	import fl.managers.IFocusManagerComponent;
	
	import flash.text.TextFormat;
	
	
	
	[Style(name="overTextFormat", type="flash.text.TextFormat")]
	
	[Style(name="downTextFormat", type="flash.text.TextFormat")]
	
	public class FLButton extends Button implements IFocusManagerComponent
	{
		
		/**
		 *  @private
		 *
		 *  Method for creating the Accessibility class.
		 *  This method is called from UIComponent.
		 *
		 * @langversion 3.0
		 * @playerversion Flash 9.0.28.0
		 */
		public static var createAccessibilityImplementation:Function;
		
		private static var defaultStyles:Object = {overTextFormat:null,downTextFormat:null};
		
		public static function getStyleDefinition():Object 
		{ 
			return mergeStyles(defaultStyles, Button.getStyleDefinition());
		}
		
		public function FLButton()
		{
			super();
		}
		
		[Inspectable(defaultValue="FLButton")]
		/**
		 * @private (setter)
		 *
		 * @langversion 3.0
		 * @playerversion Flash 9.0.28.0
		 */
		public override function set label(value:String):void
		{
			super.label = value;
		}	
		
		protected override function drawTextFormat():void
		{
			// Apply a default textformat
			var defaultTF:TextFormat = getBtnTextFormat();
			textField.setTextFormat(defaultTF);
			
			var tf:TextFormat = getStyleValue(enabled?"textFormat":"disabledTextFormat") as TextFormat;
			if (tf != null) {
				textField.setTextFormat(tf);
			} else {
				tf = defaultTF;
			}
			textField.defaultTextFormat = tf;
			
			setEmbedFont();
		}
		
		protected function getBtnTextFormat():TextFormat
		{
			var uiStyles:Object = UIComponent.getStyleDefinition();
			var tf:TextFormat = null;
			if(mouseState == ButtonStates.DOWN)
			{
				tf = uiStyles.downTextFormat as TextFormat;
			}
			else if(mouseState == ButtonStates.OVER)
			{
				tf = uiStyles.overTextFormat as TextFormat;
			}
			else if(mouseState == ButtonStates.UP)
			{
				tf = uiStyles.defaultTextFormat as TextFormat;
			}
			
			tf = tf ? tf : uiStyles.textFormat;
			tf = enabled ? tf : uiStyles.defaultDisabledTextFormat;
			
			return tf;
		}
		
		
		/**
		 * @private (protected)
		 *
		 * @langversion 3.0
		 * @playerversion Flash 9.0.28.0
		 */
		override protected function initializeAccessibility():void 
		{
			if (FLButton.createAccessibilityImplementation != null) 
			{
				FLButton.createAccessibilityImplementation(this);
			}
		}
	}
}
