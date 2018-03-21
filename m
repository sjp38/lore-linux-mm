Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5EC6B025F
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:24:36 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id l9so3718064qkk.17
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:24:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u31si5250743qta.473.2018.03.21.12.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:24:35 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJKjbk072243
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:24:34 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gurspnw0n-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:24:34 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:24:31 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 20/32] docs/vm: remap_file_pages.txt: conert to ReST format
Date: Wed, 21 Mar 2018 21:22:36 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-21-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/remap_file_pages.txt | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/Documentation/vm/remap_file_pages.txt b/Documentation/vm/remap_file_pages.txt
index f609142..7bef671 100644
--- a/Documentation/vm/remap_file_pages.txt
+++ b/Documentation/vm/remap_file_pages.txt
@@ -1,3 +1,9 @@
+.. _remap_file_pages:
+
+==============================
+remap_file_pages() system call
+==============================
+
 The remap_file_pages() system call is used to create a nonlinear mapping,
 that is, a mapping in which the pages of the file are mapped into a
 nonsequential order in memory. The advantage of using remap_file_pages()
-- 
2.7.4
