Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id B32E48E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:20:37 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id e1so1093636wmg.0
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:20:37 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-eopbgr820057.outbound.protection.outlook.com. [40.107.82.57])
        by mx.google.com with ESMTPS id g1si5955501wmg.78.2018.12.20.08.20.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 08:20:36 -0800 (PST)
From: "StDenis, Tom" <Tom.StDenis@amd.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Date: Thu, 20 Dec 2018 16:20:33 +0000
Message-ID: <5a413fa2-c3a4-d603-2069-fd27b22062cc@amd.com>
References: 
 <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com>
 <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPE36vkeycDQFhhsSQ0KhVxX4W=6Q5vt=hVzhZo3dZGWA@mail.gmail.com>
 <d40c59b2-fa8f-2687-e650-01a0c63b90a5@amd.com>
 <C97D2E5E-24AB-4B28-B7D3-BF561E4FF3D6@amd.com>
 <CABXGCsP9O8p1_hC31faCYkUOnHZp_i=mWuP5_F9v-KPxeOMsdQ@mail.gmail.com>
 <CABXGCsMygWFqnkaZbpLEBd9aBkk9=-fRnDMNOnkRfPZaeheoCg@mail.gmail.com>
 <9b87556e-ed4d-6ec0-2f98-a08469b7f35e@amd.com>
 <CABXGCsMbP8W28NTx_y3viiN=3deiEVkLw0_HBFZa1Qt_8MUVjg@mail.gmail.com>
 <b3aba7f4-b131-64fe-88eb-c1e14e133c51@amd.com>
 <CABXGCsMJs6X+bK7NS+wPn94H3skcR5a-U9710rSByvn26vg7Gg@mail.gmail.com>
 <4a3060aa-2bc7-9845-0135-ddf27e90740e@amd.com>
 <fbdd541c-ce31-9fe0-f1ac-bb9c51bb6526@amd.com>
 <96c70496-ce62-b162-187c-ff34ebb84ec2@amd.com>
 <CABXGCsORwHuOuFT273hTZSkC4tChUC_Mbj8gte2htTR2V0s79Q@mail.gmail.com>
In-Reply-To: 
 <CABXGCsORwHuOuFT273hTZSkC4tChUC_Mbj8gte2htTR2V0s79Q@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <281137B7258ECD44AD788019B82487F5@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

T24gMjAxOC0xMi0yMCAxMTowNyBhLm0uLCBNaWtoYWlsIEdhdnJpbG92IHdyb3RlOg0KPiBPbiBU
aHUsIDIwIERlYyAyMDE4IGF0IDE5OjE5LCBTdERlbmlzLCBUb20gPFRvbS5TdERlbmlzQGFtZC5j
b20+IHdyb3RlOg0KPj4NCj4+IFlhIEkgd2FzIHJpZ2h0LiAgV2l0aCBhIHBsYWluIGJ1aWxkIEkg
Y2FuIGFjY2VzcyB0aGUgZmlsZXMganVzdCBmaW5lLg0KPj4NCj4+DQo+Pg0KPj4gSSBkaWQgbWFu
YWdlIHRvIGdldCBpbnRvIGEgd2VpcmQgc2hlbGwgd2hlcmUgSSBjb3VsZG4ndCBjYXQNCj4+IGFt
ZGdwdV9nY2FfY29uZmlnIGZyb20gYmFzaCB0aG91Z2ggYWZ0ZXIgYSByZWJvb3QgKGhhZCB1cGRh
dGVzIHBlbmRpbmcpDQo+PiBpdCB3b3JrcyBmaW5lLg0KPj4NCj4+IElmIHlvdSBjYW4ndCBjYXQg
dGhvc2UgZmlsZXMgdGhlbiBuZWl0aGVyIGNhbiB1bXIuDQo+Pg0KPj4gU28gTk9UQUJVRyA6LSkN
Cj4+DQo+IA0KPiBJIGFtIHZlcnkgaGFwcHkgZm9yIHlvdS4gQnV0IHdoYXQgYWJvdXQgbWU/DQo+
IEkgZG9uJ3QgaGF2ZSBpZGVhIGhvdyBtYWtlIHRoaXMgZmlsZXMgYXZhaWxhYmxlIG9uIG15IHN5
c3RlbS4NCj4gQW5kIG9mIGNvdXJzZSBJIHRyaWVkIHJlYm9vdCBhbmQgdHJ5IGFnYWluIGNhdCBh
bWRncHVfZ2NhX2NvbmZpZw0KPiBzZXZlcmFsIHRpbWVzIGJ1dCBhbGwgdGltZXMgd2l0aG91dCBz
dWNjZXNzLg0KDQpTb3JyeSBJIGRpZG4ndCBtZWFuIHRvIGJlIGRpc21pc3NpdmUuICBJdCdzIGp1
c3Qgbm90IGEgYnVnIGluIHVtciB0aG91Z2guDQoNCk9uIEZlZG9yYSBJIGNhbiBhY2Nlc3MgdGhv
c2UgZmlsZXMgYXMgcm9vdCBqdXN0IGZpbmU6DQoNCnRvbUBmeDg6fiQgc3VkbyBiYXNoDQpbc3Vk
b10gcGFzc3dvcmQgZm9yIHRvbToNCnJvb3RAZng4Oi9ob21lL3RvbSMgY2QgL3N5cy9rZXJuZWwv
ZGVidWcvZHJpLzANCnJvb3RAZng4Oi9zeXMva2VybmVsL2RlYnVnL2RyaS8wIyB4eGQgLWUgYW1k
Z3B1X2djYV9jb25maWcNCjAwMDAwMDAwOiAwMDAwMDAwMyAwMDAwMDAwMSAwMDAwMDAwNCAwMDAw
MDAwYiAgLi4uLi4uLi4uLi4uLi4uLg0KMDAwMDAwMTA6IDAwMDAwMDAxIDAwMDAwMDAyIDAwMDAw
MDA0IDAwMDAwMTAwICAuLi4uLi4uLi4uLi4uLi4uDQowMDAwMDAyMDogMDAwMDAwMjAgMDAwMDAw
MDggMDAwMDAwMjAgMDAwMDAxMDAgICAuLi4uLi4uIC4uLi4uLi4NCjAwMDAwMDMwOiAwMDAwMDAz
MCAwMDAwMDRjMCAwMDAwMDAwMCAwMDAwMDAwMyAgMC4uLi4uLi4uLi4uLi4uLg0KMDAwMDAwNDA6
IDAwMDAwMDAwIDAwMDAwMDAwIDAwMDAwMDAwIDAwMDAwMDAwICAuLi4uLi4uLi4uLi4uLi4uDQow
MDAwMDA1MDogMDAwMDAwMDAgMDAwMDAwMDAgMjQwMDAwNDIgMDAwMDAwMDIgIC4uLi4uLi4uQi4u
JC4uLi4NCjAwMDAwMDYwOiAwMDAwMDAwMSAwMDAwNDEwMCAwMTdmOWZjZiAwMDAwMDA4ZSAgLi4u
Li5BLi4uLi4uLi4uLg0KMDAwMDAwNzA6IDAwMDAwMDAxIDAwMDAxNWRkIDAwMDAwMGM2IDAwMDBk
MDAwICAuLi4uLi4uLi4uLi4uLi4uDQowMDAwMDA4MDogMDAwMDE0NTggICAgICAgICAgICAgICAg
ICAgICAgICAgICAgIFguLi4NCnJvb3RAZng4Oi9zeXMva2VybmVsL2RlYnVnL2RyaS8wIw0KDQpU
aGVyZSBtdXN0IGJlIHNvbWUgc29ydCBvZiBBQ0wgb3Igc29tZXRoaW5nIGdvaW5nIG9uIGhlcmUu
DQoNClRvbQ0KDQo+IA0KPiBBbHNvIEkgbm90ZSB0aGF0IG5vdCBhbGwgZmlsZXMgbm90IHBlcm1p
dHRlZCBmb3IgcmVhZCBmcm9tDQo+IC9zeXMva2VybmVsL2RlYnVnL2RyaS8wLyoNCj4gSSB3YXMg
YWJsZSB0byBkdW1wIGNvbnRlbnRzIG9mIHNvbWUgZmlsZXMgaW4gZGVidWdmcy50eHQgKHNlZSBh
dHRhY2htZW50cykNCj4gTGlzdCBvZiBhdmFpbGFibGUgZm9yIHJlYWRpbmQgZmlsZXM6DQo+IGFt
ZGdwdV9ldmljdF9ndHQNCj4gYW1kZ3B1X2V2aWN0X3ZyYW0NCj4gYW1kZ3B1X2ZlbmNlX2luZm8N
Cj4gYW1kZ3B1X2Zpcm13YXJlX2luZm8NCj4gYW1kZ3B1X2dkc19tbQ0KPiBhbWRncHVfZ2VtX2lu
Zm8NCj4gYW1kZ3B1X2dwdV9yZWNvdmVyDQo+IGFtZGdwdV9ndHRfbW0NCj4gYW1kZ3B1X2d3c19t
bQ0KPiBhbWRncHVfb2FfbW0NCj4gYW1kZ3B1X3BtX2luZm8NCj4gYW1kZ3B1X3NhX2luZm8NCj4g
YW1kZ3B1X3Rlc3RfaWINCj4gYW1kZ3B1X3ZiaW9zDQo+IGFtZGdwdV92cmFtX21tDQo+IGNsaWVu
dHMNCj4gZnJhbWVidWZmZXINCj4gZ2VtX25hbWVzDQo+IGludGVybmFsX2NsaWVudHMNCj4gbmFt
ZQ0KPiBzdGF0ZQ0KPiB0dG1fcGFnZV9wb29sDQo+IA0KPiBNYXkgc29tZSBrZXJuZWwgb3B0aW9u
cyByZXN0cmljdCBhY2Nlc3MgZm9yIGZpbGVzIGluIGRlYnVnZnMgKGZvcg0KPiBleGFtcGxlIHRv
IGFtZGdwdV9nY2FfY29uZmlnKT8NCj4gSWYgeWVzIG9uIHdoaWNoIG9wdGlvbnMgc2hvdWxkIEkg
cGF5IGF0dGVudGlvbj8NCj4gSSBoYXZlIG5vIG1vcmUgaWRlYXMuIEkgdHJpZWQgZXZlcnl0aGlu
Zy4NCj4gDQo+IA0KPiANCj4gDQo+IC0tDQo+IEJlc3QgUmVnYXJkcywNCj4gTWlrZSBHYXZyaWxv
di4NCj4gDQoNCg==
