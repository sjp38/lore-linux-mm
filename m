Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 749576B0075
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 17:26:59 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id gq1so13545274obb.2
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 14:26:59 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d84si200243oif.24.2015.02.12.14.26.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Feb 2015 14:26:58 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH v5 0/3] mm: cma: debugfs access to CMA
Date: Thu, 12 Feb 2015 17:26:45 -0500
Message-Id: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: iamjoonsoo.kim@lge.com, m.szyprowski@samsung.com, akpm@linux-foundation.org, lauraa@codeaurora.org, s.strogin@partner.samsung.com, Sasha Levin <sasha.levin@oracle.com>

I've noticed that there is no interfaces exposed by CMA which would let me
fuzz what's going on in there.

This small patch set exposes some information out to userspace, plus adds
the ability to trigger allocation and freeing from userspace.

Changes from v4:
 - Inform user if he has attempted to free a partial block when the page
order != 0.

Changes from v3:
 - Minor build fix, sent incorrect patch for v3

Changes from v2:
 - Keep allocated memory lists per-cma
 - Don't allow partial free with non-zero order_per_bit
 - Use 0 alignment

Changes from v1:
 - Make allocation and free hooks per-cma.
 - Remove additional debug prints.

Sasha Levin (3):
  mm: cma: debugfs interface
  mm: cma: allocation trigger
  mm: cma: release trigger

 mm/Kconfig     |    6 ++
 mm/Makefile    |    1 +
 mm/cma.c       |   25 ++++-----
 mm/cma.h       |   24 ++++++++
 mm/cma_debug.c |  170 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 211 insertions(+), 15 deletions(-)
 create mode 100644 mm/cma.h
 create mode 100644 mm/cma_debug.c

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
