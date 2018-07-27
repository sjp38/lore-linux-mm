Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 617676B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 02:08:24 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id v2-v6so2857190ioh.17
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 23:08:24 -0700 (PDT)
Received: from mail.wingtech.com (mail.wingtech.com. [180.166.216.14])
        by mx.google.com with ESMTPS id l16-v6si2475171itl.138.2018.07.26.23.08.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Jul 2018 23:08:22 -0700 (PDT)
Date: Fri, 27 Jul 2018 14:07:49 +0800
From: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Subject: Re: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
References: <2018072514375722198958@wingtech.com>,
	<20180725141643.6d9ba86a9698bc2580836618@linux-foundation.org>,
	<2018072610214038358990@wingtech.com>,
	<20180726060640.GQ28386@dhcp22.suse.cz>,
	<20180726150323057627100@wingtech.com>,
	<20180726151118.db0cf8016e79bed849e549f9@linux-foundation.org>
Mime-Version: 1.0
Message-ID: <20180727140749669129112@wingtech.com>
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, mgorman <mgorman@techsingularity.net>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

Pk9uIFRodSwgMjYgSnVsIDIwMTggMTU6MDM6MjMgKzA4MDAgInpoYW93dXl1bkB3aW5ndGVjaC5j
b20iIDx6aGFvd3V5dW5Ad2luZ3RlY2guY29tPiB3cm90ZToKPgo+PiA+T24gVGh1IDI2LTA3LTE4
IDEwOjIxOjQwLCB6aGFvd3V5dW5Ad2luZ3RlY2guY29tIHdyb3RlOgo+PiA+Wy4uLl0KPj4gPj4g
T3VyIHByb2plY3QgcmVhbGx5IG5lZWRzIGEgZml4IHRvIHRoaXMgaXNzdWUKPj4gPgo+PiA+Q291
bGQgeW91IGJlIG1vcmUgc3BlY2lmaWMgd2h5PyBNeSB1bmRlcnN0YW5kaW5nIGlzIHRoYXQgUlQg
dGFza3MKPj4gPnVzdWFsbHkgaGF2ZSBhbGwgdGhlIG1lbW9yeSBtbG9ja2VkIG90aGVyd2lzZSBh
bGwgdGhlIHJlYWwgdGltZQo+PiA+ZXhwZWN0YXRpb25zIGFyZSBnb25lIGFscmVhZHkuCj4+ID4t
LQo+PiA+TWljaGFsIEhvY2tvCj4+ID5TVVNFIExhYnMKPj4KPj4KPj4gVGhlIFJUIHRocmVhZCBp
cyBjcmVhdGVkIGJ5IGEgcHJvY2VzcyB3aXRoIG5vcm1hbCBwcmlvcml0eSwgYW5kIHRoZSBwcm9j
ZXNzIHdhcyBzbGVlcCwKPj4gdGhlbiBzb21lIHRhc2sgbmVlZHMgdGhlIFJUIHRocmVhZCB0byBk
byBzb21ldGhpbmcsIHNvIHRoZSBwcm9jZXNzIGNyZWF0ZSB0aGlzIHRocmVhZCwgYW5kIHNldCBp
dCB0byBSVCBwb2xpY3kuCj4+IEkgdGhpbmsgdGhhdCBpcyB0aGUgcmVhc29uIHdoeSBSVCB0YXNr
IHdvdWxkIHJlYWQgdGhlIHN3YXAuCj4KPkEgc2ltcGxlciBiYW5kYWlkIG1pZ2h0IGJlIHRvIHJl
cGxhY2UgdGhlIGNvbmRfcmVzY2hlZCgpIHdpdGggbXNsZWVwKDEpLiAKCgpUaGFua3MgZm9yIHRo
ZSBzdWdnZXN0aW9uLCB3ZSB3aWxsIHRyeSB0aGF0LgoKCi0tLS0tLS0tLS0tLS0tCnpoYW93dXl1
bkB3aW5ndGVjaC5jb20=
