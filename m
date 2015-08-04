Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 350F36B0253
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 04:25:07 -0400 (EDT)
Received: by qgab18 with SMTP id b18so1414270qga.2
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 01:25:07 -0700 (PDT)
Received: from unicom145.biz-email.net (unicom145.biz-email.net. [210.51.26.145])
        by mx.google.com with ESMTPS id 8si482951qku.96.2015.08.04.01.25.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Aug 2015 01:25:06 -0700 (PDT)
Date: Tue, 4 Aug 2015 16:26:39 +0800
From: "gongzhaogang@inspur.com" <gongzhaogang@inspur.com>
Subject: Re: Re: [PATCH 1/5] x86, gfp: Cache best near node for memory allocation.
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>,
	<1436261425-29881-2-git-send-email-tangchen@cn.fujitsu.com>,
	<20150715214802.GL15934@mtj.duckdns.org>,
	<55C03332.2030808@cn.fujitsu.com>
MIME-Version: 1.0
Message-ID: <201508041626380745999@inspur.com>
Content-Type: multipart/alternative;
	boundary="----=_001_NextPart081587038428_=----"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, "tj@kernel.org" <tj@kernel.org>
Cc: "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>, "hpa@zytor.com" <hpa@zytor.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, "qiaonuohan@cn.fujitsu.com" <qiaonuohan@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

------=_001_NextPart081587038428_=----
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: base64

U29ycnksSSBhbSBuZXcuDQo+QnV0LA0KPjEpIGluIGNwdV91cCgpLCBpdCB3aWxsIHRyeSB0byBv
bmxpbmUgYSBub2RlLCBhbmQgaXQgZG9lc24ndCBjaGVjayBpZg0KPnRoZSBub2RlIGhhcyBtZW1v
cnkuDQo+MikgaW4gdHJ5X29mZmxpbmVfbm9kZSgpLCBpdCBvZmZsaW5lcyBDUFVzIGZpcnN0LCBh
bmQgdGhlbiB0aGUgbWVtb3J5Lg0KIA0KPlRoaXMgYmVoYXZpb3IgbG9va3MgYSBsaXR0bGUgd2ly
ZWQsIG9yIGxldCdzIHNheSBpdCBpcyBhbWJpZ3VvdXMuIEl0DQo+c2VlbXMgdGhhdCBhIE5VTUEg
bm9kZQ0KPmNvbnNpc3RzIG9mIENQVXMgYW5kIG1lbW9yeS4gU28gaWYgdGhlIENQVXMgYXJlIG9u
bGluZSwgdGhlIG5vZGUgc2hvdWxkDQo+YmUgb25saW5lLg0KSSBzdWdnZXN0ZWQgeW91IHRvIHRy
eSB0aGUgcGF0Y2ggb2ZmZXJlZCBieSBMaXUgSmlhbmcuDQoNCmh0dHBzOi8vbGttbC5vcmcvbGtt
bC8yMDE0LzkvMTEvMTA4NyANCg0KSSBoYXZlIHRyaWVkICxJdCBpcyBPSy4NCg0KPlVuZm9ydHVu
YXRlbHksIHNpbmNlIEkgZG9uJ3QgaGF2ZSBhIG1hY2hpbmUgYSB3aXRoIG1lbW9yeS1sZXNzIG5v
ZGUsIEkNCj5jYW5ub3QgcmVwcm9kdWNlDQo+dGhlIHByb2JsZW0gcmlnaHQgbm93Lg0KDQpJZiAg
bm90IGh1cnJpZWQgICwgSSBjYW4gdGVzdCB5b3VyIHBhdGNoZXMgaW4gb3VyIGVudmlyb25tZW50
IG9uIHdlZWtlbmRzLg0KDQoNCg0KZ29uZ3poYW9nYW5nQGluc3B1ci5jb20NCiANCkZyb206IFRh
bmcgQ2hlbg0KRGF0ZTogMjAxNS0wOC0wNCAxMTozNg0KVG86IFRlanVuIEhlbw0KQ0M6IG1pbmdv
QHJlZGhhdC5jb207IGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc7IHJqd0Byand5c29ja2kubmV0
OyBocGFAenl0b3IuY29tOyBsYWlqc0Bjbi5mdWppdHN1LmNvbTsgeWFzdS5pc2ltYXR1QGdtYWls
LmNvbTsgaXNpbWF0dS55YXN1YWtpQGpwLmZ1aml0c3UuY29tOyBrYW1lemF3YS5oaXJveXVAanAu
ZnVqaXRzdS5jb207IGl6dW1pLnRha3VAanAuZnVqaXRzdS5jb207IGdvbmd6aGFvZ2FuZ0BpbnNw
dXIuY29tOyBxaWFvbnVvaGFuQGNuLmZ1aml0c3UuY29tOyB4ODZAa2VybmVsLm9yZzsgbGludXgt
YWNwaUB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4
LW1tQGt2YWNrLm9yZzsgdGFuZ2NoZW5AY24uZnVqaXRzdS5jb20NClN1YmplY3Q6IFJlOiBbUEFU
Q0ggMS81XSB4ODYsIGdmcDogQ2FjaGUgYmVzdCBuZWFyIG5vZGUgZm9yIG1lbW9yeSBhbGxvY2F0
aW9uLg0KSGkgVEosDQogDQpTb3JyeSBmb3IgdGhlIGxhdGUgcmVwbHkuDQogDQpPbiAwNy8xNi8y
MDE1IDA1OjQ4IEFNLCBUZWp1biBIZW8gd3JvdGU6DQo+IC4uLi4uLg0KPiBzbyBpbiBpbml0aWFs
aXphdGlvbiBwaGFyc2UgbWFrZXMgbm8gc2Vuc2UgYW55IG1vcmUuIFRoZSBiZXN0IG5lYXIgb25s
aW5lDQo+IG5vZGUgZm9yIGVhY2ggY3B1IHNob3VsZCBiZSBjYWNoZWQgc29tZXdoZXJlLg0KPiBJ
J20gbm90IHJlYWxseSBmb2xsb3dpbmcuICBJcyB0aGlzIGJlY2F1c2UgdGhlIG5vdyBvZmZsaW5l
IG5vZGUgY2FuDQo+IGxhdGVyIGNvbWUgb25saW5lIGFuZCB3ZSdkIGhhdmUgdG8gYnJlYWsgdGhl
IGNvbnN0YW50IG1hcHBpbmcNCj4gaW52YXJpYW50IGlmIHdlIHVwZGF0ZSB0aGUgbWFwcGluZyBs
YXRlcj8gIElmIHNvLCBpdCdkIGJlIG5pY2UgdG8NCj4gc3BlbGwgdGhhdCBvdXQuDQogDQpZZXMu
IFdpbGwgZG9jdW1lbnQgdGhpcyBpbiB0aGUgbmV4dCB2ZXJzaW9uLg0KIA0KPj4gLi4uLi4uDQo+
PiAgIA0KPj4gK2ludCBnZXRfbmVhcl9vbmxpbmVfbm9kZShpbnQgbm9kZSkNCj4+ICt7DQo+PiAr
IHJldHVybiBwZXJfY3B1KHg4Nl9jcHVfdG9fbmVhcl9vbmxpbmVfbm9kZSwNCj4+ICsgICAgICAg
IGNwdW1hc2tfZmlyc3QoJm5vZGVfdG9fY3B1aWRfbWFza19tYXBbbm9kZV0pKTsNCj4+ICt9DQo+
PiArRVhQT1JUX1NZTUJPTChnZXRfbmVhcl9vbmxpbmVfbm9kZSk7DQo+IFVtbS4uLiB0aGlzIGZ1
bmN0aW9uIGlzIHNpdHRpbmcgb24gYSBmYWlybHkgaG90IHBhdGggYW5kIHNjYW5uaW5nIGENCj4g
Y3B1bWFzayBlYWNoIHRpbWUuICBXaHkgbm90IGp1c3QgYnVpbGQgYSBudW1hIG5vZGUgLT4gbnVt
YSBub2RlIGFycmF5Pw0KIA0KSW5kZWVkLiBXaWxsIGF2b2lkIHRvIHNjYW4gYSBjcHVtYXNrLg0K
IA0KPiAuLi4uLi4NCj4NCj4+ICAgDQo+PiAgIHN0YXRpYyBpbmxpbmUgc3RydWN0IHBhZ2UgKmFs
bG9jX3BhZ2VzX2V4YWN0X25vZGUoaW50IG5pZCwgZ2ZwX3QgZ2ZwX21hc2ssDQo+PiAgIHVuc2ln
bmVkIGludCBvcmRlcikNCj4+ICAgew0KPj4gLSBWTV9CVUdfT04obmlkIDwgMCB8fCBuaWQgPj0g
TUFYX05VTU5PREVTIHx8ICFub2RlX29ubGluZShuaWQpKTsNCj4+ICsgVk1fQlVHX09OKG5pZCA8
IDAgfHwgbmlkID49IE1BWF9OVU1OT0RFUyk7DQo+PiArDQo+PiArI2lmIElTX0VOQUJMRUQoQ09O
RklHX1g4NikgJiYgSVNfRU5BQkxFRChDT05GSUdfTlVNQSkNCj4+ICsgaWYgKCFub2RlX29ubGlu
ZShuaWQpKQ0KPj4gKyBuaWQgPSBnZXRfbmVhcl9vbmxpbmVfbm9kZShuaWQpOw0KPj4gKyNlbmRp
Zg0KPj4gICANCj4+ICAgcmV0dXJuIF9fYWxsb2NfcGFnZXMoZ2ZwX21hc2ssIG9yZGVyLCBub2Rl
X3pvbmVsaXN0KG5pZCwgZ2ZwX21hc2spKTsNCj4+ICAgfQ0KPiBEaXR0by4gIEFsc28sIHdoYXQn
cyB0aGUgc3luY2hyb25pemF0aW9uIHJ1bGVzIGZvciBOVU1BIG5vZGUNCj4gb24vb2ZmbGluaW5n
LiAgSWYgeW91IGVuZCB1cCB1cGRhdGluZyB0aGUgbWFwcGluZyBsYXRlciwgaG93IHdvdWxkDQo+
IHRoYXQgYmUgc3luY2hyb25pemVkIGFnYWluc3QgdGhlIGFib3ZlIHVzYWdlcz8NCiANCkkgdGhp
bmsgdGhlIG5lYXIgb25saW5lIG5vZGUgbWFwIHNob3VsZCBiZSB1cGRhdGVkIHdoZW4gbm9kZSBv
bmxpbmUvb2ZmbGluZQ0KaGFwcGVucy4gQnV0IGFib3V0IHRoaXMsIEkgdGhpbmsgdGhlIGN1cnJl
bnQgbnVtYSBjb2RlIGhhcyBhIGxpdHRsZSBwcm9ibGVtLg0KIA0KQXMgeW91IGtub3csIGZpcm13
YXJlIGluZm8gYmluZHMgYSBzZXQgb2YgQ1BVcyBhbmQgbWVtb3J5IHRvIGEgbm9kZS4gQnV0DQph
dCBib290IHRpbWUsIGlmIHRoZSBub2RlIGhhcyBubyBtZW1vcnkgKGEgbWVtb3J5LWxlc3Mgbm9k
ZSkgLCBpdCB3b24ndCANCmJlIG9ubGluZS4NCkJ1dCB0aGUgQ1BVcyBvbiB0aGF0IG5vZGUgaXMg
YXZhaWxhYmxlLCBhbmQgYm91bmQgdG8gdGhlIG5lYXIgb25saW5lIG5vZGUuDQooSGVyZSwgSSBt
ZWFuIG51bWFfc2V0X25vZGUoY3B1LCBub2RlKS4pDQogDQpXaHkgZG9lcyB0aGUga2VybmVsIGRv
IHRoaXMgPyBJIHRoaW5rIGl0IGlzIHVzZWQgdG8gZW5zdXJlIHRoYXQgd2UgY2FuIA0KYWxsb2Nh
dGUgbWVtb3J5DQpzdWNjZXNzZnVsbHkgYnkgY2FsbGluZyBmdW5jdGlvbnMgbGlrZSBhbGxvY19w
YWdlc19ub2RlKCkgYW5kIA0KYWxsb2NfcGFnZXNfZXhhY3Rfbm9kZSgpLg0KQnkgdGhlc2UgdHdv
IGZ1Y3Rpb25zLCBhbnkgQ1BVIHNob3VsZCBiZSBib3VuZCB0byBhIG5vZGUgd2hvIGhhcyBtZW1v
cnkgDQpzbyB0aGF0DQptZW1vcnkgYWxsb2NhdGlvbiBjYW4gYmUgc3VjY2Vzc2Z1bC4NCiANClRo
YXQgbWVhbnMsIGZvciBhIG1lbW9yeS1sZXNzIG5vZGUgYXQgYm9vdCB0aW1lLCBDUFVzIG9uIHRo
ZSBub2RlIGlzIA0Kb25saW5lLA0KYnV0IHRoZSBub2RlIGlzIG5vdCBvbmxpbmUuDQogDQpUaGF0
IGFsc28gbWVhbnMsICJ0aGUgbm9kZSBpcyBvbmxpbmUiIGVxdWFscyB0byAidGhlIG5vZGUgaGFz
IG1lbW9yeSIuIA0KQWN0dWFsbHksIHRoZXJlDQphcmUgYSBsb3Qgb2YgY29kZSBpbiB0aGUga2Vy
bmVsIGlzIHVzaW5nIHRoaXMgcnVsZS4NCiANCiANCkJ1dCwNCjEpIGluIGNwdV91cCgpLCBpdCB3
aWxsIHRyeSB0byBvbmxpbmUgYSBub2RlLCBhbmQgaXQgZG9lc24ndCBjaGVjayBpZiANCnRoZSBu
b2RlIGhhcyBtZW1vcnkuDQoyKSBpbiB0cnlfb2ZmbGluZV9ub2RlKCksIGl0IG9mZmxpbmVzIENQ
VXMgZmlyc3QsIGFuZCB0aGVuIHRoZSBtZW1vcnkuDQogDQpUaGlzIGJlaGF2aW9yIGxvb2tzIGEg
bGl0dGxlIHdpcmVkLCBvciBsZXQncyBzYXkgaXQgaXMgYW1iaWd1b3VzLiBJdCANCnNlZW1zIHRo
YXQgYSBOVU1BIG5vZGUNCmNvbnNpc3RzIG9mIENQVXMgYW5kIG1lbW9yeS4gU28gaWYgdGhlIENQ
VXMgYXJlIG9ubGluZSwgdGhlIG5vZGUgc2hvdWxkIA0KYmUgb25saW5lLg0KIA0KQW5kIGFsc28s
DQpUaGUgbWFpbiBwdXJwb3NlIG9mIHRoaXMgcGF0Y2gtc2V0IGlzIHRvIG1ha2UgdGhlIGNwdWlk
IDwtPiBub2RlaWQgDQptYXBwaW5nIHBlcnNpc3RlbnQuDQpBZnRlciB0aGlzIHBhdGNoLXNldCwg
YWxsb2NfcGFnZXNfbm9kZSgpIGFuZCBhbGxvY19wYWdlc19leGFjdF9ub2RlKCkgDQp3b24ndCBk
ZXBlbmQgb24NCmNwdWlkIDwtPiBub2RlaWQgbWFwcGluZyBhbnkgbW9yZS4gU28gdGhlIG5vZGUg
c2hvdWxkIGJlIG9ubGluZSBpZiB0aGUgDQpDUFVzIG9uIGl0IGFyZQ0Kb25saW5lLiBPdGhlcndp
c2UsIHdlIGNhbm5vdCBzZXR1cCBpbnRlcmZhY2VzIG9mIENQVXMgdW5kZXIgL3N5cy4NCiANCiAN
ClVuZm9ydHVuYXRlbHksIHNpbmNlIEkgZG9uJ3QgaGF2ZSBhIG1hY2hpbmUgYSB3aXRoIG1lbW9y
eS1sZXNzIG5vZGUsIEkgDQpjYW5ub3QgcmVwcm9kdWNlDQp0aGUgcHJvYmxlbSByaWdodCBub3cu
DQogDQpIb3cgZG8geW91IHRoaW5rIHRoZSBub2RlIG9ubGluZSBiZWhhdmlvciBzaG91bGQgYmUg
Y2hhbmdlZCA/DQogDQpUaGFua3MuDQogDQogDQogDQogDQogDQogDQogDQogDQogDQogDQogDQog
DQogDQogDQogDQogDQogDQogDQogDQogDQogDQogDQogDQogDQogDQogDQogDQogDQogDQogDQog
DQogDQogDQogDQogDQogDQogDQo=

------=_001_NextPart081587038428_=----
Content-Type: text/html; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; charse=
t=3DISO-8859-1"><style>body { line-height: 1.5; }blockquote { margin-top: =
0px; margin-bottom: 0px; margin-left: 0.5em; }body { font-size: 10.5pt; fo=
nt-family: ????; color: rgb(0, 0, 0); line-height: 1.5; }</style></head><b=
ody>=0A<div><span></span>Sorry,I am new.</div><div><div>&gt;But,</div><div=
>&gt;1) in cpu_up(), it will try to online a node, and it doesn't check if=
</div><div>&gt;the node has memory.</div><div>&gt;2) in try_offline_node()=
, it offlines CPUs first, and then the memory.</div><div>&nbsp;</div><div>=
&gt;This behavior looks a little wired, or let's say it is ambiguous. It</=
div><div>&gt;seems that a NUMA node</div><div>&gt;consists of CPUs and mem=
ory. So if the CPUs are online, the node should</div><div>&gt;be online.</=
div></div>=0A<div>I suggested you to try the patch offered by Liu Jiang.</=
div><div><br></div><div><span style=3D"background-color: rgba(0, 0, 0, 0);=
 font-size: 10.5pt; line-height: 1.5;">https://lkml.org/lkml/2014/9/11/108=
7</span>&nbsp;</div><div><br></div><div>I have tried ,It is OK.</div><div>=
<br></div><div><div>&gt;Unfortunately, since I don't have a machine a with=
 memory-less node, I</div><div>&gt;cannot reproduce</div><div>&gt;the prob=
lem right now.</div></div><div><br></div><div>If &nbsp;not hurried &nbsp;,=
 I can test your patches in our environment on weekends.</div><div><br></d=
iv><hr style=3D"width: 210px; height: 1px;" color=3D"#b5c4df" size=3D"1" a=
lign=3D"left">=0A<div><span><div style=3D"MARGIN: 10px; FONT-FAMILY: verda=
na; FONT-SIZE: 10pt"><div>gongzhaogang@inspur.com</div></div></span></div>=
=0A<blockquote style=3D"margin-top: 0px; margin-bottom: 0px; margin-left: =
0.5em;"><div>&nbsp;</div><div style=3D"border:none;border-top:solid #B5C4D=
F 1.0pt;padding:3.0pt 0cm 0cm 0cm"><div style=3D"PADDING-RIGHT: 8px; PADDI=
NG-LEFT: 8px; FONT-SIZE: 12px;FONT-FAMILY:tahoma;COLOR:#000000; BACKGROUND=
: #efefef; PADDING-BOTTOM: 8px; PADDING-TOP: 8px"><div><b>From:</b>&nbsp;<=
a href=3D"mailto:tangchen@cn.fujitsu.com">Tang Chen</a></div><div><b>Date:=
</b>&nbsp;2015-08-04&nbsp;11:36</div><div><b>To:</b>&nbsp;<a href=3D"mailt=
o:tj@kernel.org">Tejun Heo</a></div><div><b>CC:</b>&nbsp;<a href=3D"mailto=
:mingo@redhat.com">mingo@redhat.com</a>; <a href=3D"mailto:akpm@linux-foun=
dation.org">akpm@linux-foundation.org</a>; <a href=3D"mailto:rjw@rjwysocki=
.net">rjw@rjwysocki.net</a>; <a href=3D"mailto:hpa@zytor.com">hpa@zytor.co=
m</a>; <a href=3D"mailto:laijs@cn.fujitsu.com">laijs@cn.fujitsu.com</a>; <=
a href=3D"mailto:yasu.isimatu@gmail.com">yasu.isimatu@gmail.com</a>; <a hr=
ef=3D"mailto:isimatu.yasuaki@jp.fujitsu.com">isimatu.yasuaki@jp.fujitsu.co=
m</a>; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@j=
p.fujitsu.com</a>; <a href=3D"mailto:izumi.taku@jp.fujitsu.com">izumi.taku=
@jp.fujitsu.com</a>; <a href=3D"mailto:gongzhaogang@inspur.com">gongzhaoga=
ng@inspur.com</a>; <a href=3D"mailto:qiaonuohan@cn.fujitsu.com">qiaonuohan=
@cn.fujitsu.com</a>; <a href=3D"mailto:x86@kernel.org">x86@kernel.org</a>;=
 <a href=3D"mailto:linux-acpi@vger.kernel.org">linux-acpi@vger.kernel.org<=
/a>; <a href=3D"mailto:linux-kernel@vger.kernel.org">linux-kernel@vger.ker=
nel.org</a>; <a href=3D"mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>;=
 <a href=3D"mailto:tangchen@cn.fujitsu.com">tangchen@cn.fujitsu.com</a></d=
iv><div><b>Subject:</b>&nbsp;Re: [PATCH 1/5] x86, gfp: Cache best near nod=
e for memory allocation.</div></div></div><div><div>Hi TJ,</div>=0A<div>&n=
bsp;</div>=0A<div>Sorry for the late reply.</div>=0A<div>&nbsp;</div>=0A<d=
iv>On 07/16/2015 05:48 AM, Tejun Heo wrote:</div>=0A<div>&gt; ......</div>=
=0A<div>&gt; so in initialization pharse makes no sense any more. The best=
 near online</div>=0A<div>&gt; node for each cpu should be cached somewher=
e.</div>=0A<div>&gt; I'm not really following.&nbsp; Is this because the n=
ow offline node can</div>=0A<div>&gt; later come online and we'd have to b=
reak the constant mapping</div>=0A<div>&gt; invariant if we update the map=
ping later?&nbsp; If so, it'd be nice to</div>=0A<div>&gt; spell that out.=
</div>=0A<div>&nbsp;</div>=0A<div>Yes. Will document this in the next vers=
ion.</div>=0A<div>&nbsp;</div>=0A<div>&gt;&gt; ......</div>=0A<div>&gt;&gt=
;&nbsp;&nbsp; </div>=0A<div>&gt;&gt; +int get_near_online_node(int node)</=
div>=0A<div>&gt;&gt; +{</div>=0A<div>&gt;&gt; +	return per_cpu(x86_cpu_to_=
near_online_node,</div>=0A<div>&gt;&gt; +		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; cpumask_first(&amp;node_to_cpuid_mask_map[node]));</div>=0A<div>&gt;=
&gt; +}</div>=0A<div>&gt;&gt; +EXPORT_SYMBOL(get_near_online_node);</div>=
=0A<div>&gt; Umm... this function is sitting on a fairly hot path and scan=
ning a</div>=0A<div>&gt; cpumask each time.&nbsp; Why not just build a num=
a node -&gt; numa node array?</div>=0A<div>&nbsp;</div>=0A<div>Indeed. Wil=
l avoid to scan a cpumask.</div>=0A<div>&nbsp;</div>=0A<div>&gt; ......</d=
iv>=0A<div>&gt;</div>=0A<div>&gt;&gt;&nbsp;&nbsp; </div>=0A<div>&gt;&gt;&n=
bsp;&nbsp; static inline struct page *alloc_pages_exact_node(int nid, gfp_=
t gfp_mask,</div>=0A<div>&gt;&gt;&nbsp;&nbsp; 						unsigned int order)</d=
iv>=0A<div>&gt;&gt;&nbsp;&nbsp; {</div>=0A<div>&gt;&gt; -	VM_BUG_ON(nid &l=
t; 0 || nid &gt;=3D MAX_NUMNODES || !node_online(nid));</div>=0A<div>&gt;&=
gt; +	VM_BUG_ON(nid &lt; 0 || nid &gt;=3D MAX_NUMNODES);</div>=0A<div>&gt;=
&gt; +</div>=0A<div>&gt;&gt; +#if IS_ENABLED(CONFIG_X86) &amp;&amp; IS_ENA=
BLED(CONFIG_NUMA)</div>=0A<div>&gt;&gt; +	if (!node_online(nid))</div>=0A<=
div>&gt;&gt; +		nid =3D get_near_online_node(nid);</div>=0A<div>&gt;&gt; +=
#endif</div>=0A<div>&gt;&gt;&nbsp;&nbsp; </div>=0A<div>&gt;&gt;&nbsp;&nbsp=
; 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));</d=
iv>=0A<div>&gt;&gt;&nbsp;&nbsp; }</div>=0A<div>&gt; Ditto.&nbsp; Also, wha=
t's the synchronization rules for NUMA node</div>=0A<div>&gt; on/offlining=
.&nbsp; If you end up updating the mapping later, how would</div>=0A<div>&=
gt; that be synchronized against the above usages?</div>=0A<div>&nbsp;</di=
v>=0A<div>I think the near online node map should be updated when node onl=
ine/offline</div>=0A<div>happens. But about this, I think the current numa=
 code has a little problem.</div>=0A<div>&nbsp;</div>=0A<div>As you know, =
firmware info binds a set of CPUs and memory to a node. But</div>=0A<div>a=
t boot time, if the node has no memory (a memory-less node) , it won't </d=
iv>=0A<div>be online.</div>=0A<div>But the CPUs on that node is available,=
 and bound to the near online node.</div>=0A<div>(Here, I mean numa_set_no=
de(cpu, node).)</div>=0A<div>&nbsp;</div>=0A<div>Why does the kernel do th=
is ? I think it is used to ensure that we can </div>=0A<div>allocate memor=
y</div>=0A<div>successfully by calling functions like alloc_pages_node() a=
nd </div>=0A<div>alloc_pages_exact_node().</div>=0A<div>By these two fucti=
ons, any CPU should be bound to a node who has memory </div>=0A<div>so tha=
t</div>=0A<div>memory allocation can be successful.</div>=0A<div>&nbsp;</d=
iv>=0A<div>That means, for a memory-less node at boot time, CPUs on the no=
de is </div>=0A<div>online,</div>=0A<div>but the node is not online.</div>=
=0A<div>&nbsp;</div>=0A<div>That also means, "the node is online" equals t=
o "the node has memory". </div>=0A<div>Actually, there</div>=0A<div>are a =
lot of code in the kernel is using this rule.</div>=0A<div>&nbsp;</div>=0A=
<div>&nbsp;</div>=0A<div>But,</div>=0A<div>1) in cpu_up(), it will try to =
online a node, and it doesn't check if </div>=0A<div>the node has memory.<=
/div>=0A<div>2) in try_offline_node(), it offlines CPUs first, and then th=
e memory.</div>=0A<div>&nbsp;</div>=0A<div>This behavior looks a little wi=
red, or let's say it is ambiguous. It </div>=0A<div>seems that a NUMA node=
</div>=0A<div>consists of CPUs and memory. So if the CPUs are online, the =
node should </div>=0A<div>be online.</div>=0A<div>&nbsp;</div>=0A<div>And =
also,</div>=0A<div>The main purpose of this patch-set is to make the cpuid=
 &lt;-&gt; nodeid </div>=0A<div>mapping persistent.</div>=0A<div>After thi=
s patch-set, alloc_pages_node() and alloc_pages_exact_node() </div>=0A<div=
>won't depend on</div>=0A<div>cpuid &lt;-&gt; nodeid mapping any more. So =
the node should be online if the </div>=0A<div>CPUs on it are</div>=0A<div=
>online. Otherwise, we cannot setup interfaces of CPUs under /sys.</div>=
=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>Unfortunately, since I don=
't have a machine a with memory-less node, I </div>=0A<div>cannot reproduc=
e</div>=0A<div>the problem right now.</div>=0A<div>&nbsp;</div>=0A<div>How=
 do you think the node online behavior should be changed ?</div>=0A<div>&n=
bsp;</div>=0A<div>Thanks.</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A=
<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</d=
iv>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nb=
sp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<d=
iv>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div=
>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp=
;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div=
>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=
=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;=
</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>=
&nbsp;</div>=0A<div>&nbsp;</div>=0A</div></blockquote>=0A</body></html>
------=_001_NextPart081587038428_=------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
