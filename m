Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 14A706B000C
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 03:04:24 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u11-v6so618843oif.22
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 00:04:24 -0700 (PDT)
Received: from mail.wingtech.com (mail.wingtech.com. [180.166.216.14])
        by mx.google.com with ESMTPS id b185-v6si403248oif.189.2018.07.26.00.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Jul 2018 00:04:23 -0700 (PDT)
Date: Thu, 26 Jul 2018 15:03:23 +0800
From: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Subject: Re: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
References: <2018072514375722198958@wingtech.com>,
	<20180725141643.6d9ba86a9698bc2580836618@linux-foundation.org>,
	<2018072610214038358990@wingtech.com>,
	<20180726060640.GQ28386@dhcp22.suse.cz>
Mime-Version: 1.0
Message-ID: <20180726150323057627100@wingtech.com>
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm <akpm@linux-foundation.org>, mgorman <mgorman@techsingularity.net>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

Pk9uIFRodSAyNi0wNy0xOCAxMDoyMTo0MCwgemhhb3d1eXVuQHdpbmd0ZWNoLmNvbSB3cm90ZToK
PlsuLi5dCj4+IE91ciBwcm9qZWN0IHJlYWxseSBuZWVkcyBhIGZpeCB0byB0aGlzIGlzc3VlCj4K
PkNvdWxkIHlvdSBiZSBtb3JlIHNwZWNpZmljIHdoeT8gTXkgdW5kZXJzdGFuZGluZyBpcyB0aGF0
IFJUIHRhc2tzCj51c3VhbGx5IGhhdmUgYWxsIHRoZSBtZW1vcnkgbWxvY2tlZCBvdGhlcndpc2Ug
YWxsIHRoZSByZWFsIHRpbWUKPmV4cGVjdGF0aW9ucyBhcmUgZ29uZSBhbHJlYWR5Lgo+LS0KPk1p
Y2hhbCBIb2Nrbwo+U1VTRSBMYWJzIAoKClRoZSBSVCB0aHJlYWQgaXMgY3JlYXRlZCBieSBhIHBy
b2Nlc3Mgd2l0aCBub3JtYWwgcHJpb3JpdHksIGFuZCB0aGUgcHJvY2VzcyB3YXMgc2xlZXAsIAp0
aGVuIHNvbWUgdGFzayBuZWVkcyB0aGUgUlQgdGhyZWFkIHRvIGRvIHNvbWV0aGluZywgc28gdGhl
IHByb2Nlc3MgY3JlYXRlIHRoaXMgdGhyZWFkLCBhbmQgc2V0IGl0IHRvIFJUIHBvbGljeS4KSSB0
aGluayB0aGF0IGlzIHRoZSByZWFzb24gd2h5IFJUIHRhc2sgd291bGQgcmVhZCB0aGUgc3dhcC4K
CgotLS0tLS0tLS0tLS0tLQp6aGFvd3V5dW5Ad2luZ3RlY2guY29t
