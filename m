Date: Fri, 11 Jan 2008 12:59:31 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
In-Reply-To: <20080108210002.638347207@redhat.com>
References: <20080108205939.323955454@redhat.com> <20080108210002.638347207@redhat.com>
Message-Id: <20080111122225.FD59.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi Rik

> -static inline long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
> -					struct zone *zone, int priority)
> +static inline long mem_cgroup_calc_reclaim(struct mem_cgroup *mem,
> +					struct zone *zone, int priority,
> +					int active, int file)
>  {
>  	return 0;
>  }

it can't compile if memcgroup turn off.

because current mem_cgroup_calc_reclaim type is below.

	long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
				int priority, enum lru_list lru)

after patched below, it can compile.
I hope you don't think unpleasant by a trivial point out.

regard.

- kosaki


Index: linux-2.6.24-rc6-mm1-rvr/include/linux/memcontrol.h
===================================================================
--- linux-2.6.24-rc6-mm1-rvr.orig/include/linux/memcontrol.h    2008-01-11 11:10:16.000000000 +0900
+++ linux-2.6.24-rc6-mm1-rvr/include/linux/memcontrol.h 2008-01-11 12:08:29.000000000 +0900
@@ -168,9 +168,8 @@
 {
 }

-static inline long mem_cgroup_calc_reclaim(struct mem_cgroup *mem,
-                                       struct zone *zone, int priority,
-                                       int active, int file)
+static inline long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
+                                       int priority, enum lru_list lru)
 {
        return 0;
 }




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
