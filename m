Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 959E26B026F
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 09:18:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r15-v6so2179709edq.22
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 06:18:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r8-v6si405408edc.269.2018.07.04.06.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 06:18:27 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w64D9oxm080201
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 09:18:25 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0we04bg7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 09:18:24 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 14:18:22 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/3] nios2: switch to NO_BOOTMEM
Date: Wed,  4 Jul 2018 16:18:12 +0300
Message-Id: <1530710295-10774-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ley Foon Tan <lftan@altera.com>
Cc: Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Michal Hocko <mhocko@kernel.org>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

These patches switch nios2 boot time memory allocators from bootmem to
memblock + no_bootmem.

As nios2 uses fdt, the conversion is pretty much about actually using the
existing fdt infrastructure for the early memory management.

The first patch in the series is not strictly related to nios2. It's just
I've got really interesting memory layout without it because of 1K long
memory ranges defined in arch/nios2/boot/dts/10m50_devboard.dts.

Mike Rapoport (3):
  of: ignore sub-page memory regions
  nios2: use generic early_init_dt_add_memory_arch
  nios2: switch to NO_BOOTMEM

 arch/nios2/Kconfig        |  3 +++
 arch/nios2/kernel/prom.c  | 17 -----------------
 arch/nios2/kernel/setup.c | 39 +++++++--------------------------------
 drivers/of/fdt.c          | 11 ++++++-----
 4 files changed, 16 insertions(+), 54 deletions(-)

-- 
2.7.4
