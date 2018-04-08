Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A76AD6B0005
	for <linux-mm@kvack.org>; Sun,  8 Apr 2018 12:41:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s21so3730707pfm.15
        for <linux-mm@kvack.org>; Sun, 08 Apr 2018 09:41:07 -0700 (PDT)
Received: from esa2.hgst.iphmx.com (esa2.hgst.iphmx.com. [68.232.143.124])
        by mx.google.com with ESMTPS id y70si10028374pgd.777.2018.04.08.09.41.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Apr 2018 09:41:04 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: Block layer use of __GFP flags
Date: Sun, 8 Apr 2018 16:40:59 +0000
Message-ID: <aea2f6bcae3fe2b88e020d6a258706af1ce1a58b.camel@wdc.com>
References: <20180408065425.GD16007@bombadil.infradead.org>
In-Reply-To: <20180408065425.GD16007@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <B33750FFC46826469D05ADEB5AE796DF@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hare@suse.com" <hare@suse.com>, "martin@lichtvoll.de" <martin@lichtvoll.de>, "oleksandr@natalenko.name" <oleksandr@natalenko.name>, "willy@infradead.org" <willy@infradead.org>, "axboe@kernel.dk" <axboe@kernel.dk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>

T24gU2F0LCAyMDE4LTA0LTA3IGF0IDIzOjU0IC0wNzAwLCBNYXR0aGV3IFdpbGNveCB3cm90ZToN
Cj4gUGxlYXNlIGV4cGxhaW46DQo+IA0KPiBjb21taXQgNmExNTY3NGQxZTkwOTE3ZjE3MjNhODE0
ZTJlOGM5NDkwMDA0NDBmNw0KPiBBdXRob3I6IEJhcnQgVmFuIEFzc2NoZSA8YmFydC52YW5hc3Nj
aGVAd2RjLmNvbT4NCj4gRGF0ZTogICBUaHUgTm92IDkgMTA6NDk6NTQgMjAxNyAtMDgwMA0KPiAN
Cj4gICAgIGJsb2NrOiBJbnRyb2R1Y2UgYmxrX2dldF9yZXF1ZXN0X2ZsYWdzKCkNCj4gICAgIA0K
PiAgICAgQSBzaWRlIGVmZmVjdCBvZiB0aGlzIHBhdGNoIGlzIHRoYXQgdGhlIEdGUCBtYXNrIHRo
YXQgaXMgcGFzc2VkIHRvDQo+ICAgICBzZXZlcmFsIGFsbG9jYXRpb24gZnVuY3Rpb25zIGluIHRo
ZSBsZWdhY3kgYmxvY2sgbGF5ZXIgaXMgY2hhbmdlZA0KPiAgICAgZnJvbSBHRlBfS0VSTkVMIGlu
dG8gX19HRlBfRElSRUNUX1JFQ0xBSU0uDQo+IA0KPiBXaHkgd2FzIHRoaXMgdGhvdWdodCB0byBi
ZSBhIGdvb2QgaWRlYT8gIEkgdGhpbmsgZ2ZwLmggaXMgcHJldHR5IGNsZWFyOg0KPiANCj4gICog
VXNlZnVsIEdGUCBmbGFnIGNvbWJpbmF0aW9ucyB0aGF0IGFyZSBjb21tb25seSB1c2VkLiBJdCBp
cyByZWNvbW1lbmRlZA0KPiAgKiB0aGF0IHN1YnN5c3RlbXMgc3RhcnQgd2l0aCBvbmUgb2YgdGhl
c2UgY29tYmluYXRpb25zIGFuZCB0aGVuIHNldC9jbGVhcg0KPiAgKiBfX0dGUF9GT08gZmxhZ3Mg
YXMgbmVjZXNzYXJ5Lg0KPiANCj4gSW5zdGVhZCwgdGhlIGJsb2NrIGxheWVyIG5vdyB0aHJvd3Mg
YXdheSBhbGwgYnV0IG9uZSBiaXQgb2YgdGhlDQo+IGluZm9ybWF0aW9uIGJlaW5nIHBhc3NlZCBp
biBieSB0aGUgY2FsbGVycywgYW5kIGFsbCBpdCB0ZWxscyB0aGUgYWxsb2NhdG9yDQo+IGlzIHdo
ZXRoZXIgb3Igbm90IGl0IGNhbiBzdGFydCBkb2luZyBkaXJlY3QgcmVjbGFpbS4gSSBjYW4gc2Vl
IHRoYXQNCj4geW91IG1heSB3ZWxsIGJlIGluIGEgc2l0dWF0aW9uIHdoZXJlIHlvdSBkb24ndCB3
YW50IHRvIHN0YXJ0IG1vcmUgSS9PLA0KPiBidXQgeW91ciBjYWxsZXIga25vd3MgdGhhdCEgIFdo
eSBtYWtlIHRoZSBhbGxvY2F0b3Igd29yayBoYXJkZXIgdGhhbg0KPiBpdCBoYXMgdG8/ICBJbiBw
YXJ0aWN1bGFyLCB3aHkgaXNuJ3QgdGhlIHBhZ2UgYWxsb2NhdG9yIGFsbG93ZWQgdG8gd2FrZQ0K
PiB1cCBrc3dhcGQgdG8gZG8gcmVjbGFpbSBpbiBub24tYXRvbWljIGNvbnRleHQsIGJ1dCBpcyB3
aGVuIHRoZSBjYWxsZXINCj4gaXMgaW4gYXRvbWljIGNvbnRleHQ/DQoNCl9fR0ZQX0tTV0FQRF9S
RUNMQUlNIHdhc24ndCBzdHJpcHBlZCBvZmYgb24gcHVycG9zZSBmb3Igbm9uLWF0b21pYw0KYWxs
b2NhdGlvbnMuIFRoYXQgd2FzIGFuIG92ZXJzaWdodC4gDQoNCkRvIHlvdSBwZXJoYXBzIHdhbnQg
bWUgdG8gcHJlcGFyZSBhIHBhdGNoIHRoYXQgbWFrZXMgYmxrX2dldF9yZXF1ZXN0KCkgYWdhaW4N
CnJlc3BlY3QgdGhlIGZ1bGwgZ2ZwIG1hc2sgcGFzc2VkIGFzIHRoaXJkIGFyZ3VtZW50IHRvIGJs
a19nZXRfcmVxdWVzdCgpPw0KDQpCYXJ0Lg0KDQoNCg0K
