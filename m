Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id ACFAC6B002C
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 21:43:31 -0500 (EST)
Received: by pbbro12 with SMTP id ro12so351358pbb.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 18:43:31 -0800 (PST)
Date: Wed, 29 Feb 2012 18:42:57 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH next] memcg: remove PCG_CACHE page_cgroup flag fix2
In-Reply-To: <alpine.LSU.2.00.1202291718450.11821@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202291841110.14002@eggly.anvils>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils> <alpine.LSU.2.00.1202282128500.4875@eggly.anvils> <20120229194304.GF1673@cmpxchg.org> <alpine.LSU.2.00.1202291718450.11821@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add comment to MEM_CGROUP_CHARGE_TYPE_MAPPED case in
__mem_cgroup_uncharge_common().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
This one incremental to patch already in mm-commits.

 mm/memcontrol.c |    5 +++++
 1 file changed, 5 insertions(+)

--- mm-commits/mm/memcontrol.c	2012-02-28 20:45:43.488100423 -0800
+++ linux/mm/memcontrol.c	2012-02-29 18:21:49.144702180 -0800
@@ -2953,6 +2953,11 @@ __mem_cgroup_uncharge_common(struct page
 
 	switch (ctype) {
 	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
+		/*
+		 * Generally PageAnon tells if it's the anon statistics to be
+		 * updated; but sometimes e.g. mem_cgroup_uncharge_page() is
+		 * used before page reached the stage of being marked PageAnon.
+		 */
 		anon = true;
 		/* fallthrough */
 	case MEM_CGROUP_CHARGE_TYPE_DROP:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
