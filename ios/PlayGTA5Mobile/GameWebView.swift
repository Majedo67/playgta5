import SwiftUI
import WebKit

struct GameWebView: UIViewRepresentable {
    let address: String
    @Binding var showAddress: Bool
    func makeCoordinator() -> Coordinator { Coordinator(showAddress: $showAddress) }
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "gameReady")
        controller.addUserScript(WKUserScript(source: Self.controlsScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
        config.userContentController = controller
        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = .black
        web.scrollView.isScrollEnabled = false
        web.scrollView.bounces = false
        web.allowsBackForwardNavigationGestures = false
        web.load(URLRequest(url: URL(string: address) ?? URL(string: "http://localhost:8000")!))
        return web
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    final class Coordinator: NSObject, WKScriptMessageHandler {
        @Binding var showAddress: Bool
        init(showAddress: Binding<Bool>) { _showAddress = showAddress }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "gameReady" { DispatchQueue.main.async { self.showAddress = false } }
        }
    }
    static let controlsScript = #"""
    (() => {
      if (window.__playgtaMobileControls) return;
      window.__playgtaMobileControls = true;
      const style=document.createElement('style');
      style.textContent='html,body{overflow:hidden!important;touch-action:none!important}#mobilePad{position:fixed;inset:0;z-index:2147483647;pointer-events:none;font:bold 14px -apple-system,sans-serif;color:white;user-select:none}.cluster{position:absolute;bottom:24px;display:flex;gap:7px;align-items:end;pointer-events:auto}#move{left:15px;display:grid;grid-template-columns:repeat(3,50px);grid-template-rows:repeat(2,50px);gap:4px}#acts{right:14px;flex-wrap:wrap;max-width:180px;justify-content:flex-end} .gbtn{width:50px;height:50px;border-radius:50%;border:1px solid #ffffffaa;background:#111c;color:white;backdrop-filter:blur(5px);touch-action:none}#acts .gbtn{width:55px;height:55px;font-size:10px}#look{position:absolute;inset:0 0 0 38%;pointer-events:auto;touch-action:none}#move,#acts{z-index:2}';
      document.head.appendChild(style);
      const pad=document.createElement('div');pad.id='mobilePad';
      const look=document.createElement('div');look.id='look';pad.appendChild(look);
      const move=document.createElement('div');move.id='move';move.className='cluster';
      const acts=document.createElement('div');acts.id='acts';acts.className='cluster';
      const key=(k,down)=>{const e=new KeyboardEvent(down?'keydown':'keyup',{key:k,code:k===' '?'Space':(k.length===1?'Key'+k.toUpperCase():k),bubbles:true});document.dispatchEvent(e);window.dispatchEvent(e)};
      const bind=(el,k)=>{el.addEventListener('pointerdown',e=>{e.preventDefault();el.setPointerCapture(e.pointerId);key(k,true)});['pointerup','pointercancel','lostpointercapture'].forEach(t=>el.addEventListener(t,()=>key(k,false)))};
      [['',null],['▲','w'],['',null],['◀','a'],['▼','s'],['▶','d']].forEach(([label,k])=>{const b=document.createElement('button');b.className='gbtn';b.textContent=label;if(k)bind(b,k);else b.style.visibility='hidden';move.appendChild(b)});
      [['JUMP',' '],['RUN','Shift'],['ENTER','e'],['FIRE','Mouse1'],['USE','f']].forEach(([label,k])=>{const b=document.createElement('button');b.className='gbtn';b.textContent=label;if(k==='Mouse1'){b.addEventListener('pointerdown',e=>{e.preventDefault();document.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}))});b.addEventListener('pointerup',()=>document.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true})))}else bind(b,k);acts.appendChild(b)});
      pad.append(move,acts);document.body.appendChild(pad);
      let last=null;look.addEventListener('pointerdown',e=>{last=[e.clientX,e.clientY];look.setPointerCapture(e.pointerId)});
      look.addEventListener('pointermove',e=>{if(!last)return;const dx=e.clientX-last[0],dy=e.clientY-last[1];last=[e.clientX,e.clientY];document.dispatchEvent(new MouseEvent('mousemove',{clientX:e.clientX,clientY:e.clientY,movementX:dx,movementY:dy,bubbles:true}))});
      ['pointerup','pointercancel','lostpointercapture'].forEach(t=>look.addEventListener(t,()=>last=null));
      window.webkit?.messageHandlers?.gameReady?.postMessage(true);
    })();
    """#
}
