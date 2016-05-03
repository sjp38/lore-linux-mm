Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1918A6B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 14:30:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so55596181pfy.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 11:30:07 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id y6si520481paf.29.2016.05.03.11.30.05
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 11:30:05 -0700 (PDT)
From: "Rudoff, Andy" <andy.rudoff@intel.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Date: Tue, 3 May 2016 18:30:04 +0000
Message-ID: <FBB11841-7DFE-4223-9973-3457034260C2@intel.com>
References: <1461434916.3695.7.camel@intel.com>
 <20160425083114.GA27556@infradead.org> <1461604476.3106.12.camel@intel.com>
 <20160425232552.GD18496@dastard> <1461628381.1421.24.camel@intel.com>
 <20160426004155.GF18496@dastard>
 <x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jfUVXoge5D+cBY1Ph=t60165sp6sF_QFZUbFv+cNcdHg@mail.gmail.com>
 <20160503004226.GR26977@dastard>
 <D26BCF92-ED25-4ACA-9CC8-7B1C05A1D5FC@intel.com>
 <20160503024948.GT26977@dastard>
In-Reply-To: <20160503024948.GT26977@dastard>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <7D8FE82952539F48983E0B1A68FA405B@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, "hch@infradead.org" <hch@infradead.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>

Pg0KPkFuZCB3aGVuIHRoZSBmaWxlc3lzdGVtIHNheXMgbm8gYmVjYXVzZSB0aGUgZnMgZGV2cyBk
b24ndCB3YW50IHRvDQo+aGF2ZSB0byBkZWFsIHdpdGggYnJva2VuIGFwcHMgYmVjYXVzZSBhcHAg
ZGV2cyBsZWFybiB0aGF0ICJ0aGlzIGlzIGENCj5nbyBmYXN0IGtub2IiIGFuZCBkYXRhIGludGVn
cml0eSBiZSBkYW1uZWQ/IEl0J3MgImZzeW5jIGlzIHNsb3cgc28gSQ0KPndvbid0IHVzZSBpdCIg
YWxsIG92ZXIgYWdhaW4uLi4NCi4uLg0KPg0KPkFuZCwgcGxlYXNlIGtlZXAgaW4gbWluZDogbWFu
eSBhcHBsaWNhdGlvbiBkZXZlbG9wZXJzIHdpbGwgbm90DQo+ZGVzaWduIGZvciBwbWVtIGJlY2F1
c2UgdGhleSBhbHNvIGhhdmUgdG8gc3VwcG9ydCB0cmFkaXRpb25hbA0KPnN0b3JhZ2UgYmFja2Vk
IGJ5IHBhZ2UgY2FjaGUuIElmIHRoZXkgdXNlIG1zeW5jKCksIHRoZSBhcHAgd2lsbCB3b3JrDQo+
b24gYW55IHN0b3JhZ2Ugc3RhY2ssIGJ1dCBqdXN0IGJlIG11Y2gsIG11Y2ggZmFzdGVyIG9uIHBt
ZW0rREFYLiBTbywNCj5yZWFsbHksIHdlIGhhdmUgdG8gbWFrZSB0aGUgbXN5bmMoKS1vbmx5IG1v
ZGVsIHdvcmsgZWZmaWNpZW50bHksIHNvDQo+d2UgbWF5IGFzIHdlbGwgZGVzaWduIGZvciB0aGF0
IGluIHRoZSBmaXJzdCBwbGFjZS4uLi4NCg0KQm90aCBvZiB0aGVzZSBzbmlwcGV0cyBzZWVtIHRv
IGJlIGFyZ3VpbmcgdGhhdCB3ZSBzaG91bGQgbWFrZSBtc3luYy9mc3luYw0KbW9yZSBlZmZpY2ll
bnQuICBCdXQgSSBkb24ndCB0aGluayBhbnlvbmUgaXMgYXJndWluZyB0aGUgb3Bwb3NpdGUuICBJ
cw0Kc29tZW9uZSBzYXlpbmcgd2Ugc2hvdWxkbid0IG1ha2UgdGhlIG1zeW5jKCktb25seSBtb2Rl
bCB3b3JrIGVmZmljaWVudGx5Pw0KDQpTYWlkIGFub3RoZXIgd2F5OiB0aGUgY29tbW9uIGNhc2Ug
Zm9yIERBWCB3aWxsIGJlIGFwcGxpY2F0aW9ucyBzaW1wbHkNCmZvbGxvd2luZyB0aGUgUE9TSVgg
bW9kZWwuICBvcGVuLCBtbWFwLCBtc3luYy4uLiAgVGhhdCB3aWxsIHdvcmsgZmluZQ0KYW5kIG9m
IGNvdXJzZSB3ZSBzaG91bGQgb3B0aW1pemUgdGhhdCBwYXRoIGFzIG11Y2ggYXMgcG9zc2libGUu
ICBMZXNzDQpjb21tb24gYXJlIGxhdGVuY3ktc2Vuc2l0aXZlIGFwcGxpY2F0aW9ucyBidWlsdCB0
byBsZXZlcmFnZSB0byBieXRlLQ0KYWRkcmVzc2FibGUgbmF0dXJlIG9mIHBtZW0uICBGaWxlIHN5
c3RlbXMgc3VwcG9ydGluZyB0aGlzIG1vZGVsIHdpbGwNCmluZGljYXRlIGl0IHVzaW5nIGEgbmV3
IGlvY3RsIHRoYXQgc2F5cyBkb2luZyBDUFUgY2FjaGUgZmx1c2hlcyBpcw0Kc3VmZmljaWVudCB0
byBmbHVzaCBzdG9yZXMgdG8gcGVyc2lzdGVuY2UuICBCdXQgSSBkb24ndCBzZWUgaG93IHRoYXQN
CmRpcmVjdGlvbiBpcyBnZXR0aW5nIHR1cm5lZCBpbnRvIGFuIGFyZ3VtZW50IGFnYWluc3QgbXN5
bmMoKSBlZmZpY2llbmN5Lg0KDQo+V2hpY2ggYnJpbmdzIHVwIGFub3RoZXIgcG9pbnQ6IGFkdmFu
Y2VkIG5ldyBmdW5jdGlvbmFsaXR5DQo+aXMgZ29pbmcgdG8gcmVxdWlyZSBuYXRpdmUgcG1lbSBm
aWxlc3lzdGVtcy4NCg0KSSBhZ3JlZSB0aGVyZSdzIG9wcG9ydHVuaXR5IGZvciBuZXcgZmlsZXN5
c3RlbXMgKGFuZCBvbGQpIHRvIGxldmVyYWdlDQp3aGF0IHBtZW0gcHJvdmlkZXMuICBCdXQgdGhl
IHdvcmQgInJlcXVpcmUiIGltcGxpZXMgdGhhdCdzIHRoZSBvbmx5DQp3YXkgdG8gZ28gYW5kIHdl
IGtub3cgdGhhdCdzIG5vdCB0aGUgY2FzZS4gIFVzaW5nIGV4dDQrZGF4IHRvIG1hcA0KcG1lbSBp
bnRvIGFuIGFwcGxpY2F0aW9uIGFsbG93cyB0aGF0IGFwcGxpY2F0aW9uIHRvIHVzZSB0aGUgcG1l
bQ0KZGlyZWN0bHkgYW5kIGEgZ29vZCBudW1iZXIgb2Ygc29mdHdhcmUgcHJvamVjdHMgYXJlIGRv
aW5nIGV4YWN0bHkgdGhhdC4NCg0KLWFuZHkNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
