Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0F66B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 09:04:32 -0500 (EST)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate3.uk.ibm.com (8.13.1/8.13.1) with ESMTP id pAAE4Rh4012634
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:04:27 GMT
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAE4REc2138150
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:04:27 GMT
Received: from d06av11.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAE4Pbr023883
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 07:04:25 -0700
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 0/3] CMPXCHG config options changes
Date: Thu, 10 Nov 2011 15:04:17 +0100
Message-Id: <1320933860-15588-1-git-send-email-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>

While implementing cmpxchg_double() on s390 I realized that we don't
set CONFIG_CMPXCHG_LOCAL besides the fact that we have support for it.
However setting that option will increase the size of struct page by
eight bytes on 64 bit, which we certainly do not want.
Also, it doesn't make sense that a present cpu feature should increase
the size of struct page.
Besides that it looks like the dependency to CMPXCHG_LOCAL is wrong
and that it should depend on CMPXCHG_DOUBLE instead.

Heiko Carstens (3):
  mm,slub,x86: decouple size of struct page from CONFIG_CMPXCHG_LOCAL
  mm,x86,um: move CMPXCHG_LOCAL config option
  mm,x86,um: move CMPXCHG_DOUBLE config option

 arch/Kconfig             |   14 ++++++++++++++
 arch/x86/Kconfig         |    3 +++
 arch/x86/Kconfig.cpu     |    6 ------
 arch/x86/um/Kconfig      |    8 --------
 include/linux/mm_types.h |    9 ++++-----
 mm/slub.c                |    9 ++++++---
 mm/vmstat.c              |    2 +-
 7 files changed, 28 insertions(+), 23 deletions(-)

-- 
1.7.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
