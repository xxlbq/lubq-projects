//------------------------------------------------------------------------------
//
//   creator : minie.pe.kr (irismin@gmail.com)
//   date : 2010.11  
//	 license : ALL FREE
//
//------------------------------------------------------------------------------

package com.charts.SubClasses.Pie3DChart {
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import mx.core.UIComponent;
	
	
	public class PieUnit extends UIComponent {
		public function PieUnit() {
			super();
		}
		
		
		public var objData:Object;
		
		
		public var pieDrawAngleStep:Number = 30;
		
		
		protected var openMode:Boolean = false;
		
		
		protected var storeArr1:Array;
		
		
		protected var storeArr2:Array;
		
		
		public function drawPie(objData:Object, startAngle:Number, endAngle:Number, radiusLength:Number, depth:Number, colorsTop:Array, colorsSide1:Array, colorsSide2:Array, colorsSide3:Array):void {
			this.objData = objData;
			
			var g:Graphics = this.graphics;
			g.clear();
			
			var i:Number;
			var pt1:Point;
			var pt2:Point;
			
			
			if (startAngle > endAngle) {
				endAngle += 360;
			}
			
			// 기본 좌표값 세팅
			var ptCen1:Point = new Point(0, 0);
			var ptCen2:Point = new Point(0, depth);
			
			var ptStr1:Point = rotationLocate(startAngle,0,-radiusLength);
			var ptStr2:Point = new Point(ptStr1.x, ptStr1.y+depth);
			
			var ptEnd1:Point = rotationLocate(endAngle,0,-radiusLength);
			var ptEnd2:Point = new Point(ptEnd1.x, ptEnd1.y+depth);
			
			
			if (startAngle % 360 >= 180 && startAngle % 360 <= 360) {
				// 옆면 1 그리기
				g.lineStyle(0,0xFF0000,0);
				beginFillGradient(g,colorsSide1, radiusLength);
				g.moveTo(ptCen1.x,ptCen1.y);
				g.lineTo(ptStr1.x,ptStr1.y);
				g.lineTo(ptStr2.x,ptStr2.y);
				g.lineTo(ptCen2.x,ptCen2.y);
				g.endFill();
			}
			
			
			if (endAngle % 360 >= 0 && endAngle % 360 <= 180) {
				// 옆면 2 그리기
				g.lineStyle(0,0xFF0000,0);
				beginFillGradient(g,colorsSide2, radiusLength);
				g.moveTo(ptCen1.x,ptCen1.y);
				g.lineTo(ptEnd1.x,ptEnd1.y);
				g.lineTo(ptEnd2.x,ptEnd2.y);
				g.lineTo(ptCen2.x,ptCen2.y);
				g.endFill();
			}
			// 윗면 그리기
			pt1 = rotationLocate(startAngle,0,-radiusLength);
			g.lineStyle(0,0xFF0000,0);
			beginFillGradient(g,colorsTop, radiusLength);
			g.moveTo(pt1.x,pt1.y);
			
			var storeArr:Array;
			var keepPt:Point = new Point(pt1.x,pt1.y);
			
			storeArr1 = new Array();
			storeArr2 = new Array();
			storeArr = storeArr1;
			
			i = startAngle;
			
			
			while (i <= endAngle) {
				pt2 = rotationLocate(i,0,-radiusLength);
				g.lineTo(pt2.x,pt2.y);
				
				var t:Number = i % 360;
				
				
				if (t >= 90 && t <= 270) {
					storeArr.push(new Point(pt2.x,pt2.y));
				} else if (storeArr.length > 0 && storeArr != storeArr2) {
					storeArr = storeArr2;
				}
				keepPt.x = pt2.x;
				keepPt.y = pt2.y;
				
				
				if (i == endAngle) {
					break;
				}
				i += pieDrawAngleStep;
				
				
				if (i > endAngle) {
					i = endAngle;
				}
			}
			g.lineTo(0,0);
			g.lineTo(pt1.x,pt1.y);
			g.endFill();
			
			
			// 곡선면 그리기
			var startDraw:Boolean;
			
			
			for (var j:int = 1; j <= 2; j++) {
				storeArr = this["storeArr" + j];
				
				
				if (storeArr.length > 1) {
					g.lineStyle(0,0xFF0000,0);
					beginFillGradient(g,colorsSide3, radiusLength);
					
					startDraw = false;
					
					
					for (i = 1; i < storeArr.length; i++) {
						pt1 = storeArr[i - 1];
						pt2 = storeArr[i];
						
						
						if (!startDraw) {
							startDraw = true;
							g.moveTo(pt1.x,pt1.y);
						}
						g.lineTo(pt2.x,pt2.y);
					}
					
					
					for (i = storeArr.length - 1; i >= 0; i--) {
						pt2 = storeArr[i];
						g.lineTo(pt2.x,pt2.y+depth);
					}
					g.lineTo(pt2.x,pt2.y);
					g.endFill();
				}
			}
		}
		
		
		protected function beginFillGradient(g:Graphics, colors:Array, radius:Number):void {
			var fillType:String = GradientType.RADIAL;
			var alphas:Array = [1, 1, 1];
			var ratios:Array = [0, 100, 255];
			
			var matr:Matrix = new Matrix();
			matr.createGradientBox(radius*3, radius*3, 0,-radius*2, -radius*2);
			var spreadMethod:String = SpreadMethod.PAD;
			
			g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod, "rgb", 0); //, matr, spreadMethod
		}
		
		
		protected function rotationLocate(nAngle:Number, x1:Number, y1:Number, x0:Number=0, y0:Number=0):Point {
			//x0, y0 : 원점
			//x1, y1 : 이동할 점
			var rad:Number = nAngle / 180 * Math.PI;
			
			var ret:Point = new Point(0,0);
			ret.x = Math.cos(rad) * (x1 - x0) - Math.sin(rad) * (y1 - y0) + x0;
			ret.y = Math.sin(rad) * (x1 - x0) + Math.cos(rad) * (y1 - y0) + y0;
			return ret;
		}
	}
}