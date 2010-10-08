Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4DA836B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 06:27:14 -0400 (EDT)
From: "Wu, Xia" <xia.wu@intel.com>
Date: Fri, 8 Oct 2010 18:27:08 +0800
Subject: RE: [PATCH] bdi: use deferable timer for sync_supers task
Message-ID: <A24AE1FFE7AEC5489F83450EE98351BF227AB58D51@shsmsx502.ccr.corp.intel.com>
References: <20101008083514.GA12402@ywang-moblin2.bj.intel.com>
	 <20101008092520.GB5426@lst.de>
	 <A24AE1FFE7AEC5489F83450EE98351BF227AB58D43@shsmsx502.ccr.corp.intel.com>
 <1286532586.2095.55.camel@localhost>
In-Reply-To: <1286532586.2095.55.camel@localhost>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Artem.Bityutskiy@nokia.com" <Artem.Bityutskiy@nokia.com>
Cc: Christoph Hellwig <hch@lst.de>, Yong Wang <yong.y.wang@linux.intel.com>, Jens Axboe <jaxboe@fusionio.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

DQo+IE9uIEZyaSwgMjAxMC0xMC0wOCBhdCAxMjowNCArMDIwMCwgZXh0IFd1LCBYaWEgd3JvdGU6
DQo+ID4gT24gRnJpLCBPY3QgMDgsIDIwMTAgYXQgMDQ6MzU6MTRQTSArMDgwMCwgWW9uZyBXYW5n
IHdyb3RlOg0KPiA+ID4gPiBzeW5jX3N1cGVycyB0YXNrIGN1cnJlbnRseSB3YWtlcyB1cCBwZXJp
b2RpY2FsbHkgZm9yIHN1cGVyYmxvY2sNCj4gPiA+ID4gd3JpdGViYWNrLiBUaGlzIGh1cnRzIHBv
d2VyIG9uIGJhdHRlcnkgZHJpdmVuIGRldmljZXMuIFRoaXMgcGF0Y2gNCj4gPiA+ID4gdHVybnMg
dGhpcyBob3VzZWtlZXBpbmcgdGltZXIgaW50byBhIGRlZmVyYWJsZSB0aW1lciBzbyB0aGF0IGl0
DQo+ID4gPiA+IGRvZXMgbm90IGZpcmUgd2hlbiBzeXN0ZW0gaXMgcmVhbGx5IGlkbGUuDQo+ID4N
Cj4gPiA+IEhvdyBsb25nIGNhbiB0aGUgdGltZXIgYmUgZGVmZXJlZWQ/ICBXZSBjYW4ndCBzaW1w
bHkgc3RvcCB3cml0aW5nDQo+ID4gPiBvdXQgZGF0YSBmb3IgYSBsb25nIHRpbWUuICBJIHRoaW5r
IHRoZSBjdXJyZW50IHRpbWVyIHZhbHVlIHNob3VsZCBiZQ0KPiA+ID4gdGhlIHVwcGVyIGJvdW5k
LCBidXQgYWxsb3dpbmcgdG8gZmlyZSBlYXJsaWVyIHRvIHJ1biBkdXJpbmcgdGhlDQo+ID4gPiBz
YW1lIHdha2V1cCBjeWNsZSBhcyBvdGhlcnMgaXMgZmluZS4NCj4gPg0KPiA+IElmIHRoZSBzeXN0
ZW0gaXMgaW4gc2xlZXAgc3RhdGUsIHRoaXMgdGltZXIgY2FuIGJlIGRlZmVycmVkIHRvIHRoZSBu
ZXh0IHdha2UtdXAgaW50ZXJydXB0Lg0KPiA+IElmIHRoZSBzeXN0ZW0gaXMgYnVzeSwgdGhpcyB0
aW1lciB3aWxsIGZpcmUgYXQgdGhlIHNjaGVkdWxlZCB0aW1lLg0KDQo+IEhvd2V2ZXIsIHdoZW4g
dGhlIG5leHQgd2FrZS11cCBpbnRlcnJ1cHQgaGFwcGVucyBpcyBub3QgZGVmaW5lZC4gSXQgY2Fu
DQo+IGhhcHBlbiAxbXMgYWZ0ZXIsIG9yIDEgbWludXRlIGFmdGVyLCBvciAxIGhvdXIgYWZ0ZXIu
IFdoYXQgQ2hyaXN0b3BoDQo+IHNheXMgaXMgdGhhdCB0aGVyZSBzaG91bGQgYmUgc29tZSBndWFy
YW50ZWUgdGhhdCBzYiB3cml0ZW91dCBzdGFydHMsDQo+IHNheSwgd2l0aGluIDUgdG8gMTAgc2Vj
b25kcyBpbnRlcnZhbC4gRGVmZXJyYWJsZSB0aW1lcnMgZG8gbm90IGd1YXJhbnRlZQ0KPiB0aGlz
LiBCdXQgdGFrZSBhIGxvb2sgYXQgdGhlIHJhbmdlIGhydGltZXJzIC0gdGhleSBkbyBleGFjdGx5
IHRoaXMuDQoNCklmIHRoZSBzeXN0ZW0gaXMgaW4gc2xlZXAgc3RhdGUsIGlzIHRoZXJlIGFueSBk
YXRhIHdoaWNoIHNob3VsZCBiZSB3cml0dGVuPyBNdXN0IA0Kc2Igd3JpdGVvdXQgc3RhcnQgZXZl
biB0aGVyZSBpc24ndCBhbnkgZGF0YT8gDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
