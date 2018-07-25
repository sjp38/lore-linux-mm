Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 186626B0277
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 05:53:57 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g12-v6so4673842ioh.5
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 02:53:57 -0700 (PDT)
Received: from mail.wingtech.com (mail.wingtech.com. [180.166.216.14])
        by mx.google.com with ESMTPS id s188-v6si3115376itd.113.2018.07.25.02.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Jul 2018 02:53:54 -0700 (PDT)
Date: Wed, 25 Jul 2018 17:53:07 +0800
From: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Subject: Re: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
References: <2018072514375722198958@wingtech.com>,
	<20180725074009.GU28386@dhcp22.suse.cz>,
	<2018072515575576668668@wingtech.com>,
	<20180725082100.GV28386@dhcp22.suse.cz>
Mime-Version: 1.0
Message-ID: <2018072517530727482074@wingtech.com>
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: mgorman <mgorman@techsingularity.net>, akpm <akpm@linux-foundation.org>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

PltQbGVhc2UgZG8gbm90IHRvcCBwb3N0IC0gdGhhbmsgeW91XQo+W0NDIEh1Z2ggLSB0aGUgb3Jp
Z2luYWwgcGF0Y2ggd2FzIGh0dHA6Ly9sa21sLmtlcm5lbC5vcmcvci8yMDE4MDcyNTE0Mzc1NzIy
MTk4OTU4QHdpbmd0ZWNoLmNvbV0KPgo+T24gV2VkIDI1LTA3LTE4IDE1OjU3OjU1LCB6aGFvd3V5
dW5Ad2luZ3RlY2guY29tIHdyb3RlOgo+PiBUaGF0IGlzIGEgQlVHIHdlIGZvdW5kIGluIG1tL3Zt
c2Nhbi5jIGF0IEtFUk5FTCBWRVJTSU9OIDQuOS44Mgo+Cj5UaGUgY29kZSBpcyBxdWl0ZSBzaW1p
bGFyIGluIHRoZSBjdXJyZW50IHRyZWUgYXMgd2VsbC4KPgo+PiBTdW1hcnkgaXMgVEFTSyBBIChu
b3JtYWwgcHJpb3JpdHkpIGRvaW5nIF9fcmVtb3ZlX21hcHBpbmcgcGFnZSBwcmVlbXB0ZWQgYnkg
VEFTSyBCIChSVCBwcmlvcml0eSkgZG9pbmcgX19yZWFkX3N3YXBfY2FjaGVfYXN5bmMsCj4+IHRo
ZSBUQVNLIEEgcHJlZW1wdGVkIGJlZm9yZSBzd2FwY2FjaGVfZnJlZSwgbGVmdCBTV0FQX0hBU19D
QUNIRSBmbGFnIGluIHRoZSBzd2FwIGNhY2hlLAo+PiB0aGUgVEFTSyBCIHdoaWNoIGRvaW5nIF9f
cmVhZF9zd2FwX2NhY2hlX2FzeW5jLCB3aWxsIG5vdCBzdWNjZXNzIGF0IHN3YXBjYWNoZV9wcmVw
YXJlKGVudHJ5KSBiZWNhdXNlIHRoZSBzd2FwIGNhY2hlIHdhcyBleGlzdCwgdGhlbiBpdCB3aWxs
IGxvb3AgZm9yZXZlciBiZWNhdXNlIGl0IGlzIGEgUlQgdGhyZWFkLi4uCj4+IHRoZSBzcGluIGxv
Y2sgdW5sb2NrZWQgYmVmb3JlIHN3YXBjYWNoZV9mcmVlLCBzbyBkaXNhYmxlIHByZWVtcHRpb24g
dW50aWwgc3dhcGNhY2hlX2ZyZWUgZXhlY3V0ZWQgLi4uCj4KPk9LLCBJIHNlZSB5b3VyIHBvaW50
IG5vdy4gSSBoYXZlIG1pc3NlZCB0aGUgbG9jayBpcyBkcm9wcGVkIGJlZm9yZQo+c3dhcGNhY2hl
X2ZyZWUuIEhvdyBjYW4gcHJlZW1wdGlvbiBkaXNhYmxpbmcgcHJldmVudCB0aGlzIHJhY2UgdG8g
aGFwcGVuCj53aGlsZSB0aGUgY29kZSBpcyBwcmVlbXB0ZWQgYnkgYW4gSVJRPwo+LS0KPk1pY2hh
bCBIb2Nrbwo+U1VTRSBMYWJzIAoKSGkgTWljaGFsLAoKVGhlIGFjdGlvbiB3aGF0IHByb2Nlc3Nl
cyBfX3JlYWRfc3dhcF9jYWNoZV9hc3luYyBpcyBvbiB0aGUgcHJvY2VzcyBjb250ZXh0LCBzbyBJ
IHRoaW5rIGRpc2FibGUgcHJlZW1wdGlvbiBpcyBlbm91Z2guCgotLS0tLS0tLS0tLS0tLQp6aGFv
d3V5dW5Ad2luZ3RlY2guY29t
