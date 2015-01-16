Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 387EF6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 21:05:55 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id hn15so1193013igb.3
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 18:05:55 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id e3si806489igx.29.2015.01.15.18.05.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 18:05:54 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 16 Jan 2015 09:42:23 +0800
Subject: RE: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103EDAF89E1B0@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
 <20141113235322.GC4042@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103E010D1829B@CNBJMBX05.corpusers.net>
 <20141114095812.GG4042@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103E688B313C6@CNBJMBX05.corpusers.net>
 <20150108184059.GZ12302@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103EDAF89E195@CNBJMBX05.corpusers.net>
 <20150109111048.GE12302@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103EDAF89E198@CNBJMBX05.corpusers.net>
 <20150114163800.GZ12302@n2100.arm.linux.org.uk>
In-Reply-To: <20150114163800.GZ12302@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Joe Perches' <joe@perches.com>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBSdXNzZWxsIEtpbmcgLSBBUk0g
TGludXggW21haWx0bzpsaW51eEBhcm0ubGludXgub3JnLnVrXQ0KPiBTZW50OiBUaHVyc2RheSwg
SmFudWFyeSAxNSwgMjAxNSAxMjozOCBBTQ0KPiBUbzogV2FuZywgWWFsaW4NCj4gQ2M6ICdBcmQg
Qmllc2hldXZlbCc7ICdXaWxsIERlYWNvbic7ICdsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3Jn
JzsNCj4gJ2FraW5vYnUubWl0YUBnbWFpbC5jb20nOyAnbGludXgtbW1Aa3ZhY2sub3JnJzsgJ0pv
ZSBQZXJjaGVzJzsgJ2xpbnV4LWFybS0NCj4ga2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmcnDQo+
IFN1YmplY3Q6IFJlOiBbUkZDIFY2IDIvM10gYXJtOmFkZCBiaXRyZXYuaCBmaWxlIHRvIHN1cHBv
cnQgcmJpdCBpbnN0cnVjdGlvbg0KPiANCj4gT24gRnJpLCBKYW4gMDksIDIwMTUgYXQgMDg6NDA6
NTZQTSArMDgwMCwgV2FuZywgWWFsaW4gd3JvdGU6DQo+ID4gT2gsIEkgc2VlLA0KPiA+IEhvdyBh
Ym91dCBjaGFuZ2UgbGlrZSB0aGlzOg0KPiA+ICsJc2VsZWN0IEhBVkVfQVJDSF9CSVRSRVZFUlNF
IGlmICgoQ1BVX1Y3TSB8fCBDUFVfVjcpICYmICFDUFVfVjYgJiYNCj4gPiArIUNQVV9WNkspDQo+
ID4gSSBhbSBub3Qgc3VyZSBpZiBJIGFsc28gbmVlZCBhZGQgc29tZSBvbGRlciBDUFUgdHlwZXMg
bGlrZSAhQ1BVX0FSTTlURE1JDQo+ICYm44CAIUNQVV9BUk05NDBUID8NCj4gPg0KPiA+IEFub3Ro
ZXIgc29sdXRpb24gaXM6DQo+ID4gKwlzZWxlY3QgSEFWRV9BUkNIX0JJVFJFVkVSU0UgaWYgKChD
UFVfMzJWN00gfHwgQ1BVXzMyVjcpICYmICFDUFVfMzJWNg0KPiA+ICsmJiAhQ1BVXzMyVjUgJiYg
IUNQVV8zMlY0ICYmICFDUFVfMzJWNFQgJiYgIUNQVV8zMlYzKQ0KPiA+DQo+ID4gQnkgdGhlIHdh
eSwgSSBhbSBub3QgY2xlYXIgYWJvdXQgdGhlIGRpZmZlcmVuY2UgYmV0d2VlbiBDUFVfVjYgYW5k
DQo+ID4gQ1BVX1Y2SywgY291bGQgeW91IHRlbGwgbWU/IDopDQo+IA0KPiBJIHRoaW5rDQo+IA0K
PiAJc2VsZWN0IEhBVkVfQVJDSF9CSVRSRVZFUlNFIGlmIChDUFVfMzJ2N00gfHwgQ1BVXzMydjcp
ICYmICFDUFVfMzJ2Ng0KPiANCj4gaXMgc3VmZmljaWVudCAtIHdlIGRvbid0IHN1cHBvcnQgbWl4
aW5nIHByZS12NiBhbmQgdjYrIENQVSBhcmNoaXRlY3R1cmVzDQo+IGludG8gYSBzaW5nbGUga2Vy
bmVsLg0KPiANCk9rLCBJIHdpbGwgcmUtc2VuZCBhIHBhdGNoLiANCg0KVGhhbmtzDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
