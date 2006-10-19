From: Paul Jackson <pj@sgi.com>
Date: Thu, 19 Oct 2006 03:09:46 -0700
Message-Id: <20061019100946.6074.92969.sendpatchset@sam.engr.sgi.com>
Subject: [PATCH 1/2] memory page_alloc zonelist caching speedup aligncache revert
Sender: owner-linux-mm@kvack.org
From: Paul Jackson <pj@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: nickpiggin@yahoo.com.au, ak@suse.de, linux-mm@kvack.org, holt@sgi.com, mbligh@google.com, rientjes@google.com, rohitseth@google.com, menage@google.com, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Revert the patch:
  memory page_alloc zonelist caching speedup aligncache

Thanks to a suggestion by Rohit Seth, there's a better
way to do this, just by reordering some struct members.

Signed-off-by: Paul Jackson <pj@sgi.com>

---

Andrew - I'm guessing that you will squash this patch together
         with the patch it reverts:
                memory page_alloc zonelist caching speedup aligncache
         and then throw the resulting empty patch out.

         Or just throw the reverted patch out.  Whatever.

					-pj

 include/linux/mmzone.h |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

--- 2.6.19-rc2-mm1.orig/include/linux/mmzone.h	2006-10-19 02:45:44.000000000 -0700
+++ 2.6.19-rc2-mm1/include/linux/mmzone.h	2006-10-19 02:45:49.000000000 -0700
@@ -396,8 +396,7 @@ struct zonelist {
 	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
 	struct zone *zones[MAX_ZONES_PER_ZONELIST + 1];      // NULL delimited
 #ifdef CONFIG_NUMA
-	/* Keep written zonelist_cache off read-only zones[] cache lines */
-	struct zonelist_cache zlcache ____cacheline_aligned; // optional ...
+	struct zonelist_cache zlcache;			     // optional ...
 #endif
 };
 

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
