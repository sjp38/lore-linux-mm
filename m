Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 85AF96B00D8
	for <linux-mm@kvack.org>; Thu,  8 May 2014 05:28:30 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so2539267pab.26
        for <linux-mm@kvack.org>; Thu, 08 May 2014 02:28:30 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id ko6si234171pbc.141.2014.05.08.02.28.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 May 2014 02:28:29 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Thu, 8 May 2014 14:58:24 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 7CEA71258055
	for <linux-mm@kvack.org>; Thu,  8 May 2014 14:57:18 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s489SS1b3080582
	for <linux-mm@kvack.org>; Thu, 8 May 2014 14:58:29 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s489SIiS027839
	for <linux-mm@kvack.org>; Thu, 8 May 2014 14:58:19 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Subject: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data for powerpc
Date: Thu,  8 May 2014 14:58:14 +0530
Message-Id: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>

Kirill A. Shutemov with 8c6e50b029 commit introduced
vm_ops->map_pages() for mapping easy accessible pages around
fault address in hope to reduce number of minor page faults.

This patch creates infrastructure to modify the FAULT_AROUND_ORDER
value using mm/Kconfig. This will enable architecture maintainers
to decide on suitable FAULT_AROUND_ORDER value based on
performance data for that architecture. First patch also defaults
FAULT_AROUND_ORDER Kconfig element to 4. Second patch list
out the performance numbers for powerpc (platform pseries) and
initialize the fault around order variable for pseries platform of
powerpc.

V4 Changes:
  Replaced the BUILD_BUG_ON with VM_BUG_ON.
  Moved fault_around_pages() and fault_around_mask() functions outside of
   #ifdef CONFIG_DEBUG_FS.

V3 Changes:
  Replaced FAULT_AROUND_ORDER macro to a variable to support arch's that
   supports sub platforms.
  Made changes in commit messages.

V2 Changes:
  Created Kconfig parameter for FAULT_AROUND_ORDER
  Added check in do_read_fault to handle FAULT_AROUND_ORDER value of 0
  Made changes in commit messages.

Madhavan Srinivasan (2):
  mm: move FAULT_AROUND_ORDER to arch/
  powerpc/pseries: init fault_around_order for pseries

 arch/powerpc/platforms/pseries/pseries.h |    2 ++
 arch/powerpc/platforms/pseries/setup.c   |    5 +++++
 mm/Kconfig                               |    8 ++++++++
 mm/memory.c                              |   25 ++++++-------------------
 4 files changed, 21 insertions(+), 19 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
