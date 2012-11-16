Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 6FAD96B0072
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 10:13:52 -0500 (EST)
Date: Fri, 16 Nov 2012 23:13:30 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [memcg:since-3.6 365/437] warning: (BALLOON_COMPACTION &&
 TRANSPARENT_HUGEPAGE) selects COMPACTION which has unmet direct
 dependencies (MMU)
Message-ID: <50a6581a.V3MmP/x4DXU9jUhJ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.6
head:   12dfb061e5fd15be23451418da01281625c0eeae
commit: 86929cfa5f751de3d8be5a846535282730865d8a [365/437] mm: introduce a common interface for balloon pages mobility
config: make ARCH=sh allyesconfig

All warnings:

warning: (BALLOON_COMPACTION && TRANSPARENT_HUGEPAGE) selects COMPACTION which has unmet direct dependencies (MMU)
warning: (BALLOON_COMPACTION && TRANSPARENT_HUGEPAGE) selects COMPACTION which has unmet direct dependencies (MMU)
--
warning: (BALLOON_COMPACTION && TRANSPARENT_HUGEPAGE) selects COMPACTION which has unmet direct dependencies (MMU)

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
