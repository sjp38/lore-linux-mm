Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57FF66B0025
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v6so2973072wrg.8
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:23:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z24si699334edm.84.2018.03.21.12.23.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:23:16 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJIaJC009043
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:14 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gut8117m3-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:14 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:23:12 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 02/32] docs/vm: balance: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:18 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/balance | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/Documentation/vm/balance b/Documentation/vm/balance
index 9645954..6a1fadf 100644
--- a/Documentation/vm/balance
+++ b/Documentation/vm/balance
@@ -1,3 +1,9 @@
+.. _balance:
+
+================
+Memory Balancing
+================
+
 Started Jan 2000 by Kanoj Sarcar <kanoj@sgi.com>
 
 Memory balancing is needed for !__GFP_ATOMIC and !__GFP_KSWAPD_RECLAIM as
@@ -62,11 +68,11 @@ for non-sleepable allocations. Second, the HIGHMEM zone is also balanced,
 so as to give a fighting chance for replace_with_highmem() to get a
 HIGHMEM page, as well as to ensure that HIGHMEM allocations do not
 fall back into regular zone. This also makes sure that HIGHMEM pages
-are not leaked (for example, in situations where a HIGHMEM page is in 
+are not leaked (for example, in situations where a HIGHMEM page is in
 the swapcache but is not being used by anyone)
 
 kswapd also needs to know about the zones it should balance. kswapd is
-primarily needed in a situation where balancing can not be done, 
+primarily needed in a situation where balancing can not be done,
 probably because all allocation requests are coming from intr context
 and all process contexts are sleeping. For 2.3, kswapd does not really
 need to balance the highmem zone, since intr context does not request
@@ -89,7 +95,8 @@ pages is below watermark[WMARK_LOW]; in which case zone_wake_kswapd is also set.
 
 
 (Good) Ideas that I have heard:
+
 1. Dynamic experience should influence balancing: number of failed requests
-for a zone can be tracked and fed into the balancing scheme (jalvo@mbay.net)
+   for a zone can be tracked and fed into the balancing scheme (jalvo@mbay.net)
 2. Implement a replace_with_highmem()-like replace_with_regular() to preserve
-dma pages. (lkd@tantalophile.demon.co.uk)
+   dma pages. (lkd@tantalophile.demon.co.uk)
-- 
2.7.4
