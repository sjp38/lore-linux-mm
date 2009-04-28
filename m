From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/5] proc: export more page flags in /proc/kpageflags (take 4)
Date: Tue, 28 Apr 2009 09:09:07 +0800
Message-ID: <20090428010907.912554629@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 72C456B00DD
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 21:50:27 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Hi all,

Export 9 more flags to end users (and more for kernel developers):

        11. KPF_MMAP            (pseudo flag) memory mapped page
        12. KPF_ANON            (pseudo flag) memory mapped page (anonymous)
        13. KPF_SWAPCACHE       page is in swap cache
        14. KPF_SWAPBACKED      page is swap/RAM backed
        15. KPF_COMPOUND_HEAD   (*)
        16. KPF_COMPOUND_TAIL   (*)
        17. KPF_UNEVICTABLE     page is in the unevictable LRU list
        18. KPF_HWPOISON        hardware detected corruption
        19. KPF_NOPAGE          (pseudo flag) no page frame at the address

        (*) For compound pages, exporting _both_ head/tail info enables
            users to tell where a compound page starts/ends, and its order.

Please check the documentary patch and changelog of the final patch
for the details.

	[PATCH 1/5] pagemap: document clarifications                                             
	[PATCH 2/5] pagemap: documentation new page flags                                        
	[PATCH 3/5] mm: introduce PageHuge() for testing huge/gigantic pages                     
	[PATCH 4/5] proc: kpagecount/kpageflags code cleanup                                     
	[PATCH 5/5] proc: export more page flags in /proc/kpageflags                             

Thanks,
Fengguang
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
