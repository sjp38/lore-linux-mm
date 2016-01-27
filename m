Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8D11A6B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 05:09:44 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id 123so144485134wmz.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 02:09:44 -0800 (PST)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id 78si10062940wmv.119.2016.01.27.02.09.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 02:09:43 -0800 (PST)
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 27 Jan 2016 10:09:42 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 038581B08076
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:09:47 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0RA9dLl2884028
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:09:39 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0RA9cIB008387
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 03:09:39 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH v3 0/3] Optimize CONFIG_DEBUG_PAGEALLOC
Date: Wed, 27 Jan 2016 11:09:58 +0100
Message-Id: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk, Christian Borntraeger <borntraeger@de.ibm.com>

Andrew, since the arch patches depend on the base patch, maybe the mm
tree is the right one? I have acks/reviews for the s390/x86 part.


As CONFIG_DEBUG_PAGEALLOC can be enabled/disabled via kernel
parameters we can optimize some cases by checking the enablement
state.

I have done s390 and x86 as examples.
s390 should be ok, I tested several combinations, x86 seems to
work as well.

Power can probably do the same, Michael/Ben?
I am not sure about sparc. Sparc seems to allocate the TSB buffer
really early. David?


V2->V3:
- Fix whitespace/indent breakage in s390 patch
V1->V2:
- replace DEBUG_PAGEALLOC(disabled/enabled) with DEBUG_PAGEALLOC
  dump_stack for s390/x86
- add /* CONFIG_DEBUG_PAGEALLOC */ to else and endif


Christian Borntraeger (3):
  mm: provide debug_pagealloc_enabled() without CONFIG_DEBUG_PAGEALLOC
  x86: query dynamic DEBUG_PAGEALLOC setting
  s390: query dynamic DEBUG_PAGEALLOC setting

 arch/s390/kernel/dumpstack.c |  6 +++---
 arch/s390/mm/vmem.c          | 10 ++++------
 arch/x86/kernel/dumpstack.c  |  5 ++---
 arch/x86/mm/init.c           |  7 ++++---
 arch/x86/mm/pageattr.c       | 14 ++++----------
 include/linux/mm.h           |  9 +++++++--
 6 files changed, 24 insertions(+), 27 deletions(-)

-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
