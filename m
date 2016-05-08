Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 45E9C6B0005
	for <linux-mm@kvack.org>; Sun,  8 May 2016 14:46:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 4so339537863pfw.0
        for <linux-mm@kvack.org>; Sun, 08 May 2016 11:46:23 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 192si32449902pfz.229.2016.05.08.11.46.22
        for <linux-mm@kvack.org>;
        Sun, 08 May 2016 11:46:22 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH v5 3/5] dax: use sb_issue_zerout instead of calling
 dax_clear_sectors
Date: Sun, 8 May 2016 18:46:13 +0000
Message-ID: <1462733173.3006.7.camel@intel.com>
References: <1462571591-3361-1-git-send-email-vishal.l.verma@intel.com>
	 <1462571591-3361-4-git-send-email-vishal.l.verma@intel.com>
	 <20160508085203.GA10160@infradead.org>
In-Reply-To: <20160508085203.GA10160@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <D60809FA56FCC54089DF6F708EA1BE89@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@infradead.org" <hch@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "jmoyer@redhat.com" <jmoyer@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "boaz@plexistor.com" <boaz@plexistor.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gU3VuLCAyMDE2LTA1LTA4IGF0IDAxOjUyIC0wNzAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gT24gRnJpLCBNYXkgMDYsIDIwMTYgYXQgMDM6NTM6MDlQTSAtMDYwMCwgVmlzaGFsIFZl
cm1hIHdyb3RlOg0KPiA+IA0KPiA+IEZyb206IE1hdHRoZXcgV2lsY294IDxtYXR0aGV3LnIud2ls
Y294QGludGVsLmNvbT4NCj4gPiANCj4gPiBkYXhfY2xlYXJfc2VjdG9ycygpIGNhbm5vdCBoYW5k
bGUgcG9pc29uZWQgYmxvY2tzLsKgwqBUaGVzZSBtdXN0IGJlDQo+ID4gemVyb2VkIHVzaW5nIHRo
ZSBCSU8gaW50ZXJmYWNlIGluc3RlYWQuwqDCoENvbnZlcnQgZXh0MiBhbmQgWEZTIHRvDQo+ID4g
dXNlDQo+ID4gb25seSBzYl9pc3N1ZV96ZXJvdXQoKS4NCj4gPiANCj4gPiBTaWduZWQtb2ZmLWJ5
OiBNYXR0aGV3IFdpbGNveCA8bWF0dGhldy5yLndpbGNveEBpbnRlbC5jb20+DQo+ID4gW3Zpc2hh
bDogQWxzbyByZW1vdmUgdGhlIGRheF9jbGVhcl9zZWN0b3JzIGZ1bmN0aW9uIGVudGlyZWx5XQ0K
PiA+IFNpZ25lZC1vZmYtYnk6IFZpc2hhbCBWZXJtYSA8dmlzaGFsLmwudmVybWFAaW50ZWwuY29t
Pg0KPiBKdXN0IHRvIG1ha2Ugc3VyZTrCoMKgdGhlIGV4aXN0aW5nIHNiX2lzc3VlX3plcm91dCBh
cyBpbiA0LjYtcmMNCj4gaXMgYWxyZWFkeSBkb2luZyB0aGUgcmlnaHQgdGhpbmcgZm9yIERBWD/C
oMKgSSd2ZSBnb3QgYSBwZW5kaW5nDQo+IHBhdGNoc2V0DQo+IGZvciBYRlMgdGhhdCBpbnRyb2R1
Y2VzIGFub3RoZXIgZGF4X2NsZWFyX3NlY3RvcnMgdXNlcnMsIGJ1dCBpZiBpdCdzDQo+IGFscmVh
ZHkgc2FmZSB0byB1c2UgYmxrZGV2X2lzc3VlX3plcm9vdXQgSSBjYW4gc3dpdGNoIHRvIHRoYXQg
YW5kDQo+IGF2b2lkDQo+IHRoZSBtZXJnZSBjb25mbGljdC4NCg0KSSBiZWxpZXZlIHNvIC0gSmFu
IGhhcyBtb3ZlZCBhbGwgdW53cml0dGVuIGV4dGVudCBjb252ZXJzaW9ucyBvdXQgb2YNCkRBWCB3
aXRoIGhpcyBwYXRjaCBzZXQsIGFuZCBJIGJlbGlldmUgemVyb2luZyB0aHJvdWdoIHRoZSBkcml2
ZXIgaXMNCmFsd2F5cyBmaW5lLiBSb3NzIG9yIEphbiBjb3VsZCBjb25maXJtIHRob3VnaC7CoA==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
