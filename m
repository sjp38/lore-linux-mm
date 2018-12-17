Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 31E898E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 14:08:32 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id c76so8215088ybf.13
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 11:08:32 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810040.outbound.protection.outlook.com. [40.107.81.40])
        by mx.google.com with ESMTPS id l29si8203888ybj.440.2018.12.17.11.08.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Dec 2018 11:08:30 -0800 (PST)
From: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Date: Mon, 17 Dec 2018 19:08:28 +0000
Message-ID: <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
References: 
 <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com>
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com>
In-Reply-To: <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <CF9976371CE7984D9A45AA52BB0E1D18@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wentland, Harry" <Harry.Wentland@amd.com>, Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

DQoNCk9uIDEyLzE3LzIwMTggMDE6NTEgUE0sIFdlbnRsYW5kLCBIYXJyeSB3cm90ZToNCj4gT24g
MjAxOC0xMi0xNSA0OjQyIGEubS4sIE1pa2hhaWwgR2F2cmlsb3Ygd3JvdGU6DQo+PiBPbiBTYXQs
IDE1IERlYyAyMDE4IGF0IDAwOjM2LCBXZW50bGFuZCwgSGFycnkgPEhhcnJ5LldlbnRsYW5kQGFt
ZC5jb20+IHdyb3RlOg0KPj4+IExvb2tzIGxpa2UgdGhlcmUncyBhbiBlcnJvciBiZWZvcmUgdGhp
cyBoYXBwZW5zIHRoYXQgbWlnaHQgZ2V0IHVzIGludG8gdGhpcyBtZXNzOg0KPj4+DQo+Pj4gWyAg
MjI5Ljc0MTc0MV0gW2RybTphbWRncHVfam9iX3RpbWVkb3V0IFthbWRncHVdXSAqRVJST1IqIHJp
bmcgZ2Z4IHRpbWVvdXQsIHNpZ25hbGVkIHNlcT0yODY4NiwgZW1pdHRlZCBzZXE9Mjg2ODgNCj4+
PiBbICAyMjkuNzQxODA2XSBbZHJtXSBHUFUgcmVjb3ZlcnkgZGlzYWJsZWQuDQo+Pj4NCj4+PiBI
YXJyeQ0KPj4gSGFycnksIElzIHRoaXMgZXZlciB3aWxsIGJlIGZpeGVkPw0KPj4gVGhhdCBhbm5v
eWluZyBgcmluZyBnZnggdGltZW91dGAgc3RpbGwgZm9sbG93IG1lIG9uIGFsbCBtYWNoaW5lcyB3
aXRoDQo+PiBWZWdhIEdQVSBtb3JlIHRoYW4geWVhci4NCj4+IEp1c3QgeWVzdGVyZGF5IEkgYmxv
Y2tlZCB0aGUgY29tcHV0ZXIgYW5kIHdlbnQgdG8gc2xlZXAsIGF0IHRoZQ0KPj4gbW9ybmluZyBJ
IGZvdW5kIG91dCB0aGF0IEkgY291bGQgbm90IHVubG9jayB0aGUgbWFjaGluZS4NCj4+IEFmdGVy
IGNvbm5lY3RlZCB2aWEgc3NoIEkgc2F3IGFnYWluIGluIHRoZSBrZXJuZWwgbG9nDQo+PiBgW2Ry
bTphbWRncHVfam9iX3RpbWVkb3V0IFthbWRncHVdXSAqRVJST1IqIHJpbmcgZ2Z4IHRpbWVvdXQs
IHNpZ25hbGVkDQo+PiBzZXE9MzI3Nzg0NzIsIGVtaXR0ZWQgc2VxPTMyNzc4NDc0YA0KPj4gSXQg
bWVhbnMgdGhhdCB0aGlzIGJ1ZyBtYXkgaGFwcGVucyBldmVuIGl0IEkgZG9pbmcgbm90aGluZyBv
biBteSBtYWNoaW5lLg0KPj4NCj4+IFNob3VsZCB3ZSB3YWl0IGZvciBhbnkgaW1wcm92ZW1lbnQg
aW4gbG9jYWxpemF0aW9uIHRoaXMgYnVnPw0KPj4gQmVjYXVzZSBJIHN1cHBvc2UgbWVzc2FnZSBg
W2RybTphbWRncHVfam9iX3RpbWVkb3V0IFthbWRncHVdXSAqRVJST1IqDQo+PiByaW5nIGdmeCB0
aW1lb3V0LCBzaWduYWxlZCBzZXE9MzI3Nzg0NzIsIGVtaXR0ZWQgc2VxPTMyNzc4NDc0YCBub3QN
Cj4+IGNvbnRhaW4gYW55IHVzZWZ1bCBpbmZvIGZvciBmaXhpbmcgdGhpcyBidWcuDQo+Pg0KPiBJ
IGRvbid0IGtub3cgbXVjaCBhYm91dCByaW5nIGdmeCB0aW1lb3V0cyBhcyBteSBhcmVhIG9mIGV4
cGVydGlzZSByZXZvbHZlcyBhcm91bmQgdGhlIGRpc3BsYXkgc2lkZSBvZiB0aGluZ3MsIG5vdCBn
ZnguDQo+DQo+IEFsZXgsIENocmlzdGlhbiwgYW55IGlkZWFzPw0KPg0KPiBIYXJyeQ0KDQpQbGVh
c2UgaW5zdGFsbCBVTVIgYW5kIGR1bXAgZ2Z4IHJpbmcgY29udGVudCBhbmQgd2F2ZXMgYWZ0ZXIg
dGhlIGhhbmcgaXMgDQpoYXBwZW5pbmcuDQoNClVNUiBhdCAtIGh0dHBzOi8vY2dpdC5mcmVlZGVz
a3RvcC5vcmcvYW1kL3Vtci8NCldhdmVzIGR1bXANCnN1ZG8gdW1yIC1PIHZlcmJvc2UsaGFsdF93
YXZlcyAtd2ENCkdGWCByaW5nIGR1bXANCnN1ZG8gdW1yIC1PIHZlcmJvc2UsZm9sbG93IC1SIGdm
eFsuXQ0KDQpBbmRyZXkNCg0KPg0KPj4gVGhhbmtzLg0KPj4NCj4+IC0tDQo+PiBCZXN0IFJlZ2Fy
ZHMsDQo+PiBNaWtlIEdhdnJpbG92Lg0KPj4NCj4gX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX18NCj4gYW1kLWdmeCBtYWlsaW5nIGxpc3QNCj4gYW1kLWdmeEBs
aXN0cy5mcmVlZGVza3RvcC5vcmcNCj4gaHR0cHM6Ly9saXN0cy5mcmVlZGVza3RvcC5vcmcvbWFp
bG1hbi9saXN0aW5mby9hbWQtZ2Z4DQoNCg==
