Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 84B8E6B025E
	for <linux-mm@kvack.org>; Thu,  5 May 2016 17:39:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so191674312pfy.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 14:39:33 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id b68si13192003pfb.21.2016.05.05.14.39.32
        for <linux-mm@kvack.org>;
        Thu, 05 May 2016 14:39:32 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
Date: Thu, 5 May 2016 21:39:14 +0000
Message-ID: <1462484343.29294.1.camel@intel.com>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
	 <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
	 <5727753F.6090104@plexistor.com> <20160505142433.GA4557@infradead.org>
In-Reply-To: <20160505142433.GA4557@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A85A0D742E7D4047B1D16786AE1B7AF0@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@infradead.org" <hch@infradead.org>, "boaz@plexistor.com" <boaz@plexistor.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "axboe@fb.com" <axboe@fb.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>, "matthew@wil.cx" <matthew@wil.cx>

T24gVGh1LCAyMDE2LTA1LTA1IGF0IDA3OjI0IC0wNzAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gT24gTW9uLCBNYXkgMDIsIDIwMTYgYXQgMDY6NDE6NTFQTSArMDMwMCwgQm9heiBIYXJy
b3NoIHdyb3RlOg0KPiA+IA0KPiA+ID4gDQo+ID4gPiBBbGwgSU8gaW4gYSBkYXggZmlsZXN5c3Rl
bSB1c2VkIHRvIGdvIHRocm91Z2ggZGF4X2RvX2lvLCB3aGljaA0KPiA+ID4gY2Fubm90DQo+ID4g
PiBoYW5kbGUgbWVkaWEgZXJyb3JzLCBhbmQgdGh1cyBjYW5ub3QgcHJvdmlkZSBhIHJlY292ZXJ5
IHBhdGggdGhhdA0KPiA+ID4gY2FuDQo+ID4gPiBzZW5kIGEgd3JpdGUgdGhyb3VnaCB0aGUgZHJp
dmVyIHRvIGNsZWFyIGVycm9ycy4NCj4gPiA+IA0KPiA+ID4gQWRkIGEgbmV3IGlvY2IgZmxhZyBm
b3IgREFYLCBhbmQgc2V0IGl0IG9ubHkgZm9yIERBWCBtb3VudHMuIEluDQo+ID4gPiB0aGUgSU8N
Cj4gPiA+IHBhdGggZm9yIERBWCBmaWxlc3lzdGVtcywgdXNlIHRoZSBzYW1lIGRpcmVjdF9JTyBw
YXRoIGZvciBib3RoIERBWA0KPiA+ID4gYW5kDQo+ID4gPiBkaXJlY3RfaW8gaW9jYnMsIGJ1dCB1
c2UgdGhlIGZsYWdzIHRvIGlkZW50aWZ5IHdoZW4gd2UgYXJlIGluDQo+ID4gPiBPX0RJUkVDVA0K
PiA+ID4gbW9kZSB2cyBub24gT19ESVJFQ1Qgd2l0aCBEQVgsIGFuZCBmb3IgT19ESVJFQ1QsIHVz
ZSB0aGUNCj4gPiA+IGNvbnZlbnRpb25hbA0KPiA+ID4gZGlyZWN0X0lPIHBhdGggaW5zdGVhZCBv
ZiBEQVguDQo+ID4gPiANCj4gPiBSZWFsbHk/IFdoYXQgYXJlIHlvdXIgdGhpbmtpbmcgaGVyZT8N
Cj4gPiANCj4gPiBXaGF0IGFib3V0IGFsbCB0aGUgY3VycmVudCB1c2VycyBvZiBPX0RJUkVDVCwg
eW91IGhhdmUganVzdCBtYWRlDQo+ID4gdGhlbQ0KPiA+IDQgdGltZXMgc2xvd2VyIGFuZCAibGVz
cyBjb25jdXJyZW50KiIgdGhlbiAiYnVmZnJlZCBpbyIgdXNlcnMuIFNpbmNlDQo+ID4gZGlyZWN0
X0lPIHBhdGggd2lsbCBxdWV1ZSBhbiBJTyByZXF1ZXN0IGFuZCBhbGwuDQo+ID4gKEFuZCBpZiBp
dCBpcyBub3Qgc28gc2xvdyB0aGVuIHdoeSBkbyB3ZSBuZWVkIGRheF9kb19pbyBhdCBhbGw/DQo+
ID4gW1JoZXRvcmljYWxdKQ0KPiA+IA0KPiA+IEkgaGF0ZSBpdCB0aGF0IHlvdSBvdmVybG9hZCB0
aGUgc2VtYW50aWNzIG9mIGEga25vd24gYW5kIGV4cGVjdGVkDQo+ID4gT19ESVJFQ1QgZmxhZywg
Zm9yIHNwZWNpYWwgcG1lbSBxdWlya3MuIFRoaXMgaXMgYW4gaW5jb21wYXRpYmxlDQo+ID4gYW5k
IHVucmVsYXRlZCBvdmVybG9hZCBvZiB0aGUgc2VtYW50aWNzIG9mIE9fRElSRUNULg0KPiBBZ3Jl
ZWQgLSBtYWtpZyBPX0RJUkVDVCBsZXNzIGRpcmVjdCB0aGFuIG5vdCBoYXZpbmcgaXQgaXMgcGxh
aW4NCj4gc3R1cGlkLA0KPiBhbmQgSSBzb21laG93IG1pc3NlZCB0aGlzIGluaXRpYWxseS4NCg0K
SG93IGlzIGl0IGFueSAnbGVzcyBkaXJlY3QnPyBBbGwgaXQgZG9lcyBub3cgaXMgZm9sbG93IHRo
ZSBibG9ja2Rldg0KT19ESVJFQ1QgcGF0aC4gVGhlcmUgc3RpbGwgaXNuJ3QgYW55IHBhZ2UgY2Fj
aGUgaW52b2x2ZWQuLg0KDQo+IA0KPiBUaGlzIHdob2xlIERBWCBzdG9yeSB0dXJucyBpbnRvIGEg
bWFqb3IgbmlnaHRtYXJlLCBhbmQgSSBmZWFyIGFsbCBvdXINCj4gaG9kZ2UgcG9kZ2UgdHdlYWtz
IHRvIHRoZSBzZW1hbnRpY3MgYXJlbid0IGhlbHBpbmcgaXQuDQo+IA0KPiBJdCBzZWVtcyBsaWtl
IHdlIHNpbXBseSBuZWVkIGFuIGV4cGxpY2l0IE9fREFYIGZvciB0aGUgcmVhZC93cml0ZQ0KPiBi
eXBhc3MgaWYgY2FuJ3Qgc29ydCBvdXQgdGhlIHNlbWFudGljcyAoZXJyb3IsIHdyaXRlciBzeW5j
aHJvbml6YXRpb24pDQo+IGp1c3QgYXMgd2UgbmVlZCBhIHNwZWNpYWwgZmxhZyBmb3IgTU1BUC4u

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
