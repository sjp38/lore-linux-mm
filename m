Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4946B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 04:48:04 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so17630332pad.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 01:48:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id fo16si6386278pdb.235.2015.08.20.01.48.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 01:48:03 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t7K8m0ow018822
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 17:48:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v5 0/2] hugetlb: display per-process/per-vma usage
Date: Thu, 20 Aug 2015 08:26:26 +0000
Message-ID: <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

VGhlIHByZXZpb3VzIHZlcnNpb24gaGFkIGJ1aWxkIGlzc3VlcyBpbiBzb21lIGFyY2hpdGVjdHVy
ZXMsIGJlY2F1c2UgaXQNCnJlcXVpcmVkIHRvIG1vdmUgdGhlIGRlZmluaXRpb24gb2YgSFVHRV9N
QVhfSFNUQVRFIGFjcm9zcyBoZWFkZXIgZmlsZXMNCmluIG9yZGVyIHRvIGVtYmVkIGEgbmV3IGRh
dGEgc3RydWN0dXJlIHN0cnVjdCBodWdldGxiX3VzYWdlIGludG8gc3RydWN0DQptbV9zdHJ1Y3Qu
IFRoaXMgd2FzIGEgaGFyZCBwcm9ibGVtIHRvIHNvbHZlLCBzbyBJIHRvb2sgYW5vdGhlciBhcHBy
b2FjaA0KaW4gdGhpcyB2ZXJzaW9uLCB3aGVyZSBJIGFkZCBqdXN0IGEgcG9pbnRlciAoc3RydWN0
IGh1Z2V0bGJfdXNhZ2UgKikgdG8NCnN0cnVjdCBtbV9zdHJ1Y3QgYW5kIGR5bmFtaWNhbGx5IGFs
bG9jYXRlIGFuZCBsaW5rIGl0Lg0KVGhpcyBtYWtlcyB0aGUgY2hhbmdlcyBsYXJnZXIsIGJ1dCBu
byBidWlsZCBpc3N1ZXMuDQoNClRoYW5rcywNCk5hb3lhIEhvcmlndWNoaQ0KLS0tDQpTdW1tYXJ5
Og0KDQpOYW95YSBIb3JpZ3VjaGkgKDIpOg0KICAgICAgbW06IGh1Z2V0bGI6IHByb2M6IGFkZCBI
dWdldGxiUGFnZXMgZmllbGQgdG8gL3Byb2MvUElEL3NtYXBzDQogICAgICBtbTogaHVnZXRsYjog
cHJvYzogYWRkIEh1Z2V0bGJQYWdlcyBmaWVsZCB0byAvcHJvYy9QSUQvc3RhdHVzDQoNCiBEb2N1
bWVudGF0aW9uL2ZpbGVzeXN0ZW1zL3Byb2MudHh0IHwgMTAgKysrKysrKy0tDQogZnMvaHVnZXRs
YmZzL2lub2RlLmMgICAgICAgICAgICAgICB8IDEyICsrKysrKysrKysNCiBmcy9wcm9jL3Rhc2tf
bW11LmMgICAgICAgICAgICAgICAgIHwgMzAgKysrKysrKysrKysrKysrKysrKysrKysrKw0KIGlu
Y2x1ZGUvbGludXgvaHVnZXRsYi5oICAgICAgICAgICAgfCAzNiArKysrKysrKysrKysrKysrKysr
KysrKysrKysrKw0KIGluY2x1ZGUvbGludXgvbW1fdHlwZXMuaCAgICAgICAgICAgfCAgNyArKysr
KysNCiBrZXJuZWwvZm9yay5jICAgICAgICAgICAgICAgICAgICAgIHwgIDMgKysrDQogbW0vaHVn
ZXRsYi5jICAgICAgICAgICAgICAgICAgICAgICB8IDQ2ICsrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrDQogbW0vbW1hcC5jICAgICAgICAgICAgICAgICAgICAgICAgICB8ICAx
ICsNCiBtbS9ybWFwLmMgICAgICAgICAgICAgICAgICAgICAgICAgIHwgIDQgKysrLQ0KIDkgZmls
ZXMgY2hhbmdlZCwgMTQ2IGluc2VydGlvbnMoKyksIDMgZGVsZXRpb25zKC0p

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
