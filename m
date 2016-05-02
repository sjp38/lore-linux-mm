Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFE6B6B025E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 19:17:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so6406919pfy.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 16:17:24 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id s16si590956pfi.193.2016.05.02.16.17.23
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 16:17:23 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Date: Mon, 2 May 2016 23:17:21 +0000
Message-ID: <1462231029.1421.82.camel@intel.com>
References: <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	 <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	 <20160420205923.GA24797@infradead.org> <1461434916.3695.7.camel@intel.com>
	 <20160425083114.GA27556@infradead.org> <1461604476.3106.12.camel@intel.com>
	 <20160425232552.GD18496@dastard> <1461628381.1421.24.camel@intel.com>
	 <20160426004155.GF18496@dastard>
	 <x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
	 <20160502230422.GQ26977@dastard>
In-Reply-To: <20160502230422.GQ26977@dastard>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <DD7A3CDBB5E097499F162D3957B8E7B4@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "david@fromorbit.com" <david@fromorbit.com>, "jmoyer@redhat.com" <jmoyer@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "Williams, Dan J" <dan.j.williams@intel.com>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew
 R" <matthew.r.wilcox@intel.com>, "jack@suse.cz" <jack@suse.cz>

T24gVHVlLCAyMDE2LTA1LTAzIGF0IDA5OjA0ICsxMDAwLCBEYXZlIENoaW5uZXIgd3JvdGU6DQo+
IE9uIE1vbiwgTWF5IDAyLCAyMDE2IGF0IDExOjE4OjM2QU0gLTA0MDAsIEplZmYgTW95ZXIgd3Jv
dGU6DQo+ID4gDQo+ID4gRGF2ZSBDaGlubmVyIDxkYXZpZEBmcm9tb3JiaXQuY29tPiB3cml0ZXM6
DQo+ID4gDQo+ID4gPiANCj4gPiA+IE9uIE1vbiwgQXByIDI1LCAyMDE2IGF0IDExOjUzOjEzUE0g
KzAwMDAsIFZlcm1hLCBWaXNoYWwgTCB3cm90ZToNCj4gPiA+ID4gDQo+ID4gPiA+IE9uIFR1ZSwg
MjAxNi0wNC0yNiBhdCAwOToyNSArMTAwMCwgRGF2ZSBDaGlubmVyIHdyb3RlOg0KPiA+ID4gWW91
J3JlIGFzc3VtaW5nIHRoYXQgb25seSB0aGUgREFYIGF3YXJlIGFwcGxpY2F0aW9uIGFjY2Vzc2Vz
IGl0J3MNCj4gPiA+IGZpbGVzLsKgwqB1c2VycywgYmFja3VwIHByb2dyYW1zLCBkYXRhIHJlcGxp
Y2F0b3JzLCBmaWxleXN0ZW0NCj4gPiA+IHJlLW9yZ2FuaXNlcnMgKGUuZy7CoMKgZGVmcmFnbWVu
dGVycykgZXRjIGFsbCBtYXkgYWNjZXNzIHRoZSBmaWxlcw0KPiA+ID4gYW5kDQo+ID4gPiB0aGV5
IG1heSB0aHJvdyBlcnJvcnMuIFdoYXQgdGhlbj8NCj4gPiBJJ20gbm90IHN1cmUgaG93IHRoaXMg
aXMgYW55IGRpZmZlcmVudCBmcm9tIHJlZ3VsYXIgc3RvcmFnZS7CoMKgSWYgYW4NCj4gPiBhcHBs
aWNhdGlvbiBnZXRzIEVJTywgaXQncyB1cCB0byB0aGUgYXBwIHRvIGRlY2lkZSB3aGF0IHRvIGRv
IHdpdGgNCj4gPiB0aGF0Lg0KPiBTdXJlIC0gdGhleSdsbCBmYWlsLiBCdXQgdGhlIHF1ZXN0aW9u
IEknbSBhc2tpbmcgaXMgdGhhdCBpZiB0aGUNCj4gYXBwbGljYXRpb24gdGhhdCBvd25zIHRoZSBk
YXRhIGlzIHN1cHBvc2VkIHRvIGRvIGVycm9yIHJlY292ZXJ5LA0KPiB3aGF0IGhhcHBlbnMgd2hl
biBhIDNyZCBwYXJ0eSBhcHBsaWNhdGlvbiBoaXRzIGFuIGVycm9yPyBJZiB0aGF0DQo+IGNvbnN1
bWVzIHRoZSBlcnJvciwgdGhlIHRoZSBhcHAgdGhhdCBvd25zIHRoZSBkYXRhIHdvbid0IGV2ZXIg
Z2V0IGENCj4gY2hhbmNlIHRvIGNvcnJlY3QgdGhlIGVycm9yLg0KPiANCj4gVGhpcyBpcyBhIG1p
bmVmaWVsZCAtIGEgM3JkIHBhcnR5IGFwcCB0aGF0IHN3YWxsb3dzIGFuZCBjbGVhcnMgREFYDQo+
IGJhc2VkIElPIGVycm9ycyBpcyBhIGRhdGEgY29ycnVwdGlvbiB2ZWN0b3IuIGNhbiB5byBpbWFn
aW5lIGlmDQo+ICpncmVwKiBkaWQgdGhpcz8gVGhlIG1vZGVsIHRoYXQgaXMgYmVpbmcgcHJvbW90
ZWQgaGVyZSBlZmZlY3RpdmVseQ0KPiBhbGxvd3MgdGhpcyBzb3J0IG9mIGJlaGF2aW91ciAtIEkg
ZG9uJ3QgcmVhbGx5IHRoaW5rIHdlDQo+IHNob3VsZCBiZSBhcmNoaXRlY3RpbmcgYW4gZXJyb3Ig
cmVjb3Zlcnkgc3RyYXRlZ3kgdGhhdCBoYXMgdGhlDQo+IGNhcGFiaWxpdHkgdG8gZ28gdGhpcyB3
cm9uZy4uLi4NCj4gDQoNCkp1c3QgdG8gYWRkcmVzcyB0aGlzIGJpdCAtIE5vLiBBbnkgbnVtYmVy
IG9mIGJhY2t1cC8zcmQgcGFydHkNCmFwcGxpY2F0aW9uIGNhbiBoaXQgdGhlIGVycm9yIGFuZCBf
ZmFpbF8gYnV0IHN1cmVseSB0aGV5IHdvbid0IHRyeSB0bw0KX3dyaXRlXyB0aGUgYmFkIGxvY2F0
aW9uPyBPbmx5IGEgd3JpdGUgdG8gdGhlIGJhZCBzZWN0b3Igd2lsbCBjbGVhciBpdA0KaW4gdGhp
cyBtb2RlbCAtIGFuZCB1bnRpbCBzdWNoIHRpbWUsIGFsbCByZWFkcyB3aWxsIGp1c3Qga2VlcCBl
cnJvcmluZw0Kb3V0LiBUaGlzIHdvcmtzIGZvciBEQVgvbW1hcCBiYXNlZCByZWFkcy93cml0ZXMg
dG9vIC0gbW1hcC1zdG9yZXMNCndvbid0L2Nhbid0IGNsZWFyIGVycm9ycyAtIHlvdSBoYXZlIHRv
IGdvIHRocm91Z2ggdGhlIGJsb2NrIHBhdGgsIGFuZCBpbg0KdGhlIGFsdGVzdCB2ZXJzaW9uIG9m
IG15IHBhdGNoIHNldCwgdGhhdCBoYXMgdG8gYmUgZXhwbGljaXRseSB0aHJvdWdoDQpPX0RJUkVD
VC4=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
