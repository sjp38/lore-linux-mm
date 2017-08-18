Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2016B025F
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 09:06:24 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g35so84578030ioi.5
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 06:06:24 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 76si3483533pgd.169.2017.08.18.06.06.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 06:06:23 -0700 (PDT)
From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH 1/2] sched/wait: Break up long wake list walk
Date: Fri, 18 Aug 2017 13:06:04 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07753787920@SHSMSX103.ccr.corp.intel.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
In-Reply-To: <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes
 Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

DQoNCj4gT24gVGh1LCBBdWcgMTcsIDIwMTcgYXQgMToxOCBQTSwgTGlhbmcsIEthbiA8a2FuLmxp
YW5nQGludGVsLmNvbT4gd3JvdGU6DQo+ID4NCj4gPiBIZXJlIGlzIHRoZSBjYWxsIHN0YWNrIG9m
IHdhaXRfb25fcGFnZV9iaXRfY29tbW9uIHdoZW4gdGhlIHF1ZXVlIGlzDQo+ID4gbG9uZyAoZW50
cmllcyA+MTAwMCkuDQo+ID4NCj4gPiAjIE92ZXJoZWFkICBUcmFjZSBvdXRwdXQNCj4gPiAjIC4u
Li4uLi4uICAuLi4uLi4uLi4uLi4uLi4uLi4NCj4gPiAjDQo+ID4gICAgMTAwLjAwJSAgKGZmZmZm
ZmZmOTMxYWVmY2EpDQo+ID4gICAgICAgICAgICAgfA0KPiA+ICAgICAgICAgICAgIC0tLXdhaXRf
b25fcGFnZV9iaXQNCj4gPiAgICAgICAgICAgICAgICBfX21pZ3JhdGlvbl9lbnRyeV93YWl0DQo+
ID4gICAgICAgICAgICAgICAgbWlncmF0aW9uX2VudHJ5X3dhaXQNCj4gPiAgICAgICAgICAgICAg
ICBkb19zd2FwX3BhZ2UNCj4gPiAgICAgICAgICAgICAgICBfX2hhbmRsZV9tbV9mYXVsdA0KPiA+
ICAgICAgICAgICAgICAgIGhhbmRsZV9tbV9mYXVsdA0KPiA+ICAgICAgICAgICAgICAgIF9fZG9f
cGFnZV9mYXVsdA0KPiA+ICAgICAgICAgICAgICAgIGRvX3BhZ2VfZmF1bHQNCj4gPiAgICAgICAg
ICAgICAgICBwYWdlX2ZhdWx0DQo+IA0KPiBIbW0uIE9rLCBzbyBpdCBkb2VzIHNlZW0gdG8gdmVy
eSBtdWNoIGJlIHJlbGF0ZWQgdG8gbWlncmF0aW9uLiBZb3VyDQo+IHdha2VfdXBfcGFnZV9iaXQo
KSBwcm9maWxlIG1hZGUgbWUgc3VzcGVjdCB0aGF0LCBidXQgdGhpcyBvbmUgc2VlbXMgdG8NCj4g
cHJldHR5IG11Y2ggY29uZmlybSBpdC4NCj4gDQo+IFNvIGl0IGxvb2tzIGxpa2UgdGhhdCB3YWl0
X29uX3BhZ2VfbG9ja2VkKCkgdGhpbmcgaW4gX19taWdyYXRpb25fZW50cnlfd2FpdCgpLA0KPiBh
bmQgd2hhdCBwcm9iYWJseSBoYXBwZW5zIGlzIHRoYXQgeW91ciBsb2FkIGVuZHMgdXAgdHJpZ2dl
cmluZyBhIGxvdCBvZg0KPiBtaWdyYXRpb24gKG9yIGp1c3QgbWlncmF0aW9uIG9mIGEgdmVyeSBo
b3QgcGFnZSksIGFuZCB0aGVuICpldmVyeSogdGhyZWFkDQo+IGVuZHMgdXAgd2FpdGluZyBmb3Ig
d2hhdGV2ZXIgcGFnZSB0aGF0IGVuZGVkIHVwIGdldHRpbmcgbWlncmF0ZWQuDQo+IA0KPiBBbmQg
c28gdGhlIHdhaXQgcXVldWUgZm9yIHRoYXQgcGFnZSBncm93cyBodWdlbHkgbG9uZy4NCj4gDQo+
IExvb2tpbmcgYXQgdGhlIG90aGVyIHByb2ZpbGUsIHRoZSB0aGluZyB0aGF0IGlzIGxvY2tpbmcg
dGhlIHBhZ2UgKHRoYXQgZXZlcnlib2R5DQo+IHRoZW4gZW5kcyB1cCB3YWl0aW5nIG9uKSB3b3Vs
ZCBzZWVtIHRvIGJlDQo+IG1pZ3JhdGVfbWlzcGxhY2VkX3RyYW5zaHVnZV9wYWdlKCksIHNvIHRo
aXMgaXMgX3ByZXN1bWFibHlfIGR1ZSB0byBOVU1BDQo+IGJhbGFuY2luZy4NCj4gDQo+IERvZXMg
dGhlIHByb2JsZW0gZ28gYXdheSBpZiB5b3UgZGlzYWJsZSB0aGUgTlVNQSBiYWxhbmNpbmcgY29k
ZT8NCj4gDQoNClllcywgdGhlIHByb2JsZW0gZ29lcyBhd2F5IHdoZW4gTlVNQSBiYWxhbmNpbmcg
aXMgZGlzYWJsZWQuDQoNCg0KVGhhbmtzLA0KS2FuDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
