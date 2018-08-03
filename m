Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3996B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 15:59:06 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v4-v6so5652024oix.2
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 12:59:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w187-v6si3789894oib.128.2018.08.03.12.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 12:59:05 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w73Jx4ZX186716
	for <linux-mm@kvack.org>; Fri, 3 Aug 2018 15:59:04 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kmt6sfp02-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Aug 2018 15:59:04 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 3 Aug 2018 20:58:59 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH RESEND 0/7] switch several architectures NO_BOOTMEM
Date: Fri,  3 Aug 2018 22:58:43 +0300
Message-Id: <1533326330-31677-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Kuo <rkuo@codeaurora.org>, Ley Foon Tan <lftan@altera.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@pku.edu.cn>, Michal Hocko <mhocko@kernel.org>, linux-hexagon@vger.kernel.org, nios2-dev@lists.rocketboards.org, linux-um@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>


Hi,

These patches perform conversion to NO_BOOTMEM of hexagon, nios2, uml and
unicore32. The architecture maintainers have acked the patches, but, since
I've got no confirmation the patches are going through the arch tree I'd
appreciate if the set would be applied to the -mm tree.

Mike Rapoport (7):
  hexagon: switch to NO_BOOTMEM
  of: ignore sub-page memory regions
  nios2: use generic early_init_dt_add_memory_arch
  nios2: switch to NO_BOOTMEM
  um: setup_physmem: stop using global variables
  um: switch to NO_BOOTMEM
  unicore32: switch to NO_BOOTMEM

 arch/hexagon/Kconfig      |  3 +++
 arch/hexagon/mm/init.c    | 20 +++++++-----------
 arch/nios2/Kconfig        |  3 +++
 arch/nios2/kernel/prom.c  | 17 ---------------
 arch/nios2/kernel/setup.c | 39 ++++++----------------------------
 arch/um/Kconfig.common    |  2 ++
 arch/um/kernel/physmem.c  | 22 +++++++++----------
 arch/unicore32/Kconfig    |  1 +
 arch/unicore32/mm/init.c  | 54 +----------------------------------------------
 drivers/of/fdt.c          | 11 +++++-----
 10 files changed, 41 insertions(+), 131 deletions(-)

-- 
2.7.4
