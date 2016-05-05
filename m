Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 32D366B025F
	for <linux-mm@kvack.org>; Thu,  5 May 2016 17:45:10 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id gw7so132371165pac.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 14:45:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 124si13194285pfd.109.2016.05.05.14.45.08
        for <linux-mm@kvack.org>;
        Thu, 05 May 2016 14:45:09 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
Date: Thu, 5 May 2016 21:45:07 +0000
Message-ID: <1462484695.29294.7.camel@intel.com>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
	 <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
	 <5727753F.6090104@plexistor.com> <20160505142433.GA4557@infradead.org>
	 <CAPcyv4gdmo5m=Arf5sp5izJfNaaAkaaMbOzud8KRcBEC8RRu1Q@mail.gmail.com>
	 <20160505152230.GA3994@infradead.org>
In-Reply-To: <20160505152230.GA3994@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <70E6DC278A3EE74D9541D62DE6070F32@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>, "hch@infradead.org" <hch@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>, "matthew@wil.cx" <matthew@wil.cx>

T24gVGh1LCAyMDE2LTA1LTA1IGF0IDA4OjIyIC0wNzAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gT24gVGh1LCBNYXkgMDUsIDIwMTYgYXQgMDg6MTU6MzJBTSAtMDcwMCwgRGFuIFdpbGxp
YW1zIHdyb3RlOg0KPiA+IA0KPiA+ID4gDQo+ID4gPiBBZ3JlZWQgLSBtYWtpZyBPX0RJUkVDVCBs
ZXNzIGRpcmVjdCB0aGFuIG5vdCBoYXZpbmcgaXQgaXMgcGxhaW4NCj4gPiA+IHN0dXBpZCwNCj4g
PiA+IGFuZCBJIHNvbWVob3cgbWlzc2VkIHRoaXMgaW5pdGlhbGx5Lg0KPiA+IE9mIGNvdXJzZSBJ
IGRpc2FncmVlIGJlY2F1c2UgbGlrZSBEYXZlIGFyZ3VlcyBpbiB0aGUgbXN5bmMgY2FzZSB3ZQ0K
PiA+IHNob3VsZCBkbyB0aGUgY29ycmVjdCB0aGluZyBmaXJzdCBhbmQgbWFrZSBpdCBmYXN0IGxh
dGVyLCBidXQgYWxzbw0KPiA+IGxpa2UgRGF2ZSB0aGlzIGFyZ3VpbmcgaW4gY2lyY2xlcyBpcyBn
ZXR0aW5nIHRpcmVzb21lLg0KPiBXZSBzaG91bGQgZG8gdGhlIHJpZ2h0IHRoaW5nIGZpcnN0LCBh
bmQgbWFrZSBpdCBmYXN0IGxhdGVyLsKgwqBCdXQgdGhpcw0KPiBwcm9wb3NhbCBpcyBub3QgZ2V0
dGluZyBpdCByaWdodCAtIGl0IHN0aWxsIGRvZXMgbm90IGhhbmRsZSBlcnJvcnMNCj4gZm9yIHRo
ZSBmYXN0IHBhdGgsIGJ1dCBtYWdpY2FsbHkgbWFrZXMgaXQgd29yayBmb3IgZGlyZWN0IEkvTyBi
eQ0KPiBpbiBnZW5lcmFsIHVzaW5nIGEgbGVzcyBvcHRpb25hbCBwYXRoIGZvciBPX0RJUkVDVC7C
oMKgSXQncyBnZXR0aW5nIHRoZQ0KPiB3b3JzdCBvZiBhbGwgY2hvaWNlcy4NCj4gDQo+IEFzIGZh
ciBhcyBJIGNhbiB0ZWxsIHRoZSBvbmx5IHNlbnNpYmxlIG9wdGlvbiBpcyB0bzoNCj4gDQo+IMKg
LSBhbHdheXMgdHJ5IGRheC1saWtlIEkvTyBmaXJzdA0KPiDCoC0gaGF2ZSBhIGN1c3RvbSBnZXRf
dXNlcl9wYWdlcyArIHJ3X2J5dGVzIGZhbGxiYWNrIGhhbmRsZXMgYmFkIGJsb2Nrcw0KPiDCoMKg
wqB3aGVuIGhpdHRpbmcgRUlPDQoNCkknbSBub3Qgc3VyZSBJIGNvbXBsZXRlbHkgdW5kZXJzdGFu
ZCBob3cgdGhpcyB3aWxsIHdvcms/IENhbiB5b3UgZXhwbGFpbg0KYSBiaXQ/IFdvdWxkIHdlIGhh
dmUgdG8gZXhwb3J0IHJ3X2J5dGVzIHVwIHRvIGxheWVycyBhYm92ZSB0aGUgcG1lbQ0KZHJpdmVy
PyBXaGVyZSBkb2VzIGdldF91c2VyX3BhZ2VzIGNvbWUgaW4/DQoNCj4gDQo+IEFuZCB0aGVuIHdl
IG5lZWQgdG8gc29ydCBvdXQgdGhlIGNvbmN1cnJlbnQgd3JpdGUgc3luY2hyb25pemF0aW9uLg0K
PiBBZ2FpbiB0aGVyZSBJIHRoaW5rIHdlIGFic29sdXRlbHkgaGF2ZSB0byBvYmV5IFBvc2l4IGZv
ciB0aGUgIU9fRElSRUNUDQo+IGNhc2UgYW5kIGNhbiBhdm9pZCBpdCBmb3IgT19ESVJFQ1QsIHNp
bWlsYXIgdG8gdGhlIGV4aXN0aW5nIG5vbi1EQVgNCj4gc2VtYW50aWNzLsKgwqBJZiB3ZSB3YW50
IGFueSBzcGVjaWFsIGFkZGl0aW9uYWwgc2VtYW50aWNzIHdlIF93aWxsXyBuZWVkDQo+IGEgc3Bl
Y2lhbCBPX0RBWCBmbGFnLg0KPiBfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fXw0KPiBMaW51eC1udmRpbW0gbWFpbGluZyBsaXN0DQo+IExpbnV4LW52ZGltbUBs
aXN0cy4wMS5vcmcNCj4gaHR0cHM6Ly9saXN0cy4wMS5vcmcvbWFpbG1hbi9saXN0aW5mby9saW51
eC1udmRpbW0=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
