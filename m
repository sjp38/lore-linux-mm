Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 17B716B0280
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:13 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m188so2554230qkd.15
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:25:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u66si642461qkd.334.2018.03.21.12.25.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:25:12 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJIaNe064383
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:11 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gurspnwpp-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:10 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:25:08 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 28/32] docs/vm: z3fold.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:44 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-29-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/z3fold.txt | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/Documentation/vm/z3fold.txt b/Documentation/vm/z3fold.txt
index 38e4dac..224e3c6 100644
--- a/Documentation/vm/z3fold.txt
+++ b/Documentation/vm/z3fold.txt
@@ -1,5 +1,8 @@
+.. _z3fold:
+
+======
 z3fold
-------
+======
 
 z3fold is a special purpose allocator for storing compressed pages.
 It is designed to store up to three compressed pages per physical page.
@@ -7,6 +10,7 @@ It is a zbud derivative which allows for higher compression
 ratio keeping the simplicity and determinism of its predecessor.
 
 The main differences between z3fold and zbud are:
+
 * unlike zbud, z3fold allows for up to PAGE_SIZE allocations
 * z3fold can hold up to 3 compressed pages in its page
 * z3fold doesn't export any API itself and is thus intended to be used
-- 
2.7.4
