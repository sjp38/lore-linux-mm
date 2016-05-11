Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id CF7F96B007E
	for <linux-mm@kvack.org>; Wed, 11 May 2016 13:47:04 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id gw7so71606413pac.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 10:47:04 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id q6si11244545paq.16.2016.05.11.10.47.03
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 10:47:03 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH v6 4/5] dax: for truncate/hole-punch, do zeroing through
 the driver if possible
Date: Wed, 11 May 2016 17:47:00 +0000
Message-ID: <1462988808.29294.26.camel@intel.com>
References: <1462906156-22303-1-git-send-email-vishal.l.verma@intel.com>
	 <1462906156-22303-5-git-send-email-vishal.l.verma@intel.com>
	 <20160511081532.GB14744@quack2.suse.cz>
In-Reply-To: <20160511081532.GB14744@quack2.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A1E995196763DE4E964EAE4A2FA3201C@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jack@suse.cz" <jack@suse.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "jmoyer@redhat.com" <jmoyer@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "boaz@plexistor.com" <boaz@plexistor.com>, "david@fromorbit.com" <david@fromorbit.com>

T24gV2VkLCAyMDE2LTA1LTExIGF0IDEwOjE1ICswMjAwLCBKYW4gS2FyYSB3cm90ZToNCj4gT24g
VHVlIDEwLTA1LTE2IDEyOjQ5OjE1LCBWaXNoYWwgVmVybWEgd3JvdGU6DQo+ID4gDQo+ID4gSW4g
dGhlIHRydW5jYXRlIG9yIGhvbGUtcHVuY2ggcGF0aCBpbiBkYXgsIHdlIGNsZWFyIG91dCBzdWIt
cGFnZQ0KPiA+IHJhbmdlcy4NCj4gPiBJZiB0aGVzZSBzdWItcGFnZSByYW5nZXMgYXJlIHNlY3Rv
ciBhbGlnbmVkIGFuZCBzaXplZCwgd2UgY2FuIGRvIHRoZQ0KPiA+IHplcm9pbmcgdGhyb3VnaCB0
aGUgZHJpdmVyIGluc3RlYWQgc28gdGhhdCBlcnJvci1jbGVhcmluZyBpcyBoYW5kbGVkDQo+ID4g
YXV0b21hdGljYWxseS4NCj4gPiANCj4gPiBGb3Igc3ViLXNlY3RvciByYW5nZXMsIHdlIHN0aWxs
IGhhdmUgdG8gcmVseSBvbiBjbGVhcl9wbWVtIGFuZCBoYXZlDQo+ID4gdGhlDQo+ID4gcG9zc2li
aWxpdHkgb2YgdHJpcHBpbmcgb3ZlciBlcnJvcnMuDQo+ID4gDQo+ID4gQ2M6IERhbiBXaWxsaWFt
cyA8ZGFuLmoud2lsbGlhbXNAaW50ZWwuY29tPg0KPiA+IENjOiBSb3NzIFp3aXNsZXIgPHJvc3Mu
endpc2xlckBsaW51eC5pbnRlbC5jb20+DQo+ID4gQ2M6IEplZmYgTW95ZXIgPGptb3llckByZWRo
YXQuY29tPg0KPiA+IENjOiBDaHJpc3RvcGggSGVsbHdpZyA8aGNoQGluZnJhZGVhZC5vcmc+DQo+
ID4gQ2M6IERhdmUgQ2hpbm5lciA8ZGF2aWRAZnJvbW9yYml0LmNvbT4NCj4gPiBDYzogSmFuIEth
cmEgPGphY2tAc3VzZS5jej4NCj4gPiBSZXZpZXdlZC1ieTogQ2hyaXN0b3BoIEhlbGx3aWcgPGhj
aEBsc3QuZGU+DQo+ID4gU2lnbmVkLW9mZi1ieTogVmlzaGFsIFZlcm1hIDx2aXNoYWwubC52ZXJt
YUBpbnRlbC5jb20+DQo+IC4uLg0KPiANCj4gPiANCj4gPiArc3RhdGljIGJvb2wgZGF4X3Jhbmdl
X2lzX2FsaWduZWQoc3RydWN0IGJsb2NrX2RldmljZSAqYmRldiwNCj4gPiArCQkJCcKgc3RydWN0
IGJsa19kYXhfY3RsICpkYXgsIHVuc2lnbmVkDQo+ID4gaW50IG9mZnNldCwNCj4gPiArCQkJCcKg
dW5zaWduZWQgaW50IGxlbmd0aCkNCj4gPiArew0KPiA+ICsJdW5zaWduZWQgc2hvcnQgc2VjdG9y
X3NpemUgPSBiZGV2X2xvZ2ljYWxfYmxvY2tfc2l6ZShiZGV2KTsNCj4gPiArDQo+ID4gKwlpZiAo
IUlTX0FMSUdORUQoKCh1NjQpZGF4LT5hZGRyICsgb2Zmc2V0KSwgc2VjdG9yX3NpemUpKQ0KPiBP
bmUgbW9yZSBxdWVzdGlvbjogJ2RheCcgaXMgaW5pdGlhbGl6ZWQgaW4gZGF4X3plcm9fcGFnZV9y
YW5nZSgpIGFuZA0KPiBkYXgtPmFkZHIgaXMgZ29pbmcgdG8gYmUgYWx3YXlzIE5VTEwgaGVyZS4g
U28gZWl0aGVyIHlvdSBmb3Jnb3QgdG8NCj4gY2FsbA0KPiBkYXhfbWFwX2F0b21pYygpIHRvIGdl
dCB0aGUgYWRkciBvciB0aGUgdXNlIG9mIGRheC0+YWRkciBpcyBqdXN0IGJvZ3VzDQo+ICh3aGlj
aCBpcyB3aGF0IEkgY3VycmVudGx5IGJlbGlldmUgc2luY2UgSSBzZWUgbm8gd2F5IGhvdyB0aGUg
YWRkcmVzcw0KPiBjb3VsZA0KPiBiZSB1bmFsaWduZWQgd2l0aCB0aGUgc2VjdG9yX3NpemUpLi4u
DQo+IA0KDQpHb29kIGNhdGNoLCBhbmQgeW91J3JlIHJpZ2h0LiBJIGRvbid0IHRoaW5rIEkgYWN0
dWFsbHkgZXZlbiB3YW50IHRvIHVzZQ0KZGF4LT5hZGRyIGZvciB0aGUgYWxpZ25tZW50IGNoZWNr
IGhlcmUgLSBJIHdhbnQgdG8gY2hlY2sgaWYgd2UncmUNCmFsaWduZWQgdG8gdGhlIGJsb2NrIGRl
dmljZSBzZWN0b3IuIEknbSB0aGlua2luZyBzb21ldGhpbmcgbGlrZToNCg0KCWlmICghSVNfQUxJ
R05FRChvZmZzZXQsIHNlY3Rvcl9zaXplKSkNCg0KVGVjaG5pY2FsbHkgd2Ugd2FudCB0byBjaGVj
ayBpZiBzZWN0b3IgKiBzZWN0b3Jfc2l6ZSArIG9mZnNldCBpcw0KYWxpZ25lZCwgYnV0IHRoZSBm
aXJzdCBwYXJ0IG9mIHRoYXQgaXMgYWxyZWFkeSBhIHNlY3RvciA6KQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
