Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 0D2286B013D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 15:46:29 -0400 (EDT)
Date: Thu, 04 Oct 2012 15:46:24 -0400 (EDT)
Message-Id: <20121004.154624.923241475790311926.davem@davemloft.net>
Subject: [PATCH v2 0/8] THP support for Sparc64
From: David Miller <davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org


Changes since V1:

1) Respun against mmotm

2) Bug fix for pgtable allocation, need real locking instead of
   just preemption disabling.

Andrew, you can probably take patch #5 in this series and combine
it into:

mm-thp-fix-the-update_mmu_cache-last-argument-passing-in-mm-huge_memoryc.patch

in your batch.  And finally add a NOP implementation for S390
and any other huge page supporting architectures.

Signed-off-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
