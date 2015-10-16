Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A69896B0038
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 08:07:16 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so7576658wic.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 05:07:16 -0700 (PDT)
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com. [195.75.94.105])
        by mx.google.com with ESMTPS id my8si4757588wic.19.2015.10.16.05.07.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Oct 2015 05:07:15 -0700 (PDT)
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Oct 2015 13:07:15 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 542B81B08067
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 13:07:18 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9GC7CCa42860756
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 12:07:12 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9GC7AV0009792
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 06:07:11 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 0/3] mm/powerpc: enabling memory soft dirty tracking 
Date: Fri, 16 Oct 2015 14:07:05 +0200
Message-Id: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, xemul@parallels.com, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulus@samba.org
Cc: criu@openvz.org

This series is enabling the software memory dirty tracking in the
kernel for powerpc.  This is the follow up of the commit 0f8975ec4db2
("mm: soft-dirty bits for user memory changes tracking") which
introduced this feature in the mm code.

The first patch is fixing an issue in the code clearing the soft dirty
bit.  The PTE were not cleared before being modified, leading to hang
on ppc64.

The second patch is fixing a build issue when the transparent huge
page is not enabled.

The third patch is introducing the soft dirty tracking in the powerpc
architecture code. 

Laurent Dufour (3):
  mm: clearing pte in clear_soft_dirty()
  mm: clear_soft_dirty_pmd requires THP
  powerpc/mm: Add page soft dirty tracking

 arch/powerpc/Kconfig                     |  2 ++
 arch/powerpc/include/asm/pgtable-ppc64.h | 13 +++++++++--
 arch/powerpc/include/asm/pgtable.h       | 40 +++++++++++++++++++++++++++++++-
 arch/powerpc/include/asm/pte-book3e.h    |  1 +
 arch/powerpc/include/asm/pte-common.h    |  5 ++--
 arch/powerpc/include/asm/pte-hash64.h    |  1 +
 fs/proc/task_mmu.c                       | 21 +++++++++--------
 7 files changed, 68 insertions(+), 15 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
