Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0693B6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 18:54:58 -0500 (EST)
Received: by wiwl15 with SMTP id l15so28307wiw.1
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 15:54:57 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id di3si17090215wid.48.2015.03.05.15.54.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 15:54:56 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/2] Automatic NUMA balancing and PROT_NONE handling followup
Date: Thu,  5 Mar 2015 23:54:50 +0000
Message-Id: <1425599692-32445-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, linuxppc-dev@lists.ozlabs.org, Mel Gorman <mgorman@suse.de>

Dave Chinner reported a problem due to excessive NUMA balancing activity and
bisected it. These are two patches that address two major issues with that
series. The first patch is almost certainly unrelated to what he saw due
to fact his vmstats showed no huge page activity but the fix is important.
The second patch restores performance of one benchmark to similar levels
to 3.19-vanilla but it still has to be tested on his workload. While I
have a test configuration for his workload, I don't have either the KVM
setup or suitable storage to test against. It also needs to be reviewed
and tested on ppc64.

 arch/powerpc/include/asm/pgtable-ppc64.h | 16 ++++++++++++++++
 arch/x86/include/asm/pgtable.h           | 14 ++++++++++++++
 include/asm-generic/pgtable.h            | 19 +++++++++++++++++++
 mm/huge_memory.c                         | 23 ++++++++++++++++++-----
 mm/mprotect.c                            |  5 +++++
 5 files changed, 72 insertions(+), 5 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
