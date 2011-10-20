Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB3A6B0035
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 02:01:18 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LTC00MK2OQ3K4@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 20 Oct 2011 07:01:16 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LTC008TEOQ3BQ@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 20 Oct 2011 07:01:15 +0100 (BST)
Date: Thu, 20 Oct 2011 08:01:12 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: CMA v16 and DMA-mapping v13 patch series
Message-id: <ADF13DA15EB3FE4FBA487CCC7BEFDF3622549EBE58@bssrvexch01>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-language: en-US
Content-transfer-encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>
Cc: 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Jesse Barker' <jesse.barker@linaro.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, 'Subash Patel' <subashrp@gmail.com>, Joerg Roedel <joro@8bytes.org>, Shariq Hasnain <shariq.hasnain@linaro.org>Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>

SGVsbG8gZXZlcnlvbmUsDQoNCkl0IGxvb2tzIHRoYXQgdGhlIGxhc3QgcGF0Y2ggc2VyaWVzIGZy
b20gbWUgd2FzIG5vdCBjbGVhcmx5IGRlc2NyaWJlZCBpbiB0ZXJtcw0Kb2YgdGhlaXIga2VybmVs
IGJhc2UuIFNlbGVjdGluZyBhICctbmV4dCcga2VybmVsIGFzIGEgYmFzZSB3YXMgbm90IHRoZSBi
ZXN0DQppZGVhLiBJJ20gcmVhbGx5IHNvcnJ5IGZvciB0aGUgY29uZnVzaW9uLiBJJ3ZlIHJlYmFz
ZWQgYWdhaW4gdGhlc2Ugc2VyaWVzIGFuZA0KcHJlcGFyZWQgMyBuZXcgYnJhbmNoZXMuIEZlZWwg
ZnJlZSB0byBkb3dubG9hZCBhbmQgZ2l2ZSB0aGVtIGEgdHJ5Lg0KDQpIZXJlIGFyZSB0aGUga2Vy
bmVsIHRyZWVzIHdpdGggbGF0ZXN0IHZlcnNpb24gb2YgdGhlIHBhdGNoZXMsIHJlYWR5IHRvIHVz
ZToNCg0KTGludXggdjMuMS1yYzEwIHdpdGggQ01BIHYxNiAoYW5kIGEgZmV3IGZpeGVzKToNCmdp
dDovL2dpdC5pbmZyYWRlYWQub3JnL3VzZXJzL2ttcGFyay9saW51eC0yLjYtc2Ftc3VuZyAzLjEt
cmMxMC1jbWEtdjE2DQoNCkxpbnV4IHYzLjEtcmMxMCB3aXRoIERNQSBtYXBwaW5nIHYzICh3aXRo
IERNQS1JT01NVSBpbnRlZ3JhdGlvbik6DQpnaXQ6Ly9naXQuaW5mcmFkZWFkLm9yZy91c2Vycy9r
bXBhcmsvbGludXgtMi42LXNhbXN1bmcgMy4xLXJjMTAtZG1hLXYzDQoNCkxpbnV4IHYzLjEtcmMx
MCB3aXRoIGJvdGggQ01BIHYxNiBhbmQgRE1BLW1hcHBpbmcgdjM6DQpnaXQ6Ly9naXQuaW5mcmFk
ZWFkLm9yZy91c2Vycy9rbXBhcmsvbGludXgtMi42LXNhbXN1bmcgMy4xLXJjMTAtY21hLXYxNi1k
bWEtdjMNCg0KQmVzdCByZWdhcmRzDQotLQ0KTWFyZWsgU3p5cHJvd3NraQ0KU2Ftc3VuZyBQb2xh
bmQgUiZEIENlbnRlcg0KDQoNCg0KVGhlIGFib3ZlIG1lc3NhZ2UgaXMgaW50ZW5kZWQgc29sZWx5
IGZvciB0aGUgbmFtZWQgYWRkcmVzc2VlIGFuZCBtYXkgY29udGFpbiB0cmFkZSBzZWNyZXQsIGlu
ZHVzdHJpYWwgdGVjaG5vbG9neSBvciBwcml2aWxlZ2VkIGFuZCBjb25maWRlbnRpYWwgaW5mb3Jt
YXRpb24gb3RoZXJ3aXNlIHByb3RlY3RlZCB1bmRlciBhcHBsaWNhYmxlIGxhdy4gQW55IHVuYXV0
aG9yaXplZCBkaXNzZW1pbmF0aW9uLCBkaXN0cmlidXRpb24sIGNvcHlpbmcgb3IgdXNlIG9mIHRo
ZSBpbmZvcm1hdGlvbiBjb250YWluZWQgaW4gdGhpcyBjb21tdW5pY2F0aW9uIGlzIHN0cmljdGx5
IHByb2hpYml0ZWQuIElmIHlvdSBoYXZlIHJlY2VpdmVkIHRoaXMgY29tbXVuaWNhdGlvbiBpbiBl
cnJvciwgcGxlYXNlIG5vdGlmeSBzZW5kZXIgYnkgZW1haWwgYW5kIGRlbGV0ZSB0aGlzIGNvbW11
bmljYXRpb24gaW1tZWRpYXRlbHkuDQoNCg0KUG93ecW8c3phIHdpYWRvbW/Fm8SHIHByemV6bmFj
em9uYSBqZXN0IHd5xYLEhWN6bmllIGRsYSBhZHJlc2F0YSBuaW5pZWpzemVqIHdpYWRvbW/Fm2Np
IGkgbW/FvGUgemF3aWVyYcSHIGluZm9ybWFjamUgYsSZZMSFY2UgdGFqZW1uaWPEhSBoYW5kbG93
xIUsIHRhamVtbmljxIUgcHJ6ZWRzacSZYmlvcnN0d2Egb3JheiBpbmZvcm1hY2plIG8gY2hhcmFr
dGVyemUgcG91Zm55bSBjaHJvbmlvbmUgb2Jvd2nEhXp1asSFY3ltaSBwcnplcGlzYW1pIHByYXdh
LiBKYWtpZWtvbHdpZWsgbmlldXByYXduaW9uZSBpY2ggcm96cG93c3plY2huaWFuaWUsIGR5c3Ry
eWJ1Y2phLCBrb3Bpb3dhbmllIGx1YiB1xbx5Y2llIGluZm9ybWFjamkgemF3YXJ0eWNoIHcgcG93
ecW8c3plaiB3aWFkb21vxZtjaSBqZXN0IHphYnJvbmlvbmUuIEplxZtsaSBvdHJ6eW1hxYJlxZsg
cG93ecW8c3rEhSB3aWFkb21vxZvEhyBvbXnFgmtvd28sIHVwcnplam1pZSBwcm9zesSZIHBvaW5m
b3JtdWogbyB0eW0gZmFrY2llIGRyb2fEhSBtYWlsb3fEhSBuYWRhd2PEmSB0ZWogd2lhZG9tb8Wb
Y2kgb3JheiBuaWV6d8WCb2N6bmllIHVzdcWEIHBvd3nFvHN6xIUgd2lhZG9tb8WbxIcgemUgc3dv
amVnbyBrb21wdXRlcmEuDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
