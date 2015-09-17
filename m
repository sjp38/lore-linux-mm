Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2F21F6B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 05:58:04 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so16238778pad.3
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:58:03 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id ne9si4191154pbc.29.2015.09.17.02.58.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 17 Sep 2015 02:58:03 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t8H9w0Jj017521
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 18:58:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v5 1/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/smaps
Date: Thu, 17 Sep 2015 09:39:15 +0000
Message-ID: <20150917093914.GA18723@hori1.linux.bs1.fc.nec.co.jp>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <55ECE891.7030309@draigBrady.com>
 <20150907022343.GB6448@hori1.linux.bs1.fc.nec.co.jp>
 <20150907064614.GB7229@hori1.linux.bs1.fc.nec.co.jp>
 <55ED5E6C.6000102@draigBrady.com> <55ED6C79.6030000@draigBrady.com>
In-Reply-To: <55ED6C79.6030000@draigBrady.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <0AAEA283A6BE174BA64F0DB0054021A5@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

T24gTW9uLCBTZXAgMDcsIDIwMTUgYXQgMTE6NTI6NDFBTSArMDEwMCwgUMOhZHJhaWcgQnJhZHkg
d3JvdGU6DQouLi4NCj4gDQo+IEJ5IHRoZSBzYW1lIGFyZ3VtZW50IEkgcHJlc3VtZSB0aGUgZXhp
c3RpbmcgVEhQICJBbm9uSHVnZVBhZ2VzIiBzbWFwcyBmaWVsZA0KPiBpcyBub3QgYWNjb3VudGVk
IGZvciBpbiB0aGUge1ByaXZhdGUsU2hhcmVkfV8uLi4gZmllbGRzPw0KPiBJLkUuIEFub25IdWdl
UGFnZXMgbWF5IGFsc28gYmVuZWZpdCBmcm9tIHNwbGl0dGluZyB0byBQcml2YXRlL1NoYXJlZD8N
Cg0Kc21hcHNfcG1kX2VudHJ5KCkgbm90IG9ubHkgaW5jcmVtZW50cyBtc3MtPmFub255bW91c190
aHAsIGJ1dCBhbHNvIGNhbGxzDQpzbWFwc19hY2NvdW50KCkgd2hpY2ggdXBkYXRlcyBtc3MtPmFu
b255bW91cywgbXNzLT5yZWZlcmVuY2VkIGFuZA0KbXNzLT57c2hhcmVkLHByaXZhdGV9X3tjbGVh
bixkaXJ0eX0sIHNvIHRocCdzIHNoYXJlZC9wcml2YXRlIGNoYXJhY3RlcmlzdGljDQppcyBpbmNs
dWRlZCBpbiBvdGhlciBleGlzdGluZyBmaWVsZHMuDQpJIHRoaW5rIHRoYXQgZXZlbiBpZiB3ZSBr
bm93IHRoZSB0aHAtc3BlY2lmaWMgc2hhcmVkL3ByaXZhdGUgcHJvZmlsZXMsIGl0DQptaWdodCBi
ZSBoYXJkIHRvIGRvIHNvbWV0aGluZyBiZW5lZmljaWFsIHVzaW5nIHRoYXQgaW5mb3JtYXRpb24s
IHNvIEkgZmVlbA0Ka2VlcGluZyB0aGlzIGZpZWxkIGFzLWlzIGlzIG9rIGZvciBub3cuDQoNClRo
YW5rcywNCk5hb3lhIEhvcmlndWNoaQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
