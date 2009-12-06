Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B9F6D6B0044
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 05:16:16 -0500 (EST)
Message-ID: <COL115-W58F42F7BEEB67BF8324B2A9F910@phx.gbl>
From: Liu bo <bo-liu@hotmail.com>
Subject: [PATCH] memcg: correct return value at mem_cgroup reclaim
Date: Sun, 6 Dec 2009 18:16:14 +0800
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


In order to indicate reclaim has succeeded, mem_cgroup_hierarchical_reclaim() used to return 1.
Now the return value is without indicating whether reclaim has successded usage, so just return the total reclaimed pages don't plus 1.
 
Signed-off-by: Liu Bo <bo-liu@hotmail.com>
---
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14593f5..51b6b3c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -737,7 +737,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
   css_put(&victim->css);
   total += ret;
   if (mem_cgroup_check_under_limit(root_mem))
-   return 1 + total;
+   return total;
  }
  return total;
 } 		 	   		  
_________________________________________________________________
Windows Live: Keep your friends up to date with what you do online.
http://www.microsoft.com/middleeast/windows/windowslive/see-it-in-action/social-network-basics.aspx?ocid=PID23461::T:WLMTAGL:ON:WL:en-xm:SI_SB_1:092010

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
