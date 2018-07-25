Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 333F16B027F
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:18:31 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j17-v6so7129547oii.8
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 04:18:31 -0700 (PDT)
Received: from mail.wingtech.com (mail.wingtech.com. [180.166.216.14])
        by mx.google.com with ESMTPS id b192-v6si10435877oii.88.2018.07.25.04.18.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Jul 2018 04:18:29 -0700 (PDT)
Date: Wed, 25 Jul 2018 19:17:34 +0800
From: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Subject: Re: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
References: <2018072514375722198958@wingtech.com>,
	<20180725074009.GU28386@dhcp22.suse.cz>,
	<2018072515575576668668@wingtech.com>,
	<20180725082100.GV28386@dhcp22.suse.cz>,
	<2018072517530727482074@wingtech.com>,
	<20180725103416.GZ28386@dhcp22.suse.cz>
Mime-Version: 1.0
Message-ID: <2018072519173409945881@wingtech.com>
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: mgorman <mgorman@techsingularity.net>, akpm <akpm@linux-foundation.org>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

Pk9uIFdlZCAyNS0wNy0xOCAxNzo1MzowNywgemhhb3d1eXVuQHdpbmd0ZWNoLmNvbSB3cm90ZToK
Pj4gPltQbGVhc2UgZG8gbm90IHRvcCBwb3N0IC0gdGhhbmsgeW91XQo+PiA+W0NDIEh1Z2ggLSB0
aGUgb3JpZ2luYWwgcGF0Y2ggd2FzIGh0dHA6Ly9sa21sLmtlcm5lbC5vcmcvci8yMDE4MDcyNTE0
Mzc1NzIyMTk4OTU4QHdpbmd0ZWNoLmNvbV0KPj4gPgo+PiA+T24gV2VkIDI1LTA3LTE4IDE1OjU3
OjU1LCB6aGFvd3V5dW5Ad2luZ3RlY2guY29tIHdyb3RlOgo+PiA+PiBUaGF0IGlzIGEgQlVHIHdl
IGZvdW5kIGluIG1tL3Ztc2Nhbi5jIGF0IEtFUk5FTCBWRVJTSU9OIDQuOS44Mgo+PiA+Cj4+ID5U
aGUgY29kZSBpcyBxdWl0ZSBzaW1pbGFyIGluIHRoZSBjdXJyZW50IHRyZWUgYXMgd2VsbC4KPj4g
Pgo+PiA+PiBTdW1hcnkgaXMgVEFTSyBBIChub3JtYWwgcHJpb3JpdHkpIGRvaW5nIF9fcmVtb3Zl
X21hcHBpbmcgcGFnZSBwcmVlbXB0ZWQgYnkgVEFTSyBCIChSVCBwcmlvcml0eSkgZG9pbmcgX19y
ZWFkX3N3YXBfY2FjaGVfYXN5bmMsCj4+ID4+IHRoZSBUQVNLIEEgcHJlZW1wdGVkIGJlZm9yZSBz
d2FwY2FjaGVfZnJlZSwgbGVmdCBTV0FQX0hBU19DQUNIRSBmbGFnIGluIHRoZSBzd2FwIGNhY2hl
LAo+PiA+PiB0aGUgVEFTSyBCIHdoaWNoIGRvaW5nIF9fcmVhZF9zd2FwX2NhY2hlX2FzeW5jLCB3
aWxsIG5vdCBzdWNjZXNzIGF0IHN3YXBjYWNoZV9wcmVwYXJlKGVudHJ5KSBiZWNhdXNlIHRoZSBz
d2FwIGNhY2hlIHdhcyBleGlzdCwgdGhlbiBpdCB3aWxsIGxvb3AgZm9yZXZlciBiZWNhdXNlIGl0
IGlzIGEgUlQgdGhyZWFkLi4uCj4+ID4+IHRoZSBzcGluIGxvY2sgdW5sb2NrZWQgYmVmb3JlIHN3
YXBjYWNoZV9mcmVlLCBzbyBkaXNhYmxlIHByZWVtcHRpb24gdW50aWwgc3dhcGNhY2hlX2ZyZWUg
ZXhlY3V0ZWQgLi4uCj4+ID4KPj4gPk9LLCBJIHNlZSB5b3VyIHBvaW50IG5vdy4gSSBoYXZlIG1p
c3NlZCB0aGUgbG9jayBpcyBkcm9wcGVkIGJlZm9yZQo+PiA+c3dhcGNhY2hlX2ZyZWUuIEhvdyBj
YW4gcHJlZW1wdGlvbiBkaXNhYmxpbmcgcHJldmVudCB0aGlzIHJhY2UgdG8gaGFwcGVuCj4+ID53
aGlsZSB0aGUgY29kZSBpcyBwcmVlbXB0ZWQgYnkgYW4gSVJRPwo+PiA+LS0KPj4gPk1pY2hhbCBI
b2Nrbwo+PiA+U1VTRSBMYWJzCj4+Cj4+IEhpIE1pY2hhbCwKPj4KPj4gVGhlIGFjdGlvbiB3aGF0
IHByb2Nlc3NlcyBfX3JlYWRfc3dhcF9jYWNoZV9hc3luYyBpcyBvbiB0aGUgcHJvY2VzcyBjb250
ZXh0LCBzbyBJIHRoaW5rIGRpc2FibGUgcHJlZW1wdGlvbiBpcyBlbm91Z2guCj4KPlNvIHdoYXQg
eW91IGFyZSBzYXlpbmcgaXMgdGhhdCBubyBJUlEgb3Igb3RoZXIgbm9uLXByb2Nlc3MgY29udGV4
dHMgd2lsbAo+bm90IGxvb3AgaW4gX19yZWFkX3N3YXBfY2FjaGVfYXN5bmMgc28gdGhlIGxpdmUg
bG9jayBpcyBub3QgcG9zc2libGU/Cj4tLQo+TWljaGFsIEhvY2tvCj5TVVNFIExhYnMgCgoKSSB0
aGluayB0aGF0IF9fcmVhZF9zd2FwX2NhY2hlX2FzeW5jIHdpbGwgbm90IHJ1bm5pbmcgdW5kZXIg
SVJRIGNvbnRleHRzLiAKSWYgcnVubmluZyB1bmRlcsKgb3RoZXIgbm9uLXByb2Nlc3MgY29udGV4
dHMsIEkgdGhpbmsgaXQgbXVzdCBhdCB0aGUgb3RoZXIgQ1BVLCB3aWxsIG5vdCBlbmNvdW50ZXIg
dGhpcyBkZWFkIGxvb3AuCgotLS0tLS0tLS0tLS0tLQp6aGFvd3V5dW5Ad2luZ3RlY2guY29t
