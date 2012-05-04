Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 9E2276B00F0
	for <linux-mm@kvack.org>; Fri,  4 May 2012 14:55:41 -0400 (EDT)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [RFC PATCH] Expand memblock=debug to provide a bit more details (v1).
Date: Fri,  4 May 2012 14:49:40 -0400
Message-Id: <1336157382-14548-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tj@kernel.org, hpa@linux.intel.com, yinghai@kernel.org, paul.gortmaker@windriver.com, akpm@linux-foundation.org, linux-mm@kvack.org

While trying to track down some memory allocation issues, I realized that
memblock=debug was giving some information, but for guests with 256GB or
so the majority of it was just:

 memblock_reserve: [0x00003efeeea000-0x00003efeeeb000] __alloc_memory_core_early+0x5c/0x64

which really didn't tell me that much. With these patches I know it is:

 memblock_reserve: [0x00003ffe724000-0x00003ffe725000] (4kB) vmemmap_pmd_populate+0x4b/0xa2

.. which isn't really that useful for the problem I was tracking down, but
it does help in figuring out which routines are using memblock.

Please see the patches - not sure what is in the future for memblock.c
so if they are running afoul of some future grand plans - I can rebase them.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
