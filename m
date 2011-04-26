Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DB9F69000C3
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 05:51:07 -0400 (EDT)
Message-Id: <20110426094352.030753173@intel.com>
Date: Tue, 26 Apr 2011 17:43:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/3] reduce readahead overheads on tmpfs mmap page faults
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Li Shaohua <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Andrew,

This kills unnessesary ra->mmap_miss and ra->prev_pos updates on every page
fault when the readahead is disabled.

They fix the cache line bouncing problem in the mosbench exim benchmark, which
does multi-threaded page faults on shared struct file on tmpfs.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
