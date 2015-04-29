Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id F1B816B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 04:38:25 -0400 (EDT)
Received: by obbeb7 with SMTP id eb7so14899146obb.3
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 01:38:25 -0700 (PDT)
Received: from unicom145.biz-email.net (unicom145.biz-email.net. [210.51.26.145])
        by mx.google.com with ESMTPS id xv7si15151328obc.14.2015.04.29.01.38.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Apr 2015 01:38:24 -0700 (PDT)
Date: Wed, 29 Apr 2015 16:37:53 +0800
From: "songxiumiao@inspur.com" <songxiumiao@inspur.com>
Subject: Re: Re: [PATCH] of: return NUMA_NO_NODE from fallback of_node_to_nid()
References: <20150408165920.25007.6869.stgit@buzz>,
	<CAL_JsqKQPtNPfTAiqsKnFuU6e-qozzPgujM=8MHseG75R9cbSA@mail.gmail.com>,
	<552BC6E8.1040400@yandex-team.ru>,
	<CAL_Jsq+vaufZJAchHC1OaV9g18zFfkXyRZ9j5wm0VWosh9i4kQ@mail.gmail.com>,
	<201504290910595113455@inspur.com>,
	<55409696.8010209@yandex-team.ru>
MIME-Version: 1.0
Message-ID: <201504291637530087292@inspur.com>
Content-Type: multipart/alternative;
	boundary="----=_001_NextPart506071301544_=----"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Rob Herring <robherring2@gmail.com>
Cc: Grant Likely <grant.likely@linaro.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, =?UTF-8?B?6Zer5pmT5bOw?= <yanxiaofeng@inspur.com>, "x86@kernel.org" <x86@kernel.org>, "linux-metag@vger.kernel.org" <linux-metag@vger.kernel.org>

------=_001_NextPart506071301544_=----
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: base64

VGhhbmtzIGEgbG90LldlIGhhdmUgYWRkZWQgdGhlIHBhdGNoIGludG8gdGhlIGtlcm5lbDQuMC1y
YzQgYW5kIGl0IHdvcmtzLg0KIA0KRnJvbTogS29uc3RhbnRpbiBLaGxlYm5pa292DQpEYXRlOiAy
MDE1LTA0LTI5IDE2OjMwDQpUbzogc29uZ3hpdW1pYW9AaW5zcHVyLmNvbTsgUm9iIEhlcnJpbmcN
CkNDOiBHcmFudCBMaWtlbHk7IGRldmljZXRyZWVAdmdlci5rZXJuZWwub3JnOyBSb2IgSGVycmlu
ZzsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZzsgc3BhcmNsaW51eEB2Z2VyLmtlcm5lbC5v
cmc7IGxpbnV4LW1tQGt2YWNrLm9yZzsgbGludXhwcGMtZGV2OyB5YW54aWFvZmVuZzsgeDg2QGtl
cm5lbC5vcmc7IGxpbnV4LW1ldGFnQHZnZXIua2VybmVsLm9yZw0KU3ViamVjdDogUmU6IFtQQVRD
SF0gb2Y6IHJldHVybiBOVU1BX05PX05PREUgZnJvbSBmYWxsYmFjayBvZl9ub2RlX3RvX25pZCgp
DQoreDg2QGtlcm5lbC5vcmcNCitsaW51eC1tZXRhZ0B2Z2VyLmtlcm5lbC5vcmcNCiANCmhlcmUg
aXMgcHJvcG9zZWQgZml4Og0KaHR0cHM6Ly93d3cubWFpbC1hcmNoaXZlLmNvbS9saW51eC1rZXJu
ZWxAdmdlci5rZXJuZWwub3JnL21zZzg2NDAwOS5odG1sDQogDQpJdCByZXR1cm5zIE5VTUFfTk9f
Tk9ERSBmcm9tIGJvdGggc3RhdGljLWlubGluZSAoQ09ORklHX09GPW4pIGFuZCB3ZWFrDQp2ZXJz
aW9uIG9mIG9mX25vZGVfdG9fbmlkKCkuIFRoaXMgY2hhbmdlIG1pZ2h0IGFmZmVjdCBmZXcgYXJj
aGVzIHdoaWNoDQp3aGF2ZSBDT05GSUdfT0Y9eSBidXQgZG9lc24ndCBpbXBsZW1lbnQgb2Zfbm9k
ZV90b19uaWQoKSAoaS5lLiBkZXBlbmRzDQpvbiBkZWZhdWx0IGJlaGF2aW9yIG9mIHdlYWsgZnVu
Y3Rpb24pLiBJdCBzZWVtcyB0aGlzIGlzIG9ubHkgbWV0YWcuDQogDQpGcm9tIG1tLyBwb2ludCBv
ZiB2aWV3IHJldHVybmluZyBOVU1BX05PX05PREUgaXMgYSByaWdodCBjaG9pY2Ugd2hlbg0KY29k
ZSBoYXZlIG5vIGlkZWEgd2hpY2ggbnVtYSBub2RlIHNob3VsZCBiZSB1c2VkIC0tIG1lbW9yeSBh
bGxvY2F0aW9uDQpmdW5jdGlvbnMgY2hvb3NlIGN1cnJlbnQgbnVtYSBub2RlIChidXQgdGhleSBt
aWdodCB1c2UgYW55KS4NCiANCk9uIDI5LjA0LjIwMTUgMDQ6MTEsIHNvbmd4aXVtaWFvQGluc3B1
ci5jb20gd3JvdGU6DQo+IFdoZW4gd2UgdGVzdCB0aGUgY3B1IGFuZCBtZW1vcnkgaG90cGx1ZyBm
ZWF0dXJlIGluIHRoZSBzZXJ2ZXIgd2l0aCB4ODYNCj4gYXJjaGl0ZWN0dXJlIGFuZCBrZXJuZWw0
LjAtcmM0LHdlIG1ldCB0aGUgc2ltaWxhciBwcm9ibGVtLg0KPg0KPiBUaGUgc2l0dWF0aW9uIGlz
IHRoYXQgd2hlbiBtZW1vcnkgaW4gbm9kZTAgaXMgb2ZmbGluZSx0aGUgc3lzdGVtIGlzIGRvd24N
Cj4gZHVyaW5nIGJvb3RpbmcuDQo+DQo+IEZvbGxvd2luZyBpcyB0aGUgYnVnIGluZm9ybWF0aW9u
Og0KPiBbICAgIDAuMzM1MTc2XSBCVUc6IHVuYWJsZSB0byBoYW5kbGUga2VybmVsIHBhZ2luZyBy
ZXF1ZXN0IGF0DQo+IDAwMDAwMDAwMDAwMDFiMDgNCj4gWyAgICAwLjM0MjE2NF0gSVA6IFs8ZmZm
ZmZmZmY4MTE4MjU4Nz5dIF9fYWxsb2NfcGFnZXNfbm9kZW1hc2srMHhiNy8weDk0MA0KPiBbICAg
IDAuMzQ4NzA2XSBQR0QgMA0KPiBbICAgIDAuMzUwNzM1XSBPb3BzOiAwMDAwIFsjMV0gU01QDQo+
IFsgMC4zNTM5OTNdIE1vZHVsZXMgbGlua2VkIGluOg0KPiBbICAgIDAuMzU3MDYzXSBDUFU6IDAg
UElEOiAxIENvbW06IHN3YXBwZXIvMCBOb3QgdGFpbnRlZCA0LjAuMC1yYzQgIzENCj4gWyAgICAw
LjM2MzIzMl0gSGFyZHdhcmUgbmFtZTogSW5zcHVyIFRTODYwL1RTODYwLCBCSU9TIFRTODYwXzIu
MC4wDQo+IDIwMTUvMDMvMjQNCj4gWyAgICAwLjM3MDA5NV0gdGFzazogZmZmZjg4MDg1YjFlMDAw
MCB0aTogZmZmZjg4MDg1YjFlODAwMCB0YXNrLnRpOg0KPiBmZmZmODgwODViMWU4MDAwDQo+IFsg
ICAgMC4zNzc1NjRdIFJJUDogMDAxMDpbPGZmZmZmZmZmODExODI1ODc+XSAgWzxmZmZmZmZmZjgx
MTgyNTg3Pl0NCj4gX19hbGxvY19wYWdlc19ub2RlbWFzaysweGI3LzB4OTQwDQo+IFsgICAgMC4z
ODY1MjRdIFJTUDogMDAwMDpmZmZmODgwODViMWViYWM4ICBFRkxBR1M6IDAwMDEwMjQ2DQo+IFsg
ICAgMC4zOTE4MjhdIFJBWDogMDAwMDAwMDAwMDAwMWIwMCBSQlg6IDAwMDAwMDAwMDAwMDAwMTAg
UkNYOg0KPiAwMDAwMDAwMDAwMDAwMDAwDQo+IFsgICAgMC4zOTg5NTNdIFJEWDogMDAwMDAwMDAw
MDAwMDAwMCBSU0k6IDAwMDAwMDAwMDAwMDAwMDAgUkRJOg0KPiAwMDAwMDAwMDAwMjA1MmQwDQo+
IFsgICAgMC40MDYwNzVdIFJCUDogZmZmZjg4MDg1YjFlYmJiOCBSMDg6IGZmZmY4ODA4NWIxM2Zl
YzAgUjA5Og0KPiAwMDAwMDAwMDViMTNmZTAxDQo+IFsgICAgMC40MTMxOThdIFIxMDogZmZmZjg4
MDg1ZTgwNzMwMCBSMTE6IGZmZmZmZmZmODEwZDRiYzEgUjEyOg0KPiAwMDAwMDAwMDAwMDEwMDJh
DQo+IFsgICAgMC40MjAzMjFdIFIxMzogMDAwMDAwMDAwMDIwNTJkMCBSMTQ6IDAwMDAwMDAwMDAw
MDAwMDEgUjE1Og0KPiAwMDAwMDAwMDAwMDA0MGQwDQo+IFsgICAgMC40Mjc0NDZdIEZTOiAwMDAw
MDAwMDAwMDAwMDAwKDAwMDApIEdTOmZmZmY4ODA4NWVlMDAwMDAoMDAwMCkNCj4ga25sR1M6MDAw
MDAwMDAwMDAwMDAwMA0KPiBbICAgIDAuNDM1NTIyXSBDUzogIDAwMTAgRFM6IDAwMDAgRVM6IDAw
MDAgQ1IwOiAwMDAwMDAwMDgwMDUwMDMzDQo+IFsgICAgMC40NDEyNTldIENSMjogMDAwMDAwMDAw
MDAwMWIwOCBDUjM6IDAwMDAwMDAwMDE5YWUwMDAgQ1I0Og0KPiAwMDAwMDAwMDAwMTQwNmYwDQo+
IFsgICAgMC40NDgzODJdIFN0YWNrOg0KPiBbIDAuNDUwMzkyXSAgZmZmZjg4MDg1YjFlMDAwMCAw
MDAwMDAwMDAwMDAwNDAwIGZmZmY4ODA4NWIxZWZmZmYNCj4gZmZmZjg4MDg1YjFlYmI2OA0KPiBb
ICAgIDAuNDU3ODQ2XSAgMDAwMDAwMDAwMDAwMDA3YiBmZmZmODgwODViMTJkMTQwIGZmZmY4ODA4
NWIyNDkwMDANCj4gMDAwMDAwMDAwMDAwMDA3Yg0KPiBbIDAuNDY1Mjk4XSAgZmZmZjg4MDg1YjFl
YmIyOCBmZmZmZmZmZjgxYWYyOTAwIDAwMDAwMDAwMDAwMDAwMDANCj4gMDAyMDUyZDA1YjEyZDE0
MA0KPiBbICAgIDAuNDcyNzUwXSBDYWxsIFRyYWNlOg0KPiBbICAgIDAuNDc1MjA2XSAgWzxmZmZm
ZmZmZjgxMWQyN2IzPl0gPyBkZWFjdGl2YXRlX3NsYWIrMHgzODMvMHg0MDANCj4gWyAgICAwLjQ4
MTEyM10gWzxmZmZmZmZmZjgxMWQzOTQ3Pl0gbmV3X3NsYWIrMHhhNy8weDQ2MA0KPiBbIDAuNDg2
MTc0XSAgWzxmZmZmZmZmZjgxNjc4OWU1Pl0gX19zbGFiX2FsbG9jKzB4MzEwLzB4NDcwDQo+IFsg
ICAgMC40OTE2NTVdIFs8ZmZmZmZmZmY4MTA1MzA0Zj5dID8gZG1hcl9tc2lfc2V0X2FmZmluaXR5
KzB4OGYvMHhjMA0KPiBbICAgIDAuNDk3OTIxXSBbPGZmZmZmZmZmODEwZDRiYzE+XSA/IF9faXJx
X2RvbWFpbl9hZGQrMHg0MS8weDEwMA0KPiBbIDAuNTAzODM4XSAgWzxmZmZmZmZmZjgxMGQwZmVl
Pl0gPyBpcnFfZG9fc2V0X2FmZmluaXR5KzB4NWUvMHg3MA0KPiBbICAgIDAuNTA5OTIwXSBbPGZm
ZmZmZmZmODExZDU3MWQ+XSBfX2ttYWxsb2Nfbm9kZSsweGFkLzB4MmUwDQo+IFsgMC41MTU0ODNd
ICBbPGZmZmZmZmZmODEwZDRiYzE+XSA/IF9faXJxX2RvbWFpbl9hZGQrMHg0MS8weDEwMA0KPiBb
ICAgIDAuNTIxMzkyXSBbPGZmZmZmZmZmODEwZDRiYzE+XSBfX2lycV9kb21haW5fYWRkKzB4NDEv
MHgxMDANCj4gWyAwLjUyNzEzM10gIFs8ZmZmZmZmZmY4MTA1MTAyZT5dIG1wX2lycWRvbWFpbl9j
cmVhdGUrMHg5ZS8weDEyMA0KPiBbICAgIDAuNTMzMTQwXSBbPGZmZmZmZmZmODFiMmZiMTQ+XSBz
ZXR1cF9JT19BUElDKzB4NjQvMHgxYmUNCj4gWyAwLjUzODYyMl0gIFs8ZmZmZmZmZmY4MWIyZTIy
Nj5dIGFwaWNfYnNwX3NldHVwKzB4YTIvMHhhZQ0KPiBbICAgIDAuNTQ0MDk5XSBbPGZmZmZmZmZm
ODFiMmJjNzA+XSBuYXRpdmVfc21wX3ByZXBhcmVfY3B1cysweDI2Ny8weDJiMg0KPiBbICAgIDAu
NTUwNTMxXSBbPGZmZmZmZmZmODFiMTkyN2I+XSBrZXJuZWxfaW5pdF9mcmVlYWJsZSsweGYyLzB4
MjUzDQo+IFsgICAgMC41NTY2MjVdIFs8ZmZmZmZmZmY4MTY2Yjk2MD5dID8gcmVzdF9pbml0KzB4
ODAvMHg4MA0KPiBbIDAuNTYxODQ1XSAgWzxmZmZmZmZmZjgxNjZiOTZlPl0ga2VybmVsX2luaXQr
MHhlLzB4ZjANCj4gWyAgICAwLjU2Njk3OV0gWzxmZmZmZmZmZjgxNjgxYmQ4Pl0gcmV0X2Zyb21f
Zm9yaysweDU4LzB4OTANCj4gWyAwLjU3MjM3NF0gIFs8ZmZmZmZmZmY4MTY2Yjk2MD5dID8gcmVz
dF9pbml0KzB4ODAvMHg4MA0KPiBbICAgIDAuNTc3NTkxXSBDb2RlOiAzMCA5NyAwMCA4OSA0NSBi
YyA4MyBlMSAwZiBiOCAyMiAwMSAzMiAwMSAwMSBjOSBkMw0KPiBmOCA4MyBlMCAwMyA4OSA5ZCA2
YyBmZiBmZiBmZiA4MyBlMyAxMCA4OSA0NSBjMCAwZiA4NSA2ZCAwMSAwMCAwMCA0OCA4Yg0KPiA0
NSA4OCA8NDg+IDgzIDc4IDA4IDAwIDBmIDg0IDUxIDAxIDAwIDAwIGI4IDAxIDAwIDAwIDAwIDQ0
IDg5IGYxIGQzIGUwDQo+IFsgICAgMC41OTc1MzddIFJJUCBbPGZmZmZmZmZmODExODI1ODc+XSBf
X2FsbG9jX3BhZ2VzX25vZGVtYXNrKzB4YjcvMHg5NDANCj4gWyAgICAwLjYwNDE1OF0gIFJTUCA8
ZmZmZjg4MDg1YjFlYmFjOD4NCj4gWyAgICAwLjYwNzY0M10gQ1IyOiAwMDAwMDAwMDAwMDAxYjA4
DQo+IFsgICAgMC42MTA5NjJdIC0tLVsgZW5kIHRyYWNlIDBhNjAwYzA4NDEzODY5OTIgXS0tLQ0K
PiBbICAgIDAuNjE1NTczXSBLZXJuZWwgcGFuaWMgLSBub3Qgc3luY2luZzogRmF0YWwgZXhjZXB0
aW9uDQo+IFsgICAgMC42MjA3OTJdIC0tLVsgZW5kIEtlcm5lbCBwYW5pYyAtIG5vdCBzeW5jaW5n
OiBGYXRhbCBleGNlcHRpb24NCj4gKkZyb206KiBSb2IgSGVycmluZyA8bWFpbHRvOnJvYmhlcnJp
bmcyQGdtYWlsLmNvbT4NCj4gKkRhdGU6KiAyMDE1LTA0LTE0IDAwOjQ5DQo+ICpUbzoqIEtvbnN0
YW50aW4gS2hsZWJuaWtvdiA8bWFpbHRvOmtobGVibmlrb3ZAeWFuZGV4LXRlYW0ucnU+DQo+ICpD
QzoqIEdyYW50IExpa2VseSA8bWFpbHRvOmdyYW50Lmxpa2VseUBsaW5hcm8ub3JnPjsNCj4gZGV2
aWNldHJlZUB2Z2VyLmtlcm5lbC5vcmcgPG1haWx0bzpkZXZpY2V0cmVlQHZnZXIua2VybmVsLm9y
Zz47IFJvYg0KPiBIZXJyaW5nIDxtYWlsdG86cm9iaCtkdEBrZXJuZWwub3JnPjsgbGludXgta2Vy
bmVsQHZnZXIua2VybmVsLm9yZw0KPiA8bWFpbHRvOmxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5v
cmc+OyBzcGFyY2xpbnV4QHZnZXIua2VybmVsLm9yZw0KPiA8bWFpbHRvOnNwYXJjbGludXhAdmdl
ci5rZXJuZWwub3JnPjsgbGludXgtbW1Aa3ZhY2sub3JnDQo+IDxtYWlsdG86bGludXgtbW1Aa3Zh
Y2sub3JnPjsgbGludXhwcGMtZGV2DQo+IDxtYWlsdG86bGludXhwcGMtZGV2QGxpc3RzLm96bGFi
cy5vcmc+DQo+ICpTdWJqZWN0OiogUmU6IFtQQVRDSF0gb2Y6IHJldHVybiBOVU1BX05PX05PREUg
ZnJvbSBmYWxsYmFjaw0KPiBvZl9ub2RlX3RvX25pZCgpDQo+IE9uIE1vbiwgQXByIDEzLCAyMDE1
IGF0IDg6MzggQU0sIEtvbnN0YW50aW4gS2hsZWJuaWtvdg0KPiA8a2hsZWJuaWtvdkB5YW5kZXgt
dGVhbS5ydT4gd3JvdGU6DQo+ICA+IE9uIDEzLjA0LjIwMTUgMTY6MjIsIFJvYiBIZXJyaW5nIHdy
b3RlOg0KPiAgPj4NCj4gID4+IE9uIFdlZCwgQXByIDgsIDIwMTUgYXQgMTE6NTkgQU0sIEtvbnN0
YW50aW4gS2hsZWJuaWtvdg0KPiAgPj4gPGtobGVibmlrb3ZAeWFuZGV4LXRlYW0ucnU+IHdyb3Rl
Og0KPiAgPj4+DQo+ICA+Pj4gTm9kZSAwIG1pZ2h0IGJlIG9mZmxpbmUgYXMgd2VsbCBhcyBhbnkg
b3RoZXIgbnVtYSBub2RlLA0KPiAgPj4+IGluIHRoaXMgY2FzZSBrZXJuZWwgY2Fubm90IGhhbmRs
ZSBtZW1vcnkgYWxsb2NhdGlvbiBhbmQgY3Jhc2hlcy4NCj4gID4+Pg0KPiAgPj4+IFNpZ25lZC1v
ZmYtYnk6IEtvbnN0YW50aW4gS2hsZWJuaWtvdiA8a2hsZWJuaWtvdkB5YW5kZXgtdGVhbS5ydT4N
Cj4gID4+PiBGaXhlczogMGMzZjA2MWMxOTVjICgib2Y6IGltcGxlbWVudCBvZl9ub2RlX3RvX25p
ZCBhcyBhIHdlYWsgZnVuY3Rpb24iKQ0KPiAgPj4+IC0tLQ0KPiAgPj4+ICAgZHJpdmVycy9vZi9i
YXNlLmMgIHwgICAgMiArLQ0KPiAgPj4+ICAgaW5jbHVkZS9saW51eC9vZi5oIHwgICAgNSArKysr
LQ0KPiAgPj4+ICAgMiBmaWxlcyBjaGFuZ2VkLCA1IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25z
KC0pDQo+ICA+Pj4NCj4gID4+PiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9vZi9iYXNlLmMgYi9kcml2
ZXJzL29mL2Jhc2UuYw0KPiAgPj4+IGluZGV4IDhmMTY1YjExMmUwMy4uNTFmNGJkMTZlNjEzIDEw
MDY0NA0KPiAgPj4+IC0tLSBhL2RyaXZlcnMvb2YvYmFzZS5jDQo+ICA+Pj4gKysrIGIvZHJpdmVy
cy9vZi9iYXNlLmMNCj4gID4+PiBAQCAtODksNyArODksNyBAQCBFWFBPUlRfU1lNQk9MKG9mX25f
c2l6ZV9jZWxscyk7DQo+ICA+Pj4gICAjaWZkZWYgQ09ORklHX05VTUENCj4gID4+PiAgIGludCBf
X3dlYWsgb2Zfbm9kZV90b19uaWQoc3RydWN0IGRldmljZV9ub2RlICpucCkNCj4gID4+PiAgIHsN
Cj4gID4+PiAtICAgICAgIHJldHVybiBudW1hX25vZGVfaWQoKTsNCj4gID4+PiArICAgICAgIHJl
dHVybiBOVU1BX05PX05PREU7DQo+ICA+Pg0KPiAgPj4NCj4gID4+IFRoaXMgaXMgZ29pbmcgdG8g
YnJlYWsgYW55IE5VTUEgbWFjaGluZSB0aGF0IGVuYWJsZXMgT0YgYW5kIGV4cGVjdHMNCj4gID4+
IHRoZSB3ZWFrIGZ1bmN0aW9uIHRvIHdvcmsuDQo+ICA+DQo+ICA+DQo+ICA+IFdoeT8gTlVNQV9O
T19OT0RFID09IC0xIC0tIHRoaXMncyBzdGFuZGFyZCAibm8tYWZmaW5pdHkiIHNpZ25hbC4NCj4g
ID4gQXMgSSBzZWUgcG93ZXJwYy9zcGFyYyB2ZXJzaW9ucyBvZiBvZl9ub2RlX3RvX25pZCByZXR1
cm5zIC0xIGlmIHRoZXkNCj4gID4gY2Fubm90IGZpbmQgb3V0IHdoaWNoIG5vZGUgc2hvdWxkIGJl
IHVzZWQuDQo+IEFoLCBJIHdhcyB0aGlua2luZyB0aG9zZSBwbGF0Zm9ybXMgd2VyZSByZWx5aW5n
IG9uIHRoZSBkZWZhdWx0DQo+IGltcGxlbWVudGF0aW9uLiBJIGd1ZXNzIGFueSByZWFsIE5VTUEg
c3VwcG9ydCBpcyBnb2luZyB0byBuZWVkIHRvDQo+IG92ZXJyaWRlIHRoaXMgZnVuY3Rpb24uIFRo
ZSBhcm02NCBwYXRjaCBzZXJpZXMgZG9lcyB0aGF0IGFzIHdlbGwuIFdlDQo+IG5lZWQgdG8gYmUg
c3VyZSB0aGlzIGNoYW5nZSBpcyBjb3JyZWN0IGZvciBtZXRhZyB3aGljaCBhcHBlYXJzIHRvIGJl
DQo+IHRoZSBvbmx5IG90aGVyIE9GIGVuYWJsZWQgcGxhdGZvcm0gd2l0aCBOVU1BIHN1cHBvcnQu
DQo+IEluIHRoYXQgY2FzZSwgdGhlbiB0aGVyZSBpcyBsaXR0bGUgcmVhc29uIHRvIGtlZXAgdGhl
IGlubGluZSBhbmQgd2UNCj4gY2FuIGp1c3QgYWx3YXlzIGVuYWJsZSB0aGUgd2VhayBmdW5jdGlv
biAod2l0aCB5b3VyIGNoYW5nZSkuIEl0IGlzDQo+IHNsaWdodGx5IGxlc3Mgb3B0aW1hbCwgYnV0
IHRoZSBmZXcgY2FsbGVycyBoYXJkbHkgYXBwZWFyIHRvIGJlIGhvdA0KPiBwYXRocy4NCj4gUm9i
DQo+IC0tDQo+IFRvIHVuc3Vic2NyaWJlIGZyb20gdGhpcyBsaXN0OiBzZW5kIHRoZSBsaW5lICJ1
bnN1YnNjcmliZSBsaW51eC1rZXJuZWwiIGluDQo+IHRoZSBib2R5IG9mIGEgbWVzc2FnZSB0byBt
YWpvcmRvbW9Admdlci5rZXJuZWwub3JnDQo+IE1vcmUgbWFqb3Jkb21vIGluZm8gYXQgaHR0cDov
L3ZnZXIua2VybmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1sDQo+IFBsZWFzZSByZWFkIHRoZSBG
QVEgYXQgIGh0dHA6Ly93d3cudHV4Lm9yZy9sa21sLw0KIA0KIA0KLS0gDQpLb25zdGFudGluDQo=

------=_001_NextPart506071301544_=----
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; charse=
t=3DUTF-8"><style>body { line-height: 1.5; }blockquote { margin-top: 0px; =
margin-bottom: 0px; margin-left: 0.5em; }body { font-size: 10.5pt; font-fa=
mily: =E5=BE=AE=E8=BD=AF=E9=9B=85=E9=BB=91; color: rgb(0, 0, 0); line-heig=
ht: 1.5; }</style></head><body>=0A<div><span></span></div><div><span><div =
style=3D"MARGIN: 10px; FONT-FAMILY: verdana; FONT-SIZE: 10pt"><div style=
=3D"font-family: =E5=AE=8B=E4=BD=93; color: rgb(128, 128, 128); font-size:=
 10.5pt; font-weight: bold;">Thanks a lot.We have added the patch into the=
 kernel4.0-rc4 and it works.</div></div></span></div>=0A<blockquote style=
=3D"margin-top: 0px; margin-bottom: 0px; margin-left: 0.5em;"><div>&nbsp;<=
/div><div style=3D"border:none;border-top:solid #B5C4DF 1.0pt;padding:3.0p=
t 0cm 0cm 0cm"><div style=3D"PADDING-RIGHT: 8px; PADDING-LEFT: 8px; FONT-S=
IZE: 12px;FONT-FAMILY:tahoma;COLOR:#000000; BACKGROUND: #efefef; PADDING-B=
OTTOM: 8px; PADDING-TOP: 8px"><div><b>From:</b>&nbsp;<a href=3D"mailto:khl=
ebnikov@yandex-team.ru">Konstantin Khlebnikov</a></div><div><b>Date:</b>&n=
bsp;2015-04-29&nbsp;16:30</div><div><b>To:</b>&nbsp;<a href=3D"mailto:song=
xiumiao@inspur.com">songxiumiao@inspur.com</a>; <a href=3D"mailto:robherri=
ng2@gmail.com">Rob Herring</a></div><div><b>CC:</b>&nbsp;<a href=3D"mailto=
:grant.likely@linaro.org">Grant Likely</a>; <a href=3D"mailto:devicetree@v=
ger.kernel.org">devicetree@vger.kernel.org</a>; <a href=3D"mailto:robh+dt@=
kernel.org">Rob Herring</a>; <a href=3D"mailto:linux-kernel@vger.kernel.or=
g">linux-kernel@vger.kernel.org</a>; <a href=3D"mailto:sparclinux@vger.ker=
nel.org">sparclinux@vger.kernel.org</a>; <a href=3D"mailto:linux-mm@kvack.=
org">linux-mm@kvack.org</a>; <a href=3D"mailto:linuxppc-dev@lists.ozlabs.o=
rg">linuxppc-dev</a>; <a href=3D"mailto:yanxiaofeng@inspur.com">yanxiaofen=
g</a>; <a href=3D"mailto:x86@kernel.org">x86@kernel.org</a>; <a href=3D"ma=
ilto:linux-metag@vger.kernel.org">linux-metag@vger.kernel.org</a></div><di=
v><b>Subject:</b>&nbsp;Re: [PATCH] of: return NUMA_NO_NODE from fallback o=
f_node_to_nid()</div></div></div><div><div>+x86@kernel.org</div>=0A<div>+l=
inux-metag@vger.kernel.org</div>=0A<div>&nbsp;</div>=0A<div>here is propos=
ed fix:</div>=0A<div>https://www.mail-archive.com/linux-kernel@vger.kernel=
.org/msg864009.html</div>=0A<div>&nbsp;</div>=0A<div>It returns NUMA_NO_NO=
DE from both static-inline (CONFIG_OF=3Dn) and weak</div>=0A<div>version o=
f of_node_to_nid(). This change might affect few arches which</div>=0A<div=
>whave CONFIG_OF=3Dy but doesn't implement of_node_to_nid() (i.e. depends<=
/div>=0A<div>on default behavior of weak function). It seems this is only =
metag.</div>=0A<div>&nbsp;</div>=0A<div> From mm/ point of view returning =
NUMA_NO_NODE is a right choice when</div>=0A<div>code have no idea which n=
uma node should be used -- memory allocation</div>=0A<div>functions choose=
 current numa node (but they might use any).</div>=0A<div>&nbsp;</div>=0A<=
div>On 29.04.2015 04:11, songxiumiao@inspur.com wrote:</div>=0A<div>&gt; W=
hen we test the cpu and memory hotplug feature in the server with x86</div=
>=0A<div>&gt; architecture and kernel4.0-rc4,we met the similar problem.</=
div>=0A<div>&gt;</div>=0A<div>&gt; The situation is that when memory in no=
de0 is offline,the system is down</div>=0A<div>&gt; during booting.</div>=
=0A<div>&gt;</div>=0A<div>&gt; Following is the bug information:</div>=0A<=
div>&gt; [&nbsp;&nbsp;&nbsp; 0.335176] BUG: unable to handle kernel paging=
 request at</div>=0A<div>&gt; 0000000000001b08</div>=0A<div>&gt; [&nbsp;&n=
bsp;&nbsp; 0.342164] IP: [&lt;ffffffff81182587&gt;] __alloc_pages_nodemask=
+0xb7/0x940</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.348706] PGD 0</div>=0A=
<div>&gt; [&nbsp;&nbsp;&nbsp; 0.350735] Oops: 0000 [#1] SMP</div>=0A<div>&=
gt; [ 0.353993] Modules linked in:</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0=
.357063] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.0.0-rc4 #1</div>=0A<d=
iv>&gt; [&nbsp;&nbsp;&nbsp; 0.363232] Hardware name: Inspur TS860/TS860, B=
IOS TS860_2.0.0</div>=0A<div>&gt; 2015/03/24</div>=0A<div>&gt; [&nbsp;&nbs=
p;&nbsp; 0.370095] task: ffff88085b1e0000 ti: ffff88085b1e8000 task.ti:</d=
iv>=0A<div>&gt; ffff88085b1e8000</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.3=
77564] RIP: 0010:[&lt;ffffffff81182587&gt;]&nbsp; [&lt;ffffffff81182587&gt=
;]</div>=0A<div>&gt; __alloc_pages_nodemask+0xb7/0x940</div>=0A<div>&gt; [=
&nbsp;&nbsp;&nbsp; 0.386524] RSP: 0000:ffff88085b1ebac8&nbsp; EFLAGS: 0001=
0246</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.391828] RAX: 0000000000001b00=
 RBX: 0000000000000010 RCX:</div>=0A<div>&gt; 0000000000000000</div>=0A<di=
v>&gt; [&nbsp;&nbsp;&nbsp; 0.398953] RDX: 0000000000000000 RSI: 0000000000=
000000 RDI:</div>=0A<div>&gt; 00000000002052d0</div>=0A<div>&gt; [&nbsp;&n=
bsp;&nbsp; 0.406075] RBP: ffff88085b1ebbb8 R08: ffff88085b13fec0 R09:</div=
>=0A<div>&gt; 000000005b13fe01</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.413=
198] R10: ffff88085e807300 R11: ffffffff810d4bc1 R12:</div>=0A<div>&gt; 00=
0000000001002a</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.420321] R13: 000000=
00002052d0 R14: 0000000000000001 R15:</div>=0A<div>&gt; 00000000000040d0</=
div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.427446] FS: 0000000000000000(0000) =
GS:ffff88085ee00000(0000)</div>=0A<div>&gt; knlGS:0000000000000000</div>=
=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.435522] CS:&nbsp; 0010 DS: 0000 ES: 000=
0 CR0: 0000000080050033</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.441259] CR=
2: 0000000000001b08 CR3: 00000000019ae000 CR4:</div>=0A<div>&gt; 000000000=
01406f0</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.448382] Stack:</div>=0A<di=
v>&gt; [ 0.450392]&nbsp; ffff88085b1e0000 0000000000000400 ffff88085b1efff=
f</div>=0A<div>&gt; ffff88085b1ebb68</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp;=
 0.457846]&nbsp; 000000000000007b ffff88085b12d140 ffff88085b249000</div>=
=0A<div>&gt; 000000000000007b</div>=0A<div>&gt; [ 0.465298]&nbsp; ffff8808=
5b1ebb28 ffffffff81af2900 0000000000000000</div>=0A<div>&gt; 002052d05b12d=
140</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.472750] Call Trace:</div>=0A<d=
iv>&gt; [&nbsp;&nbsp;&nbsp; 0.475206]&nbsp; [&lt;ffffffff811d27b3&gt;] ? d=
eactivate_slab+0x383/0x400</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.481123]=
 [&lt;ffffffff811d3947&gt;] new_slab+0xa7/0x460</div>=0A<div>&gt; [ 0.4861=
74]&nbsp; [&lt;ffffffff816789e5&gt;] __slab_alloc+0x310/0x470</div>=0A<div=
>&gt; [&nbsp;&nbsp;&nbsp; 0.491655] [&lt;ffffffff8105304f&gt;] ? dmar_msi_=
set_affinity+0x8f/0xc0</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.497921] [&l=
t;ffffffff810d4bc1&gt;] ? __irq_domain_add+0x41/0x100</div>=0A<div>&gt; [ =
0.503838]&nbsp; [&lt;ffffffff810d0fee&gt;] ? irq_do_set_affinity+0x5e/0x70=
</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.509920] [&lt;ffffffff811d571d&gt;=
] __kmalloc_node+0xad/0x2e0</div>=0A<div>&gt; [ 0.515483]&nbsp; [&lt;fffff=
fff810d4bc1&gt;] ? __irq_domain_add+0x41/0x100</div>=0A<div>&gt; [&nbsp;&n=
bsp;&nbsp; 0.521392] [&lt;ffffffff810d4bc1&gt;] __irq_domain_add+0x41/0x10=
0</div>=0A<div>&gt; [ 0.527133]&nbsp; [&lt;ffffffff8105102e&gt;] mp_irqdom=
ain_create+0x9e/0x120</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.533140] [&lt=
;ffffffff81b2fb14&gt;] setup_IO_APIC+0x64/0x1be</div>=0A<div>&gt; [ 0.5386=
22]&nbsp; [&lt;ffffffff81b2e226&gt;] apic_bsp_setup+0xa2/0xae</div>=0A<div=
>&gt; [&nbsp;&nbsp;&nbsp; 0.544099] [&lt;ffffffff81b2bc70&gt;] native_smp_=
prepare_cpus+0x267/0x2b2</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.550531] [=
&lt;ffffffff81b1927b&gt;] kernel_init_freeable+0xf2/0x253</div>=0A<div>&gt=
; [&nbsp;&nbsp;&nbsp; 0.556625] [&lt;ffffffff8166b960&gt;] ? rest_init+0x8=
0/0x80</div>=0A<div>&gt; [ 0.561845]&nbsp; [&lt;ffffffff8166b96e&gt;] kern=
el_init+0xe/0xf0</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.566979] [&lt;ffff=
ffff81681bd8&gt;] ret_from_fork+0x58/0x90</div>=0A<div>&gt; [ 0.572374]&nb=
sp; [&lt;ffffffff8166b960&gt;] ? rest_init+0x80/0x80</div>=0A<div>&gt; [&n=
bsp;&nbsp;&nbsp; 0.577591] Code: 30 97 00 89 45 bc 83 e1 0f b8 22 01 32 01=
 01 c9 d3</div>=0A<div>&gt; f8 83 e0 03 89 9d 6c ff ff ff 83 e3 10 89 45 c=
0 0f 85 6d 01 00 00 48 8b</div>=0A<div>&gt; 45 88 &lt;48&gt; 83 78 08 00 0=
f 84 51 01 00 00 b8 01 00 00 00 44 89 f1 d3 e0</div>=0A<div>&gt; [&nbsp;&n=
bsp;&nbsp; 0.597537] RIP [&lt;ffffffff81182587&gt;] __alloc_pages_nodemask=
+0xb7/0x940</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.604158]&nbsp; RSP &lt;=
ffff88085b1ebac8&gt;</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.607643] CR2: =
0000000000001b08</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.610962] ---[ end =
trace 0a600c0841386992 ]---</div>=0A<div>&gt; [&nbsp;&nbsp;&nbsp; 0.615573=
] Kernel panic - not syncing: Fatal exception</div>=0A<div>&gt; [&nbsp;&nb=
sp;&nbsp; 0.620792] ---[ end Kernel panic - not syncing: Fatal exception</=
div>=0A<div>&gt; *From:* Rob Herring &lt;mailto:robherring2@gmail.com&gt;<=
/div>=0A<div>&gt; *Date:* 2015-04-14 00:49</div>=0A<div>&gt; *To:* Konstan=
tin Khlebnikov &lt;mailto:khlebnikov@yandex-team.ru&gt;</div>=0A<div>&gt; =
*CC:* Grant Likely &lt;mailto:grant.likely@linaro.org&gt;;</div>=0A<div>&g=
t; devicetree@vger.kernel.org &lt;mailto:devicetree@vger.kernel.org&gt;; R=
ob</div>=0A<div>&gt; Herring &lt;mailto:robh+dt@kernel.org&gt;; linux-kern=
el@vger.kernel.org</div>=0A<div>&gt; &lt;mailto:linux-kernel@vger.kernel.o=
rg&gt;; sparclinux@vger.kernel.org</div>=0A<div>&gt; &lt;mailto:sparclinux=
@vger.kernel.org&gt;; linux-mm@kvack.org</div>=0A<div>&gt; &lt;mailto:linu=
x-mm@kvack.org&gt;; linuxppc-dev</div>=0A<div>&gt; &lt;mailto:linuxppc-dev=
@lists.ozlabs.org&gt;</div>=0A<div>&gt; *Subject:* Re: [PATCH] of: return =
NUMA_NO_NODE from fallback</div>=0A<div>&gt; of_node_to_nid()</div>=0A<div=
>&gt; On Mon, Apr 13, 2015 at 8:38 AM, Konstantin Khlebnikov</div>=0A<div>=
&gt; &lt;khlebnikov@yandex-team.ru&gt; wrote:</div>=0A<div>&gt;&nbsp; &gt;=
 On 13.04.2015 16:22, Rob Herring wrote:</div>=0A<div>&gt;&nbsp; &gt;&gt;<=
/div>=0A<div>&gt;&nbsp; &gt;&gt; On Wed, Apr 8, 2015 at 11:59 AM, Konstant=
in Khlebnikov</div>=0A<div>&gt;&nbsp; &gt;&gt; &lt;khlebnikov@yandex-team.=
ru&gt; wrote:</div>=0A<div>&gt;&nbsp; &gt;&gt;&gt;</div>=0A<div>&gt;&nbsp;=
 &gt;&gt;&gt; Node 0 might be offline as well as any other numa node,</div=
>=0A<div>&gt;&nbsp; &gt;&gt;&gt; in this case kernel cannot handle memory =
allocation and crashes.</div>=0A<div>&gt;&nbsp; &gt;&gt;&gt;</div>=0A<div>=
&gt;&nbsp; &gt;&gt;&gt; Signed-off-by: Konstantin Khlebnikov &lt;khlebniko=
v@yandex-team.ru&gt;</div>=0A<div>&gt;&nbsp; &gt;&gt;&gt; Fixes: 0c3f061c1=
95c ("of: implement of_node_to_nid as a weak function")</div>=0A<div>&gt;&=
nbsp; &gt;&gt;&gt; ---</div>=0A<div>&gt;&nbsp; &gt;&gt;&gt;&nbsp;&nbsp; dr=
ivers/of/base.c&nbsp; |&nbsp;&nbsp;&nbsp; 2 +-</div>=0A<div>&gt;&nbsp; &gt=
;&gt;&gt;&nbsp;&nbsp; include/linux/of.h |&nbsp;&nbsp;&nbsp; 5 ++++-</div>=
=0A<div>&gt;&nbsp; &gt;&gt;&gt;&nbsp;&nbsp; 2 files changed, 5 insertions(=
+), 2 deletions(-)</div>=0A<div>&gt;&nbsp; &gt;&gt;&gt;</div>=0A<div>&gt;&=
nbsp; &gt;&gt;&gt; diff --git a/drivers/of/base.c b/drivers/of/base.c</div=
>=0A<div>&gt;&nbsp; &gt;&gt;&gt; index 8f165b112e03..51f4bd16e613 100644</=
div>=0A<div>&gt;&nbsp; &gt;&gt;&gt; --- a/drivers/of/base.c</div>=0A<div>&=
gt;&nbsp; &gt;&gt;&gt; +++ b/drivers/of/base.c</div>=0A<div>&gt;&nbsp; &gt=
;&gt;&gt; @@ -89,7 +89,7 @@ EXPORT_SYMBOL(of_n_size_cells);</div>=0A<div>&=
gt;&nbsp; &gt;&gt;&gt;&nbsp;&nbsp; #ifdef CONFIG_NUMA</div>=0A<div>&gt;&nb=
sp; &gt;&gt;&gt;&nbsp;&nbsp; int __weak of_node_to_nid(struct device_node =
*np)</div>=0A<div>&gt;&nbsp; &gt;&gt;&gt;&nbsp;&nbsp; {</div>=0A<div>&gt;&=
nbsp; &gt;&gt;&gt; -&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return numa_node_=
id();</div>=0A<div>&gt;&nbsp; &gt;&gt;&gt; +&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp; return NUMA_NO_NODE;</div>=0A<div>&gt;&nbsp; &gt;&gt;</div>=0A<div>=
&gt;&nbsp; &gt;&gt;</div>=0A<div>&gt;&nbsp; &gt;&gt; This is going to brea=
k any NUMA machine that enables OF and expects</div>=0A<div>&gt;&nbsp; &gt=
;&gt; the weak function to work.</div>=0A<div>&gt;&nbsp; &gt;</div>=0A<div=
>&gt;&nbsp; &gt;</div>=0A<div>&gt;&nbsp; &gt; Why? NUMA_NO_NODE =3D=3D -1 =
-- this's standard "no-affinity" signal.</div>=0A<div>&gt;&nbsp; &gt; As I=
 see powerpc/sparc versions of of_node_to_nid returns -1 if they</div>=0A<=
div>&gt;&nbsp; &gt; cannot find out which node should be used.</div>=0A<di=
v>&gt; Ah, I was thinking those platforms were relying on the default</div=
>=0A<div>&gt; implementation. I guess any real NUMA support is going to ne=
ed to</div>=0A<div>&gt; override this function. The arm64 patch series doe=
s that as well. We</div>=0A<div>&gt; need to be sure this change is correc=
t for metag which appears to be</div>=0A<div>&gt; the only other OF enable=
d platform with NUMA support.</div>=0A<div>&gt; In that case, then there i=
s little reason to keep the inline and we</div>=0A<div>&gt; can just alway=
s enable the weak function (with your change). It is</div>=0A<div>&gt; sli=
ghtly less optimal, but the few callers hardly appear to be hot</div>=0A<d=
iv>&gt; paths.</div>=0A<div>&gt; Rob</div>=0A<div>&gt; --</div>=0A<div>&gt=
; To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in</div>=0A<div>&gt; the body of a message to majordomo@vger.kernel.org</d=
iv>=0A<div>&gt; More majordomo info at http://vger.kernel.org/majordomo-in=
fo.html</div>=0A<div>&gt; Please read the FAQ at&nbsp; http://www.tux.org/=
lkml/</div>=0A<div>&nbsp;</div>=0A<div>&nbsp;</div>=0A<div>-- </div>=0A<di=
v>Konstantin</div>=0A</div></blockquote>=0A</body></html>
------=_001_NextPart506071301544_=------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
