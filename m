Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B18D6B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:26:27 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f5so329636878pgi.1
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 14:26:27 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0113.outbound.protection.outlook.com. [104.47.38.113])
        by mx.google.com with ESMTPS id v11si2486631plg.281.2017.01.26.14.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 14:26:26 -0800 (PST)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [PATCH 2/2] base/memory, hotplug: fix a kernel oops in
 show_valid_zones()
Date: Thu, 26 Jan 2017 22:26:23 +0000
Message-ID: <1485472910.2029.28.camel@hpe.com>
References: <20170126214415.4509-1-toshi.kani@hpe.com>
	 <20170126214415.4509-3-toshi.kani@hpe.com>
	 <20170126135254.cbd0bdbe3cdc5910c288ad32@linux-foundation.org>
In-Reply-To: <20170126135254.cbd0bdbe3cdc5910c288ad32@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <092889B8DAAF034D972DEB9F1620A498@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "zhenzhang.zhang@huawei.com" <zhenzhang.zhang@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "arbab@linux.vnet.ibm.com" <arbab@linux.vnet.ibm.com>, "abanman@sgi.com" <abanman@sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "rientjes@google.com" <rientjes@google.com>

T24gVGh1LCAyMDE3LTAxLTI2IGF0IDEzOjUyIC0wODAwLCBBbmRyZXcgTW9ydG9uIHdyb3RlOg0K
PiBPbiBUaHUsIDI2IEphbiAyMDE3IDE0OjQ0OjE1IC0wNzAwIFRvc2hpIEthbmkgPHRvc2hpLmth
bmlAaHBlLmNvbT4NCj4gd3JvdGU6DQo+IA0KPiA+IFJlYWRpbmcgYSBzeXNmcyBtZW1vcnlOL3Zh
bGlkX3pvbmVzIGZpbGUgbGVhZHMgdG8gdGhlIGZvbGxvd2luZw0KPiA+IG9vcHMgd2hlbiB0aGUg
Zmlyc3QgcGFnZSBvZiBhIHJhbmdlIGlzIG5vdCBiYWNrZWQgYnkgc3RydWN0IHBhZ2UuDQo+ID4g
c2hvd192YWxpZF96b25lcygpIGFzc3VtZXMgdGhhdCAnc3RhcnRfcGZuJyBpcyBhbHdheXMgdmFs
aWQgZm9yDQo+ID4gcGFnZV96b25lKCkuDQo+ID4gDQo+ID4gwqBCVUc6IHVuYWJsZSB0byBoYW5k
bGUga2VybmVsIHBhZ2luZyByZXF1ZXN0IGF0IGZmZmZlYTAxN2EwMDAwMDANCj4gPiDCoElQOiBz
aG93X3ZhbGlkX3pvbmVzKzB4NmYvMHgxNjANCj4gPiANCj4gPiBTaW5jZSB0ZXN0X3BhZ2VzX2lu
X2Ffem9uZSgpIGFscmVhZHkgY2hlY2tzIGhvbGVzLCBleHRlbmQgdGhpcw0KPiA+IGZ1bmN0aW9u
IHRvIHJldHVybiAndmFsaWRfc3RhcnQnIGFuZCAndmFsaWRfZW5kJyBmb3IgYSBnaXZlbiByYW5n
ZS4NCj4gPiBzaG93X3ZhbGlkX3pvbmVzKCkgdGhlbiBwcm9jZWVkcyB3aXRoIHRoZSB2YWxpZCBy
YW5nZS4NCj4gDQo+IFRoaXMgZG9lc24ndCBhcHBseSB0byBjdXJyZW50IG1haW5saW5lIGR1ZSB0
byBjaGFuZ2VzIGluDQo+IHpvbmVfY2FuX3NoaWZ0KCkuwqDCoFBsZWFzZSByZWRvIGFuZCByZXNl
bmQuDQoNClNvcnJ5LCBJIHdpbGwgcmViYXNlIHRvIHRoZSAtbW0gdHJlZSBhbmQgcmVzZW5kIHRo
ZSBwYXRjaGVzLg0KDQo+IFBsZWFzZSBhbHNvIHVwZGF0ZSB0aGUgY2hhbmdlbG9nIHRvIHByb3Zp
ZGUgc3VmZmljaWVudCBpbmZvcm1hdGlvbg0KPiBmb3Igb3RoZXJzIHRvIGRlY2lkZSB3aGljaCBr
ZXJuZWwocykgbmVlZCB0aGUgZml4LsKgwqBJbiBwYXJ0aWN1bGFyOg0KPiB1bmRlciB3aGF0IGNp
cmN1bXN0YW5jZXMgd2lsbCBpdCBvY2N1cj/CoMKgT24gcmVhbCBtYWNoaW5lcyB3aGljaCByZWFs
DQo+IHBlb3BsZSBvd24/DQoNClllcywgdGhpcyBpc3N1ZSBoYXBwZW5zIG9uIHJlYWwgeDg2IG1h
Y2hpbmVzIHdpdGggNjRHaUIgb3IgbW9yZSBtZW1vcnkuDQogT24gc3VjaCBzeXN0ZW1zLCB0aGUg
bWVtb3J5IGJsb2NrIHNpemUgaXMgYnVtcGVkIHVwIHRvIDJHaUIuIFsxXQ0KDQpIZXJlIGlzIGFu
IGV4YW1wbGUgc3lzdGVtLiAgMHgzMjQwMDAwMDAwIGlzIG9ubHkgYWxpZ25lZCBieSAxR2lCIGFu
ZA0KaXRzIG1lbW9yeSBibG9jayBzdGFydHMgZnJvbSAweDMyMDAwMDAwMDAsIHdoaWNoIGlzIG5v
dCBiYWNrZWQgYnkNCnN0cnVjdCBwYWdlLg0KDQrCoEJJT1MtZTgyMDogW21lbcKgMHgwMDAwMDAz
MjQwMDAwMDAwLTB4MDAwMDAwNjAzZmZmZmZmZl0gdXNhYmxlDQoNCkkgd2lsbCBhZGQgdGhlIGRl
c2NyaXB0aW9ucyB0byB0aGUgcGF0Y2guDQoNClsxXcKgaHR0cDovL2xrbWwuaXUuZWR1L2h5cGVy
bWFpbC9saW51eC9rZXJuZWwvMTQxMS4wLzAyMjg3Lmh0bWwNCg0KVGhhbmtzLA0KLVRvc2hpDQoN
Cg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
