Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9976B0003
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 22:22:14 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j17-v6so164863oii.8
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 19:22:14 -0700 (PDT)
Received: from mail.wingtech.com (mail.wingtech.com. [180.166.216.14])
        by mx.google.com with ESMTPS id r64-v6si67861oif.153.2018.07.25.19.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Jul 2018 19:22:12 -0700 (PDT)
Date: Thu, 26 Jul 2018 10:21:40 +0800
From: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Subject: Re: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
References: <2018072514375722198958@wingtech.com>,
	<20180725141643.6d9ba86a9698bc2580836618@linux-foundation.org>
Mime-Version: 1.0
Message-ID: <2018072610214038358990@wingtech.com>
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm <akpm@linux-foundation.org>
Cc: mgorman <mgorman@techsingularity.net>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, mhocko <mhocko@suse.com>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

Pk9uIFdlZCwgMjUgSnVsIDIwMTggMTQ6Mzc6NTggKzA4MDAgInpoYW93dXl1bkB3aW5ndGVjaC5j
b20iIDx6aGFvd3V5dW5Ad2luZ3RlY2guY29tPiB3cm90ZToKPgo+PiBGcm9tOiB6aGFvd3V5dW4g
PHpoYW93dXl1bkB3aW5ndGVjaC5jb20+Cj4+wqAKPj4gaXNzdWUgaXMgdGhhdCB0aGVyZSBhcmUg
dHdvIHByb2Nlc3NlcyBBIGFuZCBCLCBBIGlzIGt3b3JrZXIvdTE2OjgKPj4gbm9ybWFsIHByaW9y
aXR5LCBCIGlzIEF1ZGlvVHJhY2ssIFJUIHByaW9yaXR5LCB0aGV5IGFyZSBvbiB0aGUKPj4gc2Ft
ZSBDUFUgMy4KPj7CoAo+PiBUaGUgdGFzayBBIHByZWVtcHRlZCBieSB0YXNrIEIgaW4gdGhlIG1v
bWVudAo+PiBhZnRlciBfX2RlbGV0ZV9mcm9tX3N3YXBfY2FjaGUocGFnZSkgYW5kIGJlZm9yZSBz
d2FwY2FjaGVfZnJlZShzd2FwKS4KPj7CoAo+PiBUaGUgdGFzayBCIGRvZXMgX19yZWFkX3N3YXBf
Y2FjaGVfYXN5bmMgaW4gdGhlIGRvIHt9IHdoaWxlIGxvb3AsIGl0Cj4+IHdpbGwgbmV2ZXIgZmlu
ZCB0aGUgcGFnZSBmcm9tIHN3YXBwZXJfc3BhY2UgYmVjYXVzZSB0aGUgcGFnZSBpcyByZW1vdmVk
Cj4+IGJ5IHRoZSB0YXNrIEEsIGFuZCBpdCB3aWxsIG5ldmVyIHN1Y2Vzc2Z1bGx5IGluIHN3YXBj
YWNoZV9wcmVwYXJlIGJlY2F1c2UKPj4gdGhlIGVudHJ5IGlzIEVFWElTVC4KPj7CoAo+PiBUaGUg
dGFzayBCIHRoZW4gc3R1Y2sgaW4gdGhlIGxvb3AgaW5maW5pdGVseSBiZWNhdXNlIGl0IGlzIGEg
UlQgdGFzaywKPj4gbm8gb25lIGNhbiBwcmVlbXB0IGl0Lgo+PsKgCj4+IHNvIG5lZWQgdG8gZGlz
YWJsZSBwcmVlbXB0aW9uIHVudGlsIHRoZSBzd2FwY2FjaGVfZnJlZSBleGVjdXRlZC4KPgo+WWVz
LCByaWdodCwgc29ycnksIEkgbXVzdCBoYXZlIG1lcmdlZCBjYmFiMGU0ZWVjMjk5IGluIG15IHNs
ZWVwLgo+Y29uZF9yZXNjaGVkKCkgaXMgYSBuby1vcCBpbiB0aGUgcHJlc2VuY2Ugb2YgcmVhbHRp
bWUgcG9saWN5IHRocmVhZHMKPmFuZCB1c2luZyB0byBhdHRlbXB0IHRvIHlpZWxkIHRvIGEgZGlm
ZmVyZW50IHRocmVhZCBpdCBpbiB0aGlzIGZhc2hpb24KPmlzIGJyb2tlbi4KPgo+RGlzYWJsaW5n
IHByZWVtcHRpb24gb24gdGhlIG90aGVyIHNpZGUgb2YgdGhlIHJhY2Ugc2hvdWxkIGZpeCB0aGlu
Z3MsCj5idXQgaXQncyB1c2luZyBhIGJhbmRhaWQgdG8gcGx1ZyB0aGUgbGVha2FnZSBmcm9tIHRo
ZSBlYXJsaWVyIGJhbmRhaWQuCj5UaGUgcHJvcGVyIHdheSB0byBjb29yZGluYXRlIHRocmVhZHMg
aXMgdG8gdXNlIGEgc2xlZXBpbmcgbG9jaywgc3VjaAo+YXMgYSBtdXRleCwgb3Igc29tZSBvdGhl
ciB3YWl0L3dha2V1cCBtZWNoYW5pc20uCj4KPkFuZCBvbmNlIHRoYXQncyBkb25lLCB3ZSBjYW4g
aG9wZWZ1bGx5IGVsaW1pbmF0ZSB0aGUgZG8gbG9vcCBmcm9tCj5fX3JlYWRfc3dhcF9jYWNoZV9h
c3luYygpLsKgIFRoYXQgYWxzbyBzZXJ2aWNlcyBFTk9NRU0gZnJvbQo+cmFkaXhfdHJlZV9pbnNl
cnQoKSwgYnV0IF9fYWRkX3RvX3N3YXBfY2FjaGUoKSBhcHBlYXJzIHRvIGhhbmRsZSB0aGF0Cj5P
SyBhbmQgd2Ugc2hvdWxkbid0IGp1c3QgbG9vcCBhcm91bmQgcmV0cnlpbmcgdGhlIGluc2VydCBh
bmQgdGhlCj5yYWRpeF90cmVlX3ByZWxvYWQoKSBzaG91bGQgZW5zdXJlIHRoYXQgcmFkaXhfdHJl
ZV9pbnNlcnQoKSBuZXZlciBmYWlscwo+YW55d2F5LsKgIFVubGVzcyB3ZSdyZSBjYWxsaW5nIF9f
cmVhZF9zd2FwX2NhY2hlX2FzeW5jKCkgd2l0aCBzY3Jld3kKPmdmcF9mbGFncyBmcm9tIHNvbWV3
aGVyZS4KPgo+IAoKCllvdXIgYXJlIHJpZ2h0LCBpdCBpcyBhIGJhbmRhaWQgLi4uCkNvdWxkIHlv
dSBwcm92aWRlIHNvbWUgc3VnZ2VzdGlvbiBtb3JlIHNwZWNpZmljIGFib3V0IGhvdyB0byB1c2Ug
c2xlZXBpbmcgbG9jay9zb21lIG90aGVyIHdhaXQvd2FrZXVwIG1lY2hhbmlzbSB0byBmaXggdGhp
cyBpc3N1ZT8gVGhhbmtzIHZlcnkgbXVjaCEKT3VyIHByb2plY3QgcmVhbGx5IG5lZWRzIGEgZml4
IHRvIHRoaXMgaXNzdWUgLi4uCgoKLS0tLS0tLS0tLS0tLS0Kemhhb3d1eXVuQHdpbmd0ZWNoLmNv
bQ==
