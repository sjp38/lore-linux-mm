Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 173696B0035
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 02:27:30 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so2974785pbb.5
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 23:27:29 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id iw3si4182876pac.14.2014.04.03.23.27.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 23:27:29 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Fri, 4 Apr 2014 11:57:24 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 42594394003E
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 11:57:21 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s346RDrN26542184
	for <linux-mm@kvack.org>; Fri, 4 Apr 2014 11:57:13 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s346RJFD027403
	for <linux-mm@kvack.org>; Fri, 4 Apr 2014 11:57:20 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Subject: [PATCH V2 0/2] FAULT_AROUND_ORDER patchset performance data for powerpc
Date: Fri,  4 Apr 2014 11:57:13 +0530
Message-Id: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>

Kirill A. Shutemov with faultaround patchset introduced
vm_ops->map_pages() for mapping easy accessible pages around
fault address in hope to reduce number of minor page faults.

This patchset creates infrastructure to move the FAULT_AROUND_ORDER
to arch/ using Kconfig. This will enable architecture maintainers
to decide on suitable FAULT_AROUND_ORDER value based on
performance data for that architecture. First patch also adds
FAULT_AROUND_ORDER Kconfig element for X86. Second patch list
out the performance numbers for powerpc (platform pseries) and
adds FAULT_AROUND_ORDER Kconfig element for powerpc.

V2 Changes:
  Created Kconfig parameter for FAULT_AROUND_ORDER
  Added check in do_read_fault to handle FAULT_AROUND_ORDER value of 0
  Made changes in commit messages.

Madhavan Srinivasan (2):
  mm: move FAULT_AROUND_ORDER to arch/
  mm: add FAULT_AROUND_ORDER Kconfig paramater for powerpc

 arch/powerpc/platforms/pseries/Kconfig |    5 +++++
 arch/x86/Kconfig                       |    4 ++++
 include/linux/mm.h                     |    9 +++++++++
 mm/memory.c                            |   12 +++++-------
 4 files changed, 23 insertions(+), 7 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
