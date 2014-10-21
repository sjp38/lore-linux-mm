Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0E16B0069
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 17:05:59 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id u10so1792324lbd.34
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 14:05:58 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 4si20715381laq.88.2014.10.21.14.05.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 14:05:57 -0700 (PDT)
Date: Tue, 21 Oct 2014 17:05:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 4/4] mm: memcontrol: simplify per-memcg page statistics
 accounting
Message-ID: <20141021210554.GC29116@phnom.home.cmpxchg.org>
References: <1413922896-29042-1-git-send-email-hannes@cmpxchg.org>
 <1413922896-29042-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413922896-29042-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 21, 2014 at 04:21:36PM -0400, Johannes Weiner wrote:
> @@ -315,13 +290,13 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
>  }
>  
> -static inline void mem_cgroup_begin_update_page_stat(struct page *page,
> +static inline void mem_cgroup_begin_page_stat(struct page *page,
>  					bool *locked, unsigned long *flags)

I forgot to refresh after fixing the allnoconfig build.  Andrew could
you fold the following please if/when merging this patch?  Thanks!

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4dc4a2aec440..ea007615e8f9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -290,9 +290,10 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
-static inline void mem_cgroup_begin_page_stat(struct page *page,
+static inline struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page,
 					bool *locked, unsigned long *flags)
 {
+	return NULL;
 }
 
 static inline void mem_cgroup_end_page_stat(struct mem_cgroup *memcg,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
