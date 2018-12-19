Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C87F8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 15:21:29 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id t2-v6so12569414ybg.15
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 12:21:29 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760044.outbound.protection.outlook.com. [40.107.76.44])
        by mx.google.com with ESMTPS id t11si7242277ybl.428.2018.12.19.12.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 19 Dec 2018 12:21:27 -0800 (PST)
From: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Date: Wed, 19 Dec 2018 20:21:25 +0000
Message-ID: <d40c59b2-fa8f-2687-e650-01a0c63b90a5@amd.com>
References: 
 <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com>
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com>
 <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPE36vkeycDQFhhsSQ0KhVxX4W=6Q5vt=hVzhZo3dZGWA@mail.gmail.com>
In-Reply-To: 
 <CABXGCsPE36vkeycDQFhhsSQ0KhVxX4W=6Q5vt=hVzhZo3dZGWA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <DF7BB155C6C7C1439B2D99F22B6118D3@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, "StDenis, Tom" <Tom.StDenis@amd.com>

K1RvbQ0KDQpBbmRyZXkNCg0KDQpPbiAxMi8xOS8yMDE4IDAxOjM1IFBNLCBNaWtoYWlsIEdhdnJp
bG92IHdyb3RlOg0KPiBPbiBUdWUsIDE4IERlYyAyMDE4IGF0IDAwOjA4LCBHcm9kem92c2t5LCBB
bmRyZXkNCj4gPEFuZHJleS5Hcm9kem92c2t5QGFtZC5jb20+IHdyb3RlOg0KPj4gUGxlYXNlIGlu
c3RhbGwgVU1SIGFuZCBkdW1wIGdmeCByaW5nIGNvbnRlbnQgYW5kIHdhdmVzIGFmdGVyIHRoZSBo
YW5nIGlzDQo+PiBoYXBwZW5pbmcuDQo+Pg0KPj4gVU1SIGF0IC0gaHR0cHM6Ly9jZ2l0LmZyZWVk
ZXNrdG9wLm9yZy9hbWQvdW1yLw0KPj4gV2F2ZXMgZHVtcA0KPj4gc3VkbyB1bXIgLU8gdmVyYm9z
ZSxoYWx0X3dhdmVzIC13YQ0KPj4gR0ZYIHJpbmcgZHVtcA0KPj4gc3VkbyB1bXIgLU8gdmVyYm9z
ZSxmb2xsb3cgLVIgZ2Z4Wy5dDQo+Pg0KPj4gQW5kcmV5DQo+Pg0KPiBUaGFua3MgZm9yIHJlc3Bv
bmQuDQo+DQo+IFdoYXQgb3B0aW9ucyBzaG91bGQgSSBzcGVjaWZ5IGluIGtlcm5lbCBjb21tYW5k
IGxpbmU/DQo+DQo+IE9uIG15IHNldHVwIGB1bXJgIHRlcm1pbmF0ZWQgd2l0aCBtZXNzYWdlIGBD
b3VsZCBub3Qgb3BlbiByaW5nIGRlYnVnZnMNCj4gZmlsZWAgYW5kIGNyYXNoZXMuIEJ1dCBJIGFt
IHN1cmUgdGhhdCBkZWJ1Z2ZzIGVuYWJsZWQuDQo+DQo+ICQgc3VkbyB1bXIgLU8gdmVyYm9zZSxo
YWx0X3dhdmVzIC13YQ0KPiBDYW5ub3Qgc2VlayB0byBNTUlPIGFkZHJlc3M6IEJhZCBmaWxlIGRl
c2NyaXB0b3INCj4gW0VSUk9SXTogQ291bGQgbm90IG9wZW4gcmluZyBkZWJ1Z2ZzIGZpbGVTZWdt
ZW50YXRpb24gZmF1bHQNCj4NCj4NCj4gIyBscyAvc3lzL2tlcm5lbC9kZWJ1Zy9kcmkvMC8NCj4g
ICBhbWRncHVfZG1fZHRuX2xvZyAgICAgICAgYW1kZ3B1X3JpbmdfY29tcF8xLjEuMCAgICAgYW1k
Z3B1X3ZyYW1fbW0NCj4gICBhbWRncHVfZXZpY3RfZ3R0ICAgICAgICAgYW1kZ3B1X3JpbmdfY29t
cF8xLjEuMSAgICAgYW1kZ3B1X3dhdmUNCj4gICBhbWRncHVfZXZpY3RfdnJhbSAgICAgICAgYW1k
Z3B1X3JpbmdfY29tcF8xLjIuMCAgICAgY2xpZW50cw0KPiAgIGFtZGdwdV9mZW5jZV9pbmZvICAg
ICAgICBhbWRncHVfcmluZ19jb21wXzEuMi4xICAgICBjcnRjLTANCj4gICBhbWRncHVfZmlybXdh
cmVfaW5mbyAgICAgYW1kZ3B1X3JpbmdfY29tcF8xLjMuMCAgICAgY3J0Yy0xDQo+ICAgYW1kZ3B1
X2djYV9jb25maWcgICAgICAgIGFtZGdwdV9yaW5nX2NvbXBfMS4zLjEgICAgIGNydGMtMg0KPiAg
IGFtZGdwdV9nZHNfbW0gICAgICAgICAgICBhbWRncHVfcmluZ19nZnggICAgICAgICAgICBjcnRj
LTMNCj4gICBhbWRncHVfZ2VtX2luZm8gICAgICAgICAgYW1kZ3B1X3Jpbmdfa2lxXzIuMS4wICAg
ICAgY3J0Yy00DQo+ICAgYW1kZ3B1X2dwciAgICAgICAgICAgICAgIGFtZGdwdV9yaW5nX3NkbWEw
ICAgICAgICAgIGNydGMtNQ0KPiAgIGFtZGdwdV9ncHVfcmVjb3ZlciAgICAgICBhbWRncHVfcmlu
Z19zZG1hMSAgICAgICAgICBEUC0xDQo+ICAgYW1kZ3B1X2d0dF9tbSAgICAgICAgICAgJ2FtZGdw
dV9yaW5nX3V2ZDwwPicgICAgICAgIERQLTINCj4gICBhbWRncHVfZ3dzX21tICAgICAgICAgICAn
YW1kZ3B1X3JpbmdfdXZkX2VuYzA8MD4nICAgRFAtMw0KPiAgIGFtZGdwdV9pb21lbSAgICAgICAg
ICAgICdhbWRncHVfcmluZ191dmRfZW5jMTwwPicgICBmcmFtZWJ1ZmZlcg0KPiAgIGFtZGdwdV9v
YV9tbSAgICAgICAgICAgICBhbWRncHVfcmluZ192Y2UwICAgICAgICAgICBnZW1fbmFtZXMNCj4g
ICBhbWRncHVfcG1faW5mbyAgICAgICAgICAgYW1kZ3B1X3JpbmdfdmNlMSAgICAgICAgICAgSERN
SS1BLTENCj4gICBhbWRncHVfcmVncyAgICAgICAgICAgICAgYW1kZ3B1X3JpbmdfdmNlMiAgICAg
ICAgICAgSERNSS1BLTINCj4gICBhbWRncHVfcmVnc19kaWR0ICAgICAgICAgYW1kZ3B1X3NhX2lu
Zm8gICAgICAgICAgICAgSERNSS1BLTMNCj4gICBhbWRncHVfcmVnc19wY2llICAgICAgICAgYW1k
Z3B1X3NlbnNvcnMgICAgICAgICAgICAgaW50ZXJuYWxfY2xpZW50cw0KPiAgIGFtZGdwdV9yZWdz
X3NtYyAgICAgICAgICBhbWRncHVfdGVzdF9pYiAgICAgICAgICAgICBuYW1lDQo+ICAgYW1kZ3B1
X3JpbmdfY29tcF8xLjAuMCAgIGFtZGdwdV92YmlvcyAgICAgICAgICAgICAgIHN0YXRlDQo+ICAg
YW1kZ3B1X3JpbmdfY29tcF8xLjAuMSAgIGFtZGdwdV92cmFtICAgICAgICAgICAgICAgIHR0bV9w
YWdlX3Bvb2wNCj4NCj4NCj4NCj4NCj4gLS0NCj4gQmVzdCBSZWdhcmRzLA0KPiBNaWtlIEdhdnJp
bG92Lg0KDQo=
