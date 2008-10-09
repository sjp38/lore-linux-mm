Received: by nf-out-0910.google.com with SMTP id c10so2189619nfd.6
        for <linux-mm@kvack.org>; Thu, 09 Oct 2008 00:36:20 -0700 (PDT)
Message-ID: <48EDB47E.60604@gmail.com>
Date: Thu, 09 Oct 2008 09:36:30 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: [PATCH] documentation: clarify dirty_ratio and dirty_background_ratio
 description (v2)
References: <48EC90EC.8060306@gmail.com> <20081009105157.dd47d109.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081009105157.dd47d109.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Rubin <mrubin@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

The current documentation of dirty_ratio and dirty_background_ratio is a
bit misleading.

In the documentation we say that they are "a percentage of total system
memory", but the current page writeback policy, intead, is to apply the
percentages to the dirtyable memory, that means free pages + reclaimable
pages.

Better to be more explicit to clarify this concept.

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/filesystems/proc.txt |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 394eb2c..474bf8b 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -1380,15 +1380,18 @@ causes the kernel to prefer to reclaim dentries and inodes.
 dirty_background_ratio
 ----------------------
 
-Contains, as a percentage of total system memory, the number of pages at which
-the pdflush background writeback daemon will start writing out dirty data.
+Contains, as a percentage of the dirtyable system memory (free pages + mapped
+pages + file cache, not including locked pages and HugePages), the number of
+pages at which the pdflush background writeback daemon will start writing out
+dirty data.
 
 dirty_ratio
 -----------------
 
-Contains, as a percentage of total system memory, the number of pages at which
-a process which is generating disk writes will itself start writing out dirty
-data.
+Contains, as a percentage of the dirtyable system memory (free pages + mapped
+pages + file cache, not including locked pages and HugePages), the number of
+pages at which a process which is generating disk writes will itself start
+writing out dirty data.
 
 dirty_writeback_centisecs
 -------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
