Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0D16B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:10 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w12-v6so16419635oie.12
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 22:57:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n67-v6si5929513oib.43.2018.07.22.22.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jul 2018 22:57:09 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6N5rvOX070966
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:08 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kd7vejx9m-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:08 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 23 Jul 2018 06:57:06 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/4] ia64: switch to NO_BOOTMEM
Date: Mon, 23 Jul 2018 08:56:54 +0300
Message-Id: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches convert ia64 to use NO_BOOTMEM.

The first two patches are cleanups, the third patches reduces usage of
'struct bootmem_data' for easier transition and the forth patch actually
replaces bootmem with memblock + nobootmem.

I've tested the sim_defconfig with the ski simulator and build tested other
defconfigs.

Mike Rapoport (4):
  ia64: contig/paging_init: reduce code duplication
  ia64: remove unused num_dma_physpages member from 'struct early_node_data'
  ia64: use mem_data to detect nodes' minimal and maximal PFNs
  ia64: switch to NO_BOOTMEM

 arch/ia64/Kconfig        |   1 +
 arch/ia64/kernel/setup.c |  11 +++-
 arch/ia64/mm/contig.c    |  75 +++-----------------------
 arch/ia64/mm/discontig.c | 134 ++++++-----------------------------------------
 4 files changed, 33 insertions(+), 188 deletions(-)

-- 
2.7.4
