Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7C78482F64
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 05:18:03 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so15496354pad.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:18:03 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id tc9si3869841pac.230.2015.09.17.02.18.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 17 Sep 2015 02:18:02 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t8H9I0lF011342
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 18:18:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v6 0/2] hugetlb: display per-process/per-vma usage
Date: Thu, 17 Sep 2015 09:09:31 +0000
Message-ID: <1442480955-7297-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <211E167D121E5F49BC42F1DB91CAE4CC@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, =?utf-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>, David Rientjes <rientjes@google.com>, =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

SGkgZXZlcnlvbmUsDQoNCkkgdXBkYXRlZCB0aGUgc2VyaWVzIGFnYWluc3QgdjQuMy1yYzEuDQpJ
biBwYXRjaCAxLzIsIGEgbmV3IGZpZWxkcyBpcyBzcGxpdCBpbnRvIHR3byB0byBpZGVudGlmeSBz
aGFyZWQvcHJpdmF0ZQ0KbWFwcGluZyAodGhhbmtzIHRvIFDDoWRyYWlnKS4NCkFuZCBJIGRyb3Bw
ZWQgc2hvd2luZyBwZXItaHVnZXBhZ2VzaXplIGluZm8gaW4gL3Byb2MvUElEL3N0YXR1cyBpbiBw
YXRjaA0KMi8yIGJlY2F1c2UgdGhlcmUgd2VyZSBvYmplY3Rpb25zIG9uIHRoaXMgcGFydC4gVGhp
cyBzYXZlcyBsaW5lcyBvZiBkaWZmLg0KDQpUaGFua3MsDQpOYW95YSBIb3JpZ3VjaGkNCi0tLQ0K
U3VtbWFyeToNCg0KTmFveWEgSG9yaWd1Y2hpICgyKToNCiAgICAgIG1tOiBodWdldGxiOiBwcm9j
OiBhZGQgaHVnZXRsYi1yZWxhdGVkIGZpZWxkcyB0byAvcHJvYy9QSUQvc21hcHMNCiAgICAgIG1t
OiBodWdldGxiOiBwcm9jOiBhZGQgSHVnZXRsYlBhZ2VzIGZpZWxkIHRvIC9wcm9jL1BJRC9zdGF0
dXMNCg0KIERvY3VtZW50YXRpb24vZmlsZXN5c3RlbXMvcHJvYy50eHQgfCAxMCArKysrKysrKysr
DQogZnMvcHJvYy90YXNrX21tdS5jICAgICAgICAgICAgICAgICB8IDM5ICsrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrDQogaW5jbHVkZS9saW51eC9odWdldGxiLmggICAgICAg
ICAgICB8IDE5ICsrKysrKysrKysrKysrKysrKysNCiBpbmNsdWRlL2xpbnV4L21tX3R5cGVzLmgg
ICAgICAgICAgIHwgIDMgKysrDQogbW0vaHVnZXRsYi5jICAgICAgICAgICAgICAgICAgICAgICB8
ICA5ICsrKysrKysrKw0KIG1tL3JtYXAuYyAgICAgICAgICAgICAgICAgICAgICAgICAgfCAgNCAr
KystDQogNiBmaWxlcyBjaGFuZ2VkLCA4MyBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0p

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
