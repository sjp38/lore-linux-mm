Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A1048900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 23:31:44 -0400 (EDT)
Message-Id: <20110430032243.355805181@intel.com>
Date: Sat, 30 Apr 2011 11:22:43 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/3] reduce readahead overheads on tmpfs mmap page faults v2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Li Shaohua <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Andrew,

I would like to update the changelogs for patches 2 and 3.
There are no changes to the code. Sorry for the inconvenience.

The original changelog is not accurate: it's solely the ra->mmap_miss updates
that caused cache line bouncing on tmpfs. ra->prev_pos won't be updated at all
on tmpfs.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
