From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/4] devmem and readahead fixes for 2.6.33
Date: Fri, 22 Jan 2010 12:59:14 +0800
Message-ID: <20100122045914.993668874@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B93376B0078
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 00:19:29 -0500 (EST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, stable@kernel.org, Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

Andrew,

Here are some good fixes for 2.6.33, they have been floating around
with other patches for some time. I should really seperate them out
earlier..

Greg,

The first two patches are on devmem. 2.6.32 also needs fixing, however
the patches can only apply cleanly to 2.6.33. I can do backporting if
necessary.

	[PATCH 1/4] devmem: check vmalloc address on kmem read/write
	[PATCH 2/4] devmem: fix kmem write bug on memory holes

The next two patches are on readahead. All previous kernel needs fixing,
and the patches can apply cleanly to 2.6.32, too.

	[PATCH 3/4] vfs: take f_lock on modifying f_mode after open time
	[PATCH 4/4] readahead: introduce FMODE_RANDOM for POSIX_FADV_RANDOM

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
