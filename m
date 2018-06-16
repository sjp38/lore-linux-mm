Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1259B6B026D
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 21:19:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x17-v6so5418550pfm.18
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 18:19:41 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i9-v6si7664941pgo.36.2018.06.15.18.19.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 18:19:40 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v33 1/4] mm: add a function to get free page blocks
Date: Sat, 16 Jun 2018 01:19:36 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7396A5CDB@shsmsx102.ccr.corp.intel.com>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
 <1529037793-35521-2-git-send-email-wei.w.wang@intel.com>
 <CA+55aFzhuGKinEq5udPsk_uYHShkQxJYqcPO=tLCkT-oxpsgPg@mail.gmail.com>
In-Reply-To: <CA+55aFzhuGKinEq5udPsk_uYHShkQxJYqcPO=tLCkT-oxpsgPg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, virtualization <virtualization@lists.linux-foundation.org>, KVM list <kvm@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, Rik van Riel <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

T24gU2F0dXJkYXksIEp1bmUgMTYsIDIwMTggNzowOSBBTSwgTGludXMgVG9ydmFsZHMgd3JvdGU6
DQo+IE9uIEZyaSwgSnVuIDE1LCAyMDE4IGF0IDI6MDggUE0gV2VpIFdhbmcgPHdlaS53LndhbmdA
aW50ZWwuY29tPiB3cm90ZToNCj4gPg0KPiA+IFRoaXMgcGF0Y2ggYWRkcyBhIGZ1bmN0aW9uIHRv
IGdldCBmcmVlIHBhZ2VzIGJsb2NrcyBmcm9tIGEgZnJlZSBwYWdlDQo+ID4gbGlzdC4gVGhlIG9i
dGFpbmVkIGZyZWUgcGFnZSBibG9ja3MgYXJlIGhpbnRzIGFib3V0IGZyZWUgcGFnZXMsDQo+ID4g
YmVjYXVzZSB0aGVyZSBpcyBubyBndWFyYW50ZWUgdGhhdCB0aGV5IGFyZSBzdGlsbCBvbiB0aGUg
ZnJlZSBwYWdlDQo+ID4gbGlzdCBhZnRlciB0aGUgZnVuY3Rpb24gcmV0dXJucy4NCj4gDQo+IEFj
ay4gVGhpcyBpcyB0aGUga2luZCBvZiBzaW1wbGUgaW50ZXJmYWNlIHdoZXJlIEkgZG9uJ3QgbmVl
ZCB0byB3b3JyeSBhYm91dA0KPiB0aGUgTU0gY29kZSBjYWxsaW5nIG91dCB0byByYW5kb20gZHJp
dmVycyBvciBzdWJzeXN0ZW1zLg0KPiANCj4gSSB0aGluayB0aGF0ICJvcmRlciIgc2hvdWxkIGJl
IGNoZWNrZWQgZm9yIHZhbGlkaXR5LCBidXQgZnJvbSBhIE1NIHN0YW5kcG9pbnQNCj4gSSB0aGlu
ayB0aGlzIGlzIGZpbmUuDQo+IA0KDQpUaGFua3MsIHdpbGwgYWRkIGEgdmFsaWRpdHkgY2hlY2sg
Zm9yICJvcmRlciIuDQoNCkJlc3QsDQpXZWkNCg==
