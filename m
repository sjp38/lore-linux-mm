Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id DDD986B0253
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:03:26 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id yy13so30504274pab.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 03:03:26 -0800 (PST)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0060.outbound.protection.outlook.com. [157.56.110.60])
        by mx.google.com with ESMTPS id b90si11869506pfj.165.2016.02.25.03.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Feb 2016 03:03:26 -0800 (PST)
From: Robert Richter <rrichter@caviumnetworks.com>
Subject: [PATCH 0/2] arm64, cma, gicv3-its: Use CMA for allocation of large device tables
Date: Thu, 25 Feb 2016 12:02:42 +0100
Message-ID: <1456398164-16864-1-git-send-email-rrichter@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Tirumalesh Chalamarla <tchalamarla@cavium.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>

From: Robert Richter <rrichter@cavium.com>

This series implements the use of CMA for allocation of large device
tables for the arm64 gicv3 interrupt controller.

There are 2 patches, the first is for early activation of cma, which
needs to be done before interrupt initialization to make it available
to the gicv3. The second implements the use of CMA to allocate
gicv3-its device tables.

This solves the problem where mem allocation is limited to 4MB. A
previous patch sent to the list to address this that instead increases
FORCE_MAX_ZONEORDER becomes obsolete.

Robert Richter (2):
  mm: cma: arm64: Introduce dma_activate_contiguous() for early
    activation
  irqchip, gicv3-its, cma: Use CMA for allocation of large device tables

 arch/arm64/kernel/irq.c          |  4 ++++
 drivers/base/dma-contiguous.c    | 14 ++++++++++++++
 drivers/irqchip/irq-gic-v3-its.c | 30 +++++++++++++++++++++---------
 include/linux/cma.h              |  1 +
 include/linux/dma-contiguous.h   |  8 ++++++++
 mm/cma.c                         |  6 +++++-
 6 files changed, 53 insertions(+), 10 deletions(-)

-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
