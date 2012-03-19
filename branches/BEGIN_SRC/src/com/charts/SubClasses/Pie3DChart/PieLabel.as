//------------------------------------------------------------------------------
//
//   creator : minie.pe.kr (irismin@gmail.com)
//   date : 2010.11  
//	 license : ALL FREE
//
//------------------------------------------------------------------------------

package com.charts.SubClasses.Pie3DChart {
	import flash.text.TextFieldAutoSize;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	
	
	public class PieLabel extends UIComponent {
		
		public function PieLabel() {
			super();
			
			this.mouseChildren = false;
			this.useHandCursor = true;
			this.buttonMode = true;
			
			txt = new UITextField();
			this.addChild(txt);
		}
		
		
		public var objData:Object;
		
		
		protected var txt:UITextField;
		
		
		public function setText(v:String, align:String="left"):void {
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.text = v;
			txt.y = -txt.textHeight;
			
			
			switch (align) {
				case "right":
					txt.x = -txt.textWidth;
					break;
				case "left":
					txt.x = 0;
					break;
			}
		}
		
		
		public function get textWidth():Number {
			return txt.textWidth;
		}
	}
}