Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 612AC6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:10:58 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p5so49740999qtb.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:10:58 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id y15si1654860plh.90.2017.03.13.15.10.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 15:10:57 -0700 (PDT)
From: Krishna Reddy <vdumpa@nvidia.com>
Subject: RE: [HMM v17 09/14] mm/hmm/mirror: mirror process address space on
 device with HMM helpers
Date: Mon, 13 Mar 2017 22:10:56 +0000
Message-ID: <cb3d586c5f8b49c18443c6eb2341136a@HQMAIL107.nvidia.com>
References: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
 <1485557541-7806-10-git-send-email-jglisse@redhat.com>
In-Reply-To: <1485557541-7806-10-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny
 Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

Ky8qDQorICogc3RydWN0IGhtbV9taXJyb3Jfb3BzIC0gSE1NIG1pcnJvciBkZXZpY2Ugb3BlcmF0
aW9ucyBjYWxsYmFjaw0KKyAqDQorICogQHVwZGF0ZTogY2FsbGJhY2sgdG8gdXBkYXRlIHJhbmdl
IG9uIGEgZGV2aWNlICAqLyBzdHJ1Y3QgDQoraG1tX21pcnJvcl9vcHMgew0KKwkvKiB1cGRhdGUo
KSAtIHVwZGF0ZSB2aXJ0dWFsIGFkZHJlc3MgcmFuZ2Ugb2YgbWVtb3J5DQorCSAqDQorCSAqIEBt
aXJyb3I6IHBvaW50ZXIgdG8gc3RydWN0IGhtbV9taXJyb3INCisJICogQHVwZGF0ZTogdXBkYXRl
J3MgdHlwZSAodHVybiByZWFkIG9ubHksIHVubWFwLCAuLi4pDQorCSAqIEBzdGFydDogdmlydHVh
bCBzdGFydCBhZGRyZXNzIG9mIHRoZSByYW5nZSB0byB1cGRhdGUNCisJICogQGVuZDogdmlydHVh
bCBlbmQgYWRkcmVzcyBvZiB0aGUgcmFuZ2UgdG8gdXBkYXRlDQouLi4uLi4uDQorCSAqLw0KKwl2
b2lkICgqdXBkYXRlKShzdHJ1Y3QgaG1tX21pcnJvciAqbWlycm9yLA0KKwkJICAgICAgIGVudW0g
aG1tX3VwZGF0ZSBhY3Rpb24sDQorCQkgICAgICAgdW5zaWduZWQgbG9uZyBzdGFydCwNCisJCSAg
ICAgICB1bnNpZ25lZCBsb25nIGVuZCk7DQorfTsNCg0KbWlub3IgYXJnIGRvY3VtZW50YXRpb24g
aXNzdWUuIEB1cGRhdGUgc2hvdWxkIGJlIEBhY3Rpb24uIA0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
