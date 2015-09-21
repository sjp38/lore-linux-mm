Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id A24186B0255
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 11:22:24 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so120860932wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 08:22:24 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id b13si31821244wjz.156.2015.09.21.08.22.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Sep 2015 08:22:23 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 21 Sep 2015 16:22:22 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 40499219005C
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:21:52 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8LFMLQx36110566
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 15:22:21 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8LEMLQE009157
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 08:22:21 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 0/2] mm: soft-dirty bits for s390
Date: Mon, 21 Sep 2015 17:22:18 +0200
Message-Id: <1442848940-22108-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>

Greetings,

this patch set of two adds memory change tracking alias soft-dirty
feature to the s390 architecture.

The first patch is a cleanup of the existing x86 support, it adds two
arch specific functions pte_clear_soft_dirty and pmd_clear_soft_dirty
to complement the other xxx_soft_dirty functions. This removes the
use of a x86 specific function in fs/proc/tasm_mmu.c.

The second patch is the s390 arch support.

Tested on x86 and s390, seems to work as intended for both platforms.
If the first patch is acceptable I can queue the set on the linux-s390
tree for the 4.4 merge window in a couple of weeks.

Martin Schwidefsky (2):
  mm: add architecture primitives for software dirty bit clearing
  s390/mm: implement soft-dirty bits for user memory change tracking

 arch/s390/Kconfig               |  1 +
 arch/s390/include/asm/pgtable.h | 59 ++++++++++++++++++++++++++++++++++++++---
 arch/s390/mm/hugetlbpage.c      |  2 ++
 arch/x86/include/asm/pgtable.h  | 10 +++++++
 fs/proc/task_mmu.c              |  4 +--
 include/asm-generic/pgtable.h   | 10 +++++++
 6 files changed, 80 insertions(+), 6 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
