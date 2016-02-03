Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id AB6C26B0257
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 03:39:45 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l66so58806254wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 00:39:45 -0800 (PST)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id m129si28880073wmf.106.2016.02.03.00.39.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 00:39:44 -0800 (PST)
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 3 Feb 2016 08:39:43 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id A0C322190066
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:39:27 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u138de3S8126974
	for <linux-mm@kvack.org>; Wed, 3 Feb 2016 08:39:40 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u138deSF010960
	for <linux-mm@kvack.org>; Wed, 3 Feb 2016 01:39:40 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH v4 0/4 (resend)] Optimize CONFIG_DEBUG_PAGEALLOC (x86 and s390)
Date: Wed,  3 Feb 2016 09:39:31 +0100
Message-Id: <1454488775-108777-6-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1454488775-108777-1-git-send-email-borntraeger@de.ibm.com>
References: <1454488775-108777-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>

Andrew, here is a resend as these patches were dropped as I also 
had them on my linux-next branch (instead of a private one)

As CONFIG_DEBUG_PAGEALLOC can be enabled/disabled via kernel
parameters we can optimize some cases by checking the enablement
state.

I have done s390 and x86. Other architecture can follow as necessary.

Christian Borntraeger (4):
  mm: provide debug_pagealloc_enabled() without CONFIG_DEBUG_PAGEALLOC
  x86: query dynamic DEBUG_PAGEALLOC setting
  s390: query dynamic DEBUG_PAGEALLOC setting
  x86: also use debug_pagealloc_enabled() for free_init_pages

 arch/s390/kernel/dumpstack.c |  6 +++---
 arch/s390/mm/vmem.c          | 10 ++++------
 arch/x86/kernel/dumpstack.c  |  5 ++---
 arch/x86/mm/init.c           | 36 +++++++++++++++++++-----------------
 arch/x86/mm/pageattr.c       | 14 ++++----------
 include/linux/mm.h           |  9 +++++++--
 6 files changed, 39 insertions(+), 41 deletions(-)

-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
