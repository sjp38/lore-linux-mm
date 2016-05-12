Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5ECEC6B0266
	for <linux-mm@kvack.org>; Thu, 12 May 2016 13:07:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so156473740pfy.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 10:07:31 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id a3si18468776pfb.217.2016.05.12.10.07.30
        for <linux-mm@kvack.org>;
        Thu, 12 May 2016 10:07:30 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH v7 4/6] dax: export a low-level __dax_zero_page_range
 helper
Date: Thu, 12 May 2016 17:06:39 +0000
Message-ID: <1463072787.29294.38.camel@intel.com>
References: <1463000932-31680-1-git-send-email-vishal.l.verma@intel.com>
	 <1463000932-31680-5-git-send-email-vishal.l.verma@intel.com>
	 <20160512084138.GC10306@quack2.suse.cz>
In-Reply-To: <20160512084138.GC10306@quack2.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <9CB344B4DD27584EAD3C45DE3E6E0947@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jack@suse.cz" <jack@suse.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "jmoyer@redhat.com" <jmoyer@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hch@lst.de" <hch@lst.de>, "Williams, Dan J" <dan.j.williams@intel.com>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "boaz@plexistor.com" <boaz@plexistor.com>, "david@fromorbit.com" <david@fromorbit.com>

T24gVGh1LCAyMDE2LTA1LTEyIGF0IDEwOjQxICswMjAwLCBKYW4gS2FyYSB3cm90ZToNCj4gT24g
V2VkIDExLTA1LTE2IDE1OjA4OjUwLCBWaXNoYWwgVmVybWEgd3JvdGU6DQo+ID4gDQo+ID4gRnJv
bTogQ2hyaXN0b3BoIEhlbGx3aWcgPGhjaEBsc3QuZGU+DQo+ID4gDQo+ID4gVGhpcyBhbGxvd3Mg
WEZTIHRvIHBlcmZvcm0gemVyb2luZyB1c2luZyB0aGUgaW9tYXAgaW5mcmFzdHJ1Y3R1cmUNCj4g
PiBhbmQNCj4gPiBhdm9pZCBidWZmZXIgaGVhZHMuDQo+ID4gDQo+ID4gW3Zpc2hhbDogZml4IGNv
bmZsaWN0cyB3aXRoIGRheC1lcnJvci1oYW5kbGluZ10NCj4gPiBTaWduZWQtb2ZmLWJ5OiBDaHJp
c3RvcGggSGVsbHdpZyA8aGNoQGxzdC5kZT4NCj4gTG9va3MgZ29vZC4gWW91IGNhbiBhZGQ6DQo+
IA0KPiBSZXZpZXdlZC1ieTogSmFuIEthcmEgPGphY2tAc3VzZS5jej4NCj4gDQo+IEJUVzogWW91
IGFyZSBzdXBwb3NlZCB0byBhZGQgeW91ciBTaWduZWQtb2ZmLWJ5IHdoZW4gZm9yd2FyZGluZw0K
PiBwYXRjaGVzDQo+IGxpa2UgdGhpcy4uLg0KDQpBaCBJIGRpZG4ndCBrbm93LiBJJ2xsIGFkZCBp
dCB3aGVuIG1ha2luZyB0aGUgc3RhYmxlIHRvcGljIGJyYW5jaCBmb3INCnRoaXMuIFRoYW5rcyEN
Cg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
