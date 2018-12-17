Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDDDF8E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 13:51:54 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id g4so8023373otl.14
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 10:51:54 -0800 (PST)
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710042.outbound.protection.outlook.com. [40.107.71.42])
        by mx.google.com with ESMTPS id 5si5448473oil.258.2018.12.17.10.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Dec 2018 10:51:53 -0800 (PST)
From: "Wentland, Harry" <Harry.Wentland@amd.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Date: Mon, 17 Dec 2018 18:51:51 +0000
Message-ID: <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com>
References: 
 <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com>
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
In-Reply-To: 
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <CAFF47E4889B5840B223E760A118C377@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

T24gMjAxOC0xMi0xNSA0OjQyIGEubS4sIE1pa2hhaWwgR2F2cmlsb3Ygd3JvdGU6DQo+IE9uIFNh
dCwgMTUgRGVjIDIwMTggYXQgMDA6MzYsIFdlbnRsYW5kLCBIYXJyeSA8SGFycnkuV2VudGxhbmRA
YW1kLmNvbT4gd3JvdGU6DQo+Pg0KPj4gTG9va3MgbGlrZSB0aGVyZSdzIGFuIGVycm9yIGJlZm9y
ZSB0aGlzIGhhcHBlbnMgdGhhdCBtaWdodCBnZXQgdXMgaW50byB0aGlzIG1lc3M6DQo+Pg0KPj4g
WyAgMjI5Ljc0MTc0MV0gW2RybTphbWRncHVfam9iX3RpbWVkb3V0IFthbWRncHVdXSAqRVJST1Iq
IHJpbmcgZ2Z4IHRpbWVvdXQsIHNpZ25hbGVkIHNlcT0yODY4NiwgZW1pdHRlZCBzZXE9Mjg2ODgN
Cj4+IFsgIDIyOS43NDE4MDZdIFtkcm1dIEdQVSByZWNvdmVyeSBkaXNhYmxlZC4NCj4+DQo+PiBI
YXJyeQ0KPiANCj4gSGFycnksIElzIHRoaXMgZXZlciB3aWxsIGJlIGZpeGVkPw0KPiBUaGF0IGFu
bm95aW5nIGByaW5nIGdmeCB0aW1lb3V0YCBzdGlsbCBmb2xsb3cgbWUgb24gYWxsIG1hY2hpbmVz
IHdpdGgNCj4gVmVnYSBHUFUgbW9yZSB0aGFuIHllYXIuDQo+IEp1c3QgeWVzdGVyZGF5IEkgYmxv
Y2tlZCB0aGUgY29tcHV0ZXIgYW5kIHdlbnQgdG8gc2xlZXAsIGF0IHRoZQ0KPiBtb3JuaW5nIEkg
Zm91bmQgb3V0IHRoYXQgSSBjb3VsZCBub3QgdW5sb2NrIHRoZSBtYWNoaW5lLg0KPiBBZnRlciBj
b25uZWN0ZWQgdmlhIHNzaCBJIHNhdyBhZ2FpbiBpbiB0aGUga2VybmVsIGxvZw0KPiBgW2RybTph
bWRncHVfam9iX3RpbWVkb3V0IFthbWRncHVdXSAqRVJST1IqIHJpbmcgZ2Z4IHRpbWVvdXQsIHNp
Z25hbGVkDQo+IHNlcT0zMjc3ODQ3MiwgZW1pdHRlZCBzZXE9MzI3Nzg0NzRgDQo+IEl0IG1lYW5z
IHRoYXQgdGhpcyBidWcgbWF5IGhhcHBlbnMgZXZlbiBpdCBJIGRvaW5nIG5vdGhpbmcgb24gbXkg
bWFjaGluZS4NCj4gDQo+IFNob3VsZCB3ZSB3YWl0IGZvciBhbnkgaW1wcm92ZW1lbnQgaW4gbG9j
YWxpemF0aW9uIHRoaXMgYnVnPw0KPiBCZWNhdXNlIEkgc3VwcG9zZSBtZXNzYWdlIGBbZHJtOmFt
ZGdwdV9qb2JfdGltZWRvdXQgW2FtZGdwdV1dICpFUlJPUioNCj4gcmluZyBnZnggdGltZW91dCwg
c2lnbmFsZWQgc2VxPTMyNzc4NDcyLCBlbWl0dGVkIHNlcT0zMjc3ODQ3NGAgbm90DQo+IGNvbnRh
aW4gYW55IHVzZWZ1bCBpbmZvIGZvciBmaXhpbmcgdGhpcyBidWcuDQo+IA0KDQpJIGRvbid0IGtu
b3cgbXVjaCBhYm91dCByaW5nIGdmeCB0aW1lb3V0cyBhcyBteSBhcmVhIG9mIGV4cGVydGlzZSBy
ZXZvbHZlcyBhcm91bmQgdGhlIGRpc3BsYXkgc2lkZSBvZiB0aGluZ3MsIG5vdCBnZnguDQoNCkFs
ZXgsIENocmlzdGlhbiwgYW55IGlkZWFzPw0KDQpIYXJyeQ0KDQo+IFRoYW5rcy4NCj4gDQo+IC0t
DQo+IEJlc3QgUmVnYXJkcywNCj4gTWlrZSBHYXZyaWxvdi4NCj4gDQo=
