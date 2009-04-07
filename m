From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/14] filemap and readahead fixes
Date: Tue, 07 Apr 2009 19:50:39 +0800
Message-ID: <20090407115039.780820496@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 298725F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:00:50 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

Andrew,

This is a set of fixes and cleanups for filemap and readahead.
They are for 2.6.29-rc8-mm1 and have been carefully tested.

filemap VM_FAULT_RETRY fixes
----------------------------
        [PATCH 01/14] mm: fix find_lock_page_retry() return value parsing
        [PATCH 02/14] mm: fix major/minor fault accounting on retried fault
        [PATCH 03/14] mm: remove FAULT_FLAG_RETRY dead code
        [PATCH 04/14] mm: reduce duplicate page fault code
        [PATCH 05/14] readahead: account mmap_miss for VM_FAULT_RETRY

readahead fixes
---------------
minor cleanups:
        [PATCH 06/14] readahead: move max_sane_readahead() calls into force_page_cache_readahead()
        [PATCH 07/14] readahead: apply max_sane_readahead() limit in ondemand_readahead()
        [PATCH 08/14] readahead: remove one unnecessary radix tree lookup

behavior changes necessary for the following mmap readahead:
        [PATCH 09/14] readahead: increase interleaved readahead size
        [PATCH 10/14] readahead: remove sync/async readahead call dependency

mmap readaround/readahead
-------------------------
major cleanups from Linus:
(the cleanups automatically fix a PGMAJFAULT accounting bug in VM_RAND_READ case)
        [PATCH 11/14] readahead: clean up and simplify the code for filemap page fault readahead

and my further steps:
        [PATCH 12/14] readahead: sequential mmap readahead
        [PATCH 13/14] readahead: enforce full readahead size on async mmap readahead
        [PATCH 14/14] readahead: record mmap read-around states in file_ra_state

Thanks,
Fengguang
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
