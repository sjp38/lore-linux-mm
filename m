Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B12C8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 13:47:04 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id q207so1029443iod.18
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 10:47:04 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-eopbgr750078.outbound.protection.outlook.com. [40.107.75.78])
        by mx.google.com with ESMTPS id g7si11062078jac.44.2019.01.07.10.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 10:47:03 -0800 (PST)
From: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Date: Mon, 7 Jan 2019 18:46:55 +0000
Message-ID: <e1ced25f-4f35-320b-5208-7e1ca3565a3a@amd.com>
References: 
 <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com>
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com>
 <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPCACOhOo4DTCiOam65SiOiudrKpn5vKAL72bV6iGo9vA@mail.gmail.com>
 <CABXGCsMMSMJuURyhBQC3GuZc7m6Wq7FH=8_rpSWHrZT-0dJeGA@mail.gmail.com>
In-Reply-To: 
 <CABXGCsMMSMJuURyhBQC3GuZc7m6Wq7FH=8_rpSWHrZT-0dJeGA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <1BC47199C490154A8E4EA6650FE5E08D@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

SSBzZWUgJ25vIGFjdGl2ZSB3YXZlcycgcHJpbnQgbWVhbmluZyBpdCdzIG5vdCBzaGFkZXIgaGFu
Zy4NCg0KV2UgY2FuIHRyeSBhbmQgZXN0aW1hdGUgYXJvdW5kIHdoaWNoIGNvbW1hbmRzIHRoZSBo
YW5nIG9jY3VycmVkIC0gaW4gDQphZGRpdGlvbiB0byB3aGF0IHlvdSBhbHJlYWR5IHByaW50IHBs
ZWFzZSBhbHNvIGR1bXANCg0Kc3VkbyB1bXIgLU8gbWFueSxiaXRzwqAgLXIgKi4qLm1tR1JCTV9T
VEFUVVMqICYmIHN1ZG8gdW1yIC1PIG1hbnksYml0c8KgIA0KLXIgKi4qLm1tQ1BfRU9QXyogJiYg
c3VkbyB1bXIgLU8gbWFueSxiaXRzIC1yICouKi5tbUNQX1BGUF9IRUFERVJfRFVNUCANCiYmIHN1
ZG8gdW1yIC1PIG1hbnksYml0c8KgIC1yICouKi5tbUNQX01FX0hFQURFUl9EVU1QDQoNCkFuZHJl
eQ0KDQoNCk9uIDAxLzA0LzIwMTkgMTI6NTAgUE0sIE1pa2hhaWwgR2F2cmlsb3Ygd3JvdGU6DQo+
IE9uIEZyaSwgNCBKYW4gMjAxOSBhdCAwMToyMywgTWlraGFpbCBHYXZyaWxvdg0KPiA8bWlraGFp
bC52LmdhdnJpbG92QGdtYWlsLmNvbT4gd3JvdGU6DQo+PiBPbiBUdWUsIDE4IERlYyAyMDE4IGF0
IDAwOjA4LCBHcm9kem92c2t5LCBBbmRyZXkNCj4+IDxBbmRyZXkuR3JvZHpvdnNreUBhbWQuY29t
PiB3cm90ZToNCj4+PiBQbGVhc2UgaW5zdGFsbCBVTVIgYW5kIGR1bXAgZ2Z4IHJpbmcgY29udGVu
dCBhbmQgd2F2ZXMgYWZ0ZXIgdGhlIGhhbmcgaXMNCj4+PiBoYXBwZW5pbmcuDQo+Pj4NCj4+IFRv
ZGF5IEkgY2F1Z2h0IGhhbmcgYWdhaW4gYW5kIGFibGUgZHVtcCBnZnggcmluZyBjb250ZW50Lg0K
Pj4gQW5kcmV5LCBjYW4geW91IGxvb2sgbXkgZHVtcHM/DQo+Pg0KPiBBbmQgSSBhbSBjYXRjaCB5
ZXQgYW5vdGhlciBoYW5nLg0KPiBPZiBjb3Vyc2UgSSBkdW1wZWQgYWxsIG5lZWRlZCBnZnggcmlu
ZyBjb250ZW50IGluIGF0dGFjaG1lbnQuDQo+DQo+IC0tDQo+IEJlc3QgUmVnYXJkcywNCj4gTWlr
ZSBHYXZyaWxvdi4NCg0K
