From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/3] reduce readahead overheads on tmpfs mmap page faults v2
Date: Sat, 30 Apr 2011 11:22:43 +0800
Message-ID: <20110430032243.355805181__314.839572138403$1304134346$gmane$org@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Li Shaohua <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Andrew,

I would like to update the changelogs for patches 2 and 3.
There are no changes to the code. Sorry for the inconvenience.

The original changelog is not accurate: it's solely the ra->mmap_miss updates
that caused cache line bouncing on tmpfs. ra->prev_pos won't be updated at all
on tmpfs.

Thanks,
Fengguang
