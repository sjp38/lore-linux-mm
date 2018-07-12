Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56A786B000A
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 21:41:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g5-v6so1523469pgv.12
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 18:41:03 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e85-v6si22087346pfl.132.2018.07.11.18.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 18:41:02 -0700 (PDT)
From: "Lu, Aaron" <aaron.lu@intel.com>
Subject: Re: [RFC PATCH] mm, page_alloc: double zone's batchsize
Date: Thu, 12 Jul 2018 01:40:41 +0000
Message-ID: <9f778198327e62cdab0651382740189e0665507a.camel@intel.com>
References: <20180711055855.29072-1-aaron.lu@intel.com>
	 <20180711143505.5ccb378fb67dc6ba8fa202a3@linux-foundation.org>
In-Reply-To: <20180711143505.5ccb378fb67dc6ba8fa202a3@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <B39D905F2145D74183675215CB519B0C@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "Wang, Kemi" <kemi.wang@intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "Hansen, Dave" <dave.hansen@intel.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "Huang, Ying" <ying.huang@intel.com>

T24gV2VkLCAyMDE4LTA3LTExIGF0IDE0OjM1IC0wNzAwLCBBbmRyZXcgTW9ydG9uIHdyb3RlOg0K
PiBPbiBXZWQsIDExIEp1bCAyMDE4IDEzOjU4OjU1ICswODAwIEFhcm9uIEx1IDxhYXJvbi5sdUBp
bnRlbC5jb20+IHdyb3RlOg0KPiANCj4gPiBbNTUwIGxpbmVzIG9mIGNoYW5nZWxvZ10NCj4gDQo+
IE9LLCBJJ20gY29udmluY2VkIDspICBUaGF0IHdhcyBhIGxvdCBvZiB3b3JrIC0gdGhhbmtzIGZv
ciBiZWluZyBleGhhdXN0aXZlLg0KDQpUaGFua3MgQW5kcmV3Lg0KSSB0aGluayB0aGUgY3JlZGl0
IGdvZXMgdG8gRGF2ZSBIYW5zZW4gc2luY2UgaGUgaGFzIGJlZW4gdmVyeSBjYXJlZnVsDQphYm91
dCB0aGlzIGNoYW5nZSBhbmQgd291bGQgbGlrZSBtZSB0byBkbyBhbGwgdGhvc2UgMm5kIHBoYXNl
IHRlc3RzIHRvDQptYWtlIHN1cmUgd2UgZGlkbid0IGdldCBhbnkgc3VycHJpc2UgYWZ0ZXIgZG91
YmxpbmcgYmF0Y2ggc2l6ZSA6LSkNCg0KSSB0aGluayB0aGUgTEtQIHJvYm90IHdpbGwgcnVuIGV2
ZW4gbW9yZSB0ZXN0cyB0byBjYXB0dXJlIHBvc3NpYmxlDQpyZWdyZXNzaW9ucywgaWYgYW55Lg==
