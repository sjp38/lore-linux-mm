Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52AD06B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:03 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id z143so99952830ywz.7
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 04:35:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d63si1966908ywc.365.2017.01.20.04.35.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 04:35:02 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0KCYYZP127498
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:02 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28302h9634-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:01 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Fri, 20 Jan 2017 12:35:00 -0000
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 0/3] memblock: physical memory list cleanups
Date: Fri, 20 Jan 2017 13:34:53 +0100
Message-Id: <20170120123456.46508-1-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Just a couple of trivial memblock patches, which could also be merged
into one patch; whatever is preferred.

Since commit 70210ed950b5 ("mm/memblock: add physical memory list")
the memblock structure knows about a physical memory list.

The memblock code should also print a sane name instead of "unknown"
if it calls memblock_type_name() to get a name for the physmem
memblock type.
In addition the physmem list should also be dumped, if present, and
memblock_dump_all is called to improve debugability.

The last patch embeds the memblock type name into the memblock type
structure in order to hopefully make the code a bit more easier and to
get rid of a bit of code duplication.

Thanks,
Heiko

Heiko Carstens (3):
  memblock: let memblock_type_name know about physmem type
  memblock: also dump physmem list within __memblock_dump_all
  memblock: embed memblock type name within struct memblock_type

 arch/s390/kernel/crash_dump.c |  1 +
 include/linux/memblock.h      |  1 +
 mm/memblock.c                 | 32 +++++++++++++-------------------
 3 files changed, 15 insertions(+), 19 deletions(-)

-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
