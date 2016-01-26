Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 687D46B0255
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:18:13 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id n5so119458236wmn.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:18:13 -0800 (PST)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id r186si4308895wmb.16.2016.01.26.01.18.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 01:18:12 -0800 (PST)
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 26 Jan 2016 09:18:12 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 551F61B0804B
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:18:08 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0Q9I1ti8716556
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:18:01 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0Q9I0CV002047
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 02:18:00 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH/RFC 0/3] Optimize CONFIG_DEBUG_PAGEALLOC
Date: Tue, 26 Jan 2016 10:18:22 +0100
Message-Id: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>

As CONFIG_DEBUG_PAGEALLOC can be enabled/disabled via kernel
parameters we can optimize some cases by checking the enablement
state.

I have done s390 and x86 as examples. Other architecture can
provide followup patches later on.

Christian Borntraeger (3):
  mm: provide debug_pagealloc_enabled() without CONFIG_DEBUG_PAGEALLOC
  x86: query dynamic DEBUG_PAGEALLOC setting
  s390: query dynamic DEBUG_PAGEALLOC setting

 arch/s390/kernel/dumpstack.c |  4 +++-
 arch/s390/mm/vmem.c          | 10 ++++------
 arch/x86/kernel/dumpstack.c  |  4 +++-
 arch/x86/mm/init.c           |  7 ++++---
 arch/x86/mm/pageattr.c       | 14 ++++----------
 include/linux/mm.h           |  4 ++++
 6 files changed, 22 insertions(+), 21 deletions(-)

-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
