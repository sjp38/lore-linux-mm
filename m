Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6EF136B002C
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 16:43:35 -0500 (EST)
Received: by dakp5 with SMTP id p5so4515436dak.8
        for <linux-mm@kvack.org>; Sun, 04 Mar 2012 13:43:34 -0800 (PST)
Date: Sun, 4 Mar 2012 13:43:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, mempolicy: dummy slab_node return value for bugless
 kernels
Message-ID: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

BUG() is a no-op when CONFIG_BUG is disabled, so slab_node() needs a
dummy return value to avoid reaching the end of a non-void function.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mempolicy.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1611,6 +1611,7 @@ unsigned slab_node(struct mempolicy *policy)
 
 	default:
 		BUG();
+		return numa_node_id();
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
