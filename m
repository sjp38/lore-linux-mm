Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f53.google.com (mail-qe0-f53.google.com [209.85.128.53])
	by kanga.kvack.org (Postfix) with ESMTP id F288E6B0038
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:30:15 -0500 (EST)
Received: by mail-qe0-f53.google.com with SMTP id nc12so4412429qeb.26
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 11:30:15 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id q6si12921087qag.72.2013.12.10.11.30.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 11:30:14 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 0/2] mm: memblock: Couple of kbuild fixes after the memblock series
Date: Tue, 10 Dec 2013 14:29:56 -0500
Message-ID: <1386703798-26521-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Russell King <linux@arm.linux.org.uk>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>

Andrew,

Thanks to kbuild which almost covers all the architectures builds, couple
of build related issues poped up after the memblock series applied [1]

This series tries to address those build issues.

Cc: Russell King <linux@arm.linux.org.uk>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Grygorii Strashko (2):
  mm/ARM: dma: fix conflicting types for 'arm_dma_zone_size'
  mm/memblock: fix buld of "cris" arch

 arch/arm/include/asm/dma.h |    2 +-
 include/linux/bootmem.h    |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

Regards,
Santosh

[1] https://lkml.org/lkml/2013/12/9/715 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
