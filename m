Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E17FE6B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 13:02:49 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 00/10] mm: memcg: charge/uncharge improvements v2
Date: Wed, 11 Jul 2012 19:02:12 +0200
Message-Id: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

second version of tiny charge/uncharge improvements, with incorporated
feedback and acks added (thanks guys).

changes:
o fixed the 03/10 PageSwapCache check in end_migration(), spotted by Kame
o dropped the v1 03/11 shmem patch in favor of Hugh's cleanup
o included default group charging comment fix in 07/10, spotted by Wanpeng

 include/linux/memcontrol.h |   11 +--
 mm/memcontrol.c            |  207 +++++++++++++++++++++++---------------------
 mm/migrate.c               |   27 ++-----
 mm/swapfile.c              |    3 +-
 4 files changed, 119 insertions(+), 129 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
