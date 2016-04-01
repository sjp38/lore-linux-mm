Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B032E6B007E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 15:17:55 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id tt10so97662389pab.3
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 12:17:55 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id t1si23075466pas.16.2016.04.01.12.17.54
        for <linux-mm@kvack.org>;
        Fri, 01 Apr 2016 12:17:54 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH 4/5] dax: use sb_issue_zerout instead of calling
 dax_clear_sectors
Date: Fri, 1 Apr 2016 19:17:52 +0000
Message-ID: <1459538265.23200.8.camel@intel.com>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
	 <1458861450-17705-5-git-send-email-vishal.l.verma@intel.com>
	 <CAPcyv4iKK=1Nhz4QqEkhc4gum+UvUS4a=+Sza2zSa1Kyrth41w@mail.gmail.com>
	 <1458939796.5501.8.camel@intel.com>
	 <CAPcyv4jWqVcav7dQPh7WHpqB6QDrCezO5jbd9QW9xH3zsU4C1w@mail.gmail.com>
	 <1459195288.15523.3.camel@intel.com>
	 <CAPcyv4jFwh679arTNoUzLZpJCSoR+KhMdEmwqddCU1RWOrjD=Q@mail.gmail.com>
	 <1459277829.6412.3.camel@intel.com> <20160330074926.GC12776@quack.suse.cz>
In-Reply-To: <20160330074926.GC12776@quack.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <BCDA0CA9B9E5EA4C9093399005FC4758@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jack@suse.cz" <jack@suse.cz>
Cc: "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "Williams, Dan J" <dan.j.williams@intel.com>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew
 R" <matthew.r.wilcox@intel.com>, "david@fromorbit.com" <david@fromorbit.com>

T24gV2VkLCAyMDE2LTAzLTMwIGF0IDA5OjQ5ICswMjAwLCBKYW4gS2FyYSB3cm90ZToNCj4gT24g
VHVlIDI5LTAzLTE2IDE4OjU3OjE2LCBWZXJtYSwgVmlzaGFsIEwgd3JvdGU6DQo+ID4gDQo+ID4g
T24gTW9uLCAyMDE2LTAzLTI4IGF0IDE2OjM0IC0wNzAwLCBEYW4gV2lsbGlhbXMgd3JvdGU6DQo+
ID4gDQo+ID4gPD4NCj4gPiANCj4gPiA+IA0KPiA+ID4gU2VlbXMga2luZCBvZiBzYWQgdG8gZmFp
bCB0aGUgZmF1bHQgZHVlIHRvIGEgYmFkIGJsb2NrIHdoZW4gd2UNCj4gPiA+IHdlcmUNCj4gPiA+
IGdvaW5nIHRvIHplcm8gaXQgYW55d2F5LCByaWdodD/CoMKgSSdtIG5vdCBzZWVpbmcgYSBjb21w
ZWxsaW5nDQo+ID4gPiByZWFzb24gdG8NCj4gPiA+IGtlZXAgYW55IHplcm9pbmcgaW4gZnMvZGF4
LmMuDQo+ID4gQWdyZWVkIC0gYnV0IGhvdyBkbyB3ZSBkbyB0aGlzPyBjbGVhcl9wbWVtIG5lZWRz
IHRvIGJlIGFibGUgdG8gY2xlYXINCj4gPiBhbg0KPiA+IGFyYml0cmFyeSBudW1iZXIgb2YgYnl0
ZXMsIGJ1dCB0byBnbyB0aHJvdWdoIHRoZSBkcml2ZXIsIHdlJ2QgbmVlZA0KPiA+IHRvDQo+ID4g
c2VuZCBkb3duIGEgYmlvPyBJZiBvbmx5IHRoZSBkcml2ZXIgaGFkIGFuIHJ3X2J5dGVzIGxpa2Ug
aW50ZXJmYWNlDQo+ID4gdGhhdA0KPiA+IGNvdWxkIGJlIHVzZWQgYnkgYW55b25lLi4uIDopDQo+
IEFjdHVhbGx5LCBteSBwYXRjaGVzIGZvciBwYWdlIGZhdWx0IGxvY2tpbmcgcmVtb3ZlIHplcm9p
bmcgZnJvbQ0KPiBkYXhfaW5zZXJ0X21hcHBpbmcoKSBhbmQgX19kYXhfcG1kX2ZhdWx0KCkgLSB0
aGUgemVyb2luZyBub3cgaGFwcGVucw0KPiBmcm9tDQo+IHRoZSBmaWxlc3lzdGVtIG9ubHkgYW5k
IHRoZSB6ZXJvaW5nIGluIHRob3NlIHR3byBmdW5jdGlvbnMgaXMganVzdCBhDQo+IGRlYWQNCj4g
Y29kZS4uLg0KDQpUaGF0IHNob3VsZCBtYWtlIHRoaW5ncyBlYXNpZXIhIERvIHlvdSBoYXZlIGEg
dHJlZSBJIGNvdWxkIG1lcmdlIGluIHRvDQpnZXQgdGhpcz8gKFdJUCBpcyBvayBhcyB3ZSBrbm93
IHRoYXQgbXkgc2VyaWVzIHdpbGwgZGVwZW5kIG9uIHlvdXJzLi4pDQpvciwgaWYgeW91IGNhbiBk
aXN0aWxsIG91dCB0aGF0IHBhdGNoIG9uIGEgNC42LXJjMSBiYXNlLCBJIGNvdWxkIGNhcnJ5DQpp
dCBpbiBteSBzZXJpZXMgdG9vICh5b3VyIHYyJ3MgMy8xMCBkb2Vzbid0IGFwcGx5IG9uIDQuNi1y
YzEuLikNCg0KVGhhbmtzLA0KCS1WaXNoYWw=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
