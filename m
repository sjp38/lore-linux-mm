Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id DAD466B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 03:53:04 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so21532611pac.3
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 00:53:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id dx2si10044148pab.128.2015.08.06.00.53.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Aug 2015 00:53:04 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t767r0At020149
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 6 Aug 2015 16:53:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] smaps: fill missing fields for vma(VM_HUGETLB)
Date: Thu, 6 Aug 2015 07:44:44 +0000
Message-ID: <20150806074443.GA7870@hori1.linux.bs1.fc.nec.co.jp>
References: <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com>
 <20150728222654.GA28456@Sligo.logfs.org>
 <alpine.DEB.2.10.1507281622470.10368@chino.kir.corp.google.com>
 <20150729005332.GB17938@Sligo.logfs.org>
 <alpine.DEB.2.10.1507291205590.24373@chino.kir.corp.google.com>
 <55B95FDB.1000801@oracle.com>
 <20150804025530.GA13210@hori1.linux.bs1.fc.nec.co.jp>
 <20150804051339.GA24931@hori1.linux.bs1.fc.nec.co.jp>
 <20150804182158.GH14335@Sligo.logfs.org>
 <alpine.DEB.2.10.1508051917430.4843@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1508051917430.4843@chino.kir.corp.google.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <ABC6F904EE674643A446880AED11F08D@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

T24gV2VkLCBBdWcgMDUsIDIwMTUgYXQgMDc6MTg6NDRQTSAtMDcwMCwgRGF2aWQgUmllbnRqZXMg
d3JvdGU6DQouLi4NCj4gSG1tLCB3b3VsZG4ndCB0aGlzIGJlIGNvbmZ1c2luZyBzaW5jZSBWbVJT
UyBpbiAvcHJvYy9waWQvc3RhdHVzIGRvZXNuJ3QgDQo+IG1hdGNoIHRoZSByc3Mgc2hvd24gaW4g
c21hcHMsIHNpbmNlIGh1Z2V0bGIgbWFwcGluZ3MgYXJlbid0IGFjY291bnRlZCBpbiANCj4gZ2V0
X21tX3JzcygpPw0KPiANCj4gTm90IHN1cmUgdGhpcyBpcyBhIGdvb2QgaWRlYSwgSSB0aGluayBj
b25zaXN0ZW5jeSBhbW9uZ3N0IHJzcyB2YWx1ZXMgd291bGQgDQo+IGJlIG1vcmUgaW1wb3J0YW50
Lg0KDQpSaWdodCwgc28gb25lIG9wdGlvbiBpcyBtYWtpbmcgZ2V0X21tX3JzcygpIGNvdW50IGh1
Z2V0bGIsIGJ1dCB0aGF0IGNvdWxkDQptYWtlIG9vbS9tZW1jZyBsZXNzIGVmZmljaWVudCBvciBi
cm9rZW4gYXMgeW91IHN0YXRlZCBpbiBhIHByZXZpb3VzIGVtYWlsLg0KU28gYW5vdGhlciBvbmUg
aXMgdG8gYWRkICJWbUh1Z2V0bGJSU1M6IiBmaWVsZCBpbiAvcHJvYy9waWQvc3RhdHVzPw0KDQpU
aGFua3MsDQpOYW95YSBIb3JpZ3VjaGk=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
