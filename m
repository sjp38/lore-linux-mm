Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1328B6B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 23:41:42 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q6so113669488pgn.12
        for <linux-mm@kvack.org>; Mon, 15 May 2017 20:41:42 -0700 (PDT)
Received: from tyimss.htc.com (tyimss.htc.com. [220.128.71.150])
        by mx.google.com with ESMTPS id q77si12619435pfi.121.2017.05.15.20.41.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 May 2017 20:41:41 -0700 (PDT)
From: <zhiyuan_zhu@htc.com>
Subject: RE: Low memory killer problem
Date: Tue, 16 May 2017 03:41:31 +0000
Message-ID: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A52C9@CN-MBX03.HTC.COM.TW>
References: <AF7C0ADF1FEABA4DABABB97411952A2EDD0A004D@CN-MBX05.HTC.COM.TW>
 <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F06@CN-MBX03.HTC.COM.TW>
 <20170515080535.GA22076@kroah.com>
 <AF7C0ADF1FEABA4DABABB97411952A2EDD0A4F84@CN-MBX03.HTC.COM.TW>
 <20170515090027.GA18167@kroah.com>
In-Reply-To: <20170515090027.GA18167@kroah.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: vinmenon@codeaurora.org, linux-mm@kvack.org, skhiani@codeaurora.org, torvalds@linux-foundation.org, Jet_Li@htc.com

VGhhbmtzIGZvciB5b3VyIHJlbWluZCwNCkkgZm91bmQgbG93bWVtb3J5a2lsbGVyLmMgaGF2ZSBi
ZWVuIHJlbW92ZWQsIGFuZCBJT04gbW9kdWxlIHN0aWxsIGV4aXN0IHNpbmNlIHY0LjEyLXJjMS4N
Ckkgd2lsbCBwYXkgYXR0ZW50aW9uIHRvIElPTiBtb2R1bGUuDQoNCkJ1dCBJIHN0aWxsIGhhdmUg
MyBxdWVzdGlvbnMsDQpJcyB0aGVyZSBhbnkgc3Vic3RpdHV0ZSBmb3IgbG93LW1lbW9yeS1raWxs
ZXIgYWZ0ZXIga2VybmVsIHY0LjEyLXJjMSA/DQpDYW4gSSBhY2NvdW50ZWQgdGhlIElPTiBmcmVl
IHRvIGZyZWUgbWVtb3J5Pw0KSXMgdGhlcmUgYW55IGRpZmZlcmVudCBmcm9tIElPTiBmcmVlIGFu
ZCB0aGUgbm9ybWFsIHN5c3RlbSBtZW1vcnkgZnJlZT8NCg0KSU9OIGZyZWUgbWVhbnM6ICAgSW9u
VG90YWwgLSBJb25JblVzZSAgLSBJT04gcmVzZXJ2ZWQgbWVtb3J5Lg0KVGhhbmtzIGEgbG90Lg0K
DQotLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KRnJvbTogR3JlZyBLSCBbbWFpbHRvOmdyZWdr
aEBsaW51eGZvdW5kYXRpb24ub3JnXSANClNlbnQ6IE1vbmRheSwgTWF5IDE1LCAyMDE3IDU6MDAg
UE0NClRvOiBaaGl5dWFuIFpodSjmnLHlv5fpgaApDQpDYzogdmlubWVub25AY29kZWF1cm9yYS5v
cmc7IGxpbnV4LW1tQGt2YWNrLm9yZzsgc2toaWFuaUBjb2RlYXVyb3JhLm9yZzsgdG9ydmFsZHNA
bGludXgtZm91bmRhdGlvbi5vcmc7IEpldCBMaSjmnY7nmbzlgpEpDQpTdWJqZWN0OiBSZTogTG93
IG1lbW9yeSBraWxsZXIgcHJvYmxlbQ0KDQpPbiBNb24sIE1heSAxNSwgMjAxNyBhdCAwODoyMjoz
OEFNICswMDAwLCB6aGl5dWFuX3podUBodGMuY29tIHdyb3RlOg0KPiBEZWFyIEdyZWcsDQo+IA0K
PiBWZXJ5IHNvcnJ5IG15IG1haWwgaGlzdG9yeSBpcyBsb3N0Lg0KPiANCj4gSSBmb3VuZCBhIHBh
cnQgb2YgSU9OIG1lbW9yeSB3aWxsIGJlIHJldHVybiB0byBzeXN0ZW0gaW4gYW5kcm9pZCANCj4g
cGxhdGZvcm0sIEJ1dCB0aGVzZSBtZW1vcnlzICBjYW7igJl0IGFjY291bnRlZCBpbiBsb3ctbWVt
b3J5LWtpbGxlciBzdHJhdGVneS4NCj4g4oCmDQo+IEFuZCBJIGFsc28gZm91bmQgSU9OIG1lbW9y
eSBjb21lcyBmcm9tLCAga21hbGxvYy92bWFsbG9jL2FsbG9jIHBhZ2VzL3Jlc2VydmVkIG1lbW9y
eS4NCj4gSSB1bmRlcnN0YW5kIHJlc2VydmVkIG1lbW9yeSBzaG91bGRuJ3QgYWNjb3VudGVkIHRv
IGZyZWUgbWVtb3J5Lg0KPiBCdXQgdGhlIG1lbW9yeSB3aGljaCBhbGxvY2VkIGJ5IGttYWxsb2Mv
dm1hbGxvYy9hbGxvYyBwYWdlcywgY2FuIGJlIHJlY2xhaW1lZC4NCj4gDQo+IEJ1dCB0aGUgbG93
LW1lbW9yeSBraWxsZXIgY2FuJ3QgYWNjb3VudGVkIHRoaXMgcGFydCwgTWFueSB0aGFua3MuDQo+
IA0KPiBDb2RlIGxvY2F0aW9uLCANCj4gICAgLS0tPiBkcml2ZXJzL3N0YWdpbmcvYW5kcm9pZC9s
b3dtZW1vcnlraWxsZXIuYyAgwqAtPiBsb3dtZW1fc2Nhbg0KDQpUaGF0IGZpbGUgaXMgZ29uZSBm
cm9tIHRoZSBsYXRlc3Qga2VybmVsIHJlbGVhc2UsIHNvcnJ5LiAgU28gdGhlcmUncyBub3QgbXVj
aCB3ZSBjYW4gZG8gYWJvdXQgdGhpcyBjb2RlIGFueW1vcmUuDQoNClNlZSB0aGUgbWFpbGluZyBs
aXN0IGFyY2hpdmVzIGZvciB3aGF0IHNob3VsZCBiZSB1c2VkIGluc3RlYWQgb2YgdGhpcyBjb2Rl
LCB0aGVyZSBpcyBhIHBsYW4gZm9yIHdoYXQgdG8gZG8uDQoNCkFsc28gbm90ZSB0aGF0IHRoZSBJ
T04gY29kZSBoYXMgaGFkIGEgbG90IG9mIHJld29ya3MgbGF0ZWx5IGFzIHdlbGwuDQoNCmdvb2Qg
bHVjayENCg0KZ3JlZyBrLWgNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
