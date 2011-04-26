From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/3] reduce readahead overheads on tmpfs mmap page faults
Date: Tue, 26 Apr 2011 17:43:52 +0800
Message-ID: <20110426094352.030753173__18790.7593012371$1303811520$gmane$org@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Li Shaohua <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Andrew,

This kills unnessesary ra->mmap_miss and ra->prev_pos updates on every page
fault when the readahead is disabled.

They fix the cache line bouncing problem in the mosbench exim benchmark, which
does multi-threaded page faults on shared struct file on tmpfs.

Thanks,
Fengguang
