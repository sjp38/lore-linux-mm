Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id AFA996B007E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 16:59:33 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id td3so52859912pab.2
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 13:59:33 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id u67si21873539pfa.243.2016.03.25.13.59.32
        for <linux-mm@kvack.org>;
        Fri, 25 Mar 2016 13:59:32 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH 5/5] dax: handle media errors in dax_do_io
Date: Fri, 25 Mar 2016 20:59:30 +0000
Message-ID: <1458939566.5501.5.camel@intel.com>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
	 <1458861450-17705-6-git-send-email-vishal.l.verma@intel.com>
	 <20160325104549.GB10525@infradead.org>
In-Reply-To: <20160325104549.GB10525@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <21B546D71D01A9489F096D2F38A6C68A@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@infradead.org" <hch@infradead.org>
Cc: "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "Williams, Dan J" <dan.j.williams@intel.com>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew
 R" <matthew.r.wilcox@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gRnJpLCAyMDE2LTAzLTI1IGF0IDAzOjQ1IC0wNzAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gT24gVGh1LCBNYXIgMjQsIDIwMTYgYXQgMDU6MTc6MzBQTSAtMDYwMCwgVmlzaGFsIFZl
cm1hIHdyb3RlOg0KPiA+IA0KPiA+IGRheF9kb19pbyAoY2FsbGVkIGZvciByZWFkKCkgb3Igd3Jp
dGUoKSBmb3IgYSBkYXggZmlsZSBzeXN0ZW0pIG1heQ0KPiA+IGZhaWwNCj4gPiBpbiB0aGUgcHJl
c2VuY2Ugb2YgYmFkIGJsb2NrcyBvciBtZWRpYSBlcnJvcnMuIFNpbmNlIHdlIGV4cGVjdCB0aGF0
DQo+ID4gYQ0KPiA+IHdyaXRlIHNob3VsZCBjbGVhciBtZWRpYSBlcnJvcnMgb24gbnZkaW1tcywg
bWFrZSBkYXhfZG9faW8gZmFsbA0KPiA+IGJhY2sgdG8NCj4gPiB0aGUgZGlyZWN0X0lPIHBhdGgs
IHdoaWNoIHdpbGwgc2VuZCBkb3duIGEgYmlvIHRvIHRoZSBkcml2ZXIsIHdoaWNoDQo+ID4gY2Fu
DQo+ID4gdGhlbiBhdHRlbXB0IHRvIGNsZWFyIHRoZSBlcnJvci4NCj4gTGVhdmUgdGhlIGZhbGxi
YWNrIG9uIC1FSU8gdG8gdGhlIGNhbGxlcnMgcGxlYXNlLsKgwqBUaGV5IGdlbmVyYWxseQ0KPiBj
YWxsDQo+IF9fYmxvY2tkZXZfZGlyZWN0X0lPIGFueXdheSwgc28gaXQgc2hvdWxkIGFjdHVhbGx5
IGJlY29tZSBzaW1wbGVyDQo+IHRoYXQNCj4gd2F5Lg0KDQpJIHRob3VnaHQgb2YgdGhpcywgYnV0
IG1hZGUgdGhlIHJldHJ5aW5nIGhhcHBlbiBpbiB0aGUgd3JhcHBlciBzbyB0aGF0DQppdCBjYW4g
YmUgY2VudHJhbGl6ZWQuIElmIHRoZSBjYWxsZXJzIHdlcmUgdG8gYmVjb21lIHJlc3BvbnNpYmxl
IGZvcg0KdGhlIHJldHJ5LCB0aGVuIGFueSBuZXcgY2FsbGVycyBvZiBkYXhfZG9faW8gbWlnaHQg
bm90IHJlYWxpemUgdGhleSBhcmUNCnJlc3BvbnNpYmxlIGZvciByZXRyeWluZywgYW5kIGhpdCBw
cm9ibGVtcy4gQW5vdGhlciB0cmlja3kgcG9pbnQgbWlnaHQNCmJlOiBpbiB0aGUgd3JhcHBlciwg
aWYgX19kYXhfZG9faW8gZmFpbGVkIHdpdGggLUVJTywgYW5kIHN1YnNlcXVlbnRseQ0KX19ibG9j
a2Rldl9kaXJlY3RfSU8gYWxzbyBmYWlscyB3aXRoIGEgKmRpZmZlcmVudCogZXJyb3IsIEkgY2hv
c2UgdG8NCnJldHVybiAtRUlPIGJlY2F1c2UgdGhhdCB3YXMgdGhlICdmaXJzdCcgZXJyb3Igd2Ug
aGl0IGFuZCBjYXVzZWQgdXMgdG8NCmZhbGxiYWNrLi4gKERvZXMgdGhpcyBldmVuIHNlZW0gcmVh
c29uYWJsZT8pIEFuZCBpZiBzbywgZG8gd2Ugd2FudCB0bw0KcHVzaCBiYWNrIHRoaXMgZGVjaXNp
b24gdG9vLCB0byB0aGUgY2FsbGVycz8=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
