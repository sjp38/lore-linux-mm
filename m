Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0494403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 05:02:06 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id n128so65984638pfn.3
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 02:02:06 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id q74si22994768pfq.207.2016.02.05.02.02.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 02:02:06 -0800 (PST)
Date: Fri, 5 Feb 2016 13:01:57 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/3] mm: memcontrol: report kernel stack usage in cgroup2
 memory.stat
Message-ID: <20160205100157.GB29522@esperanza>
References: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
 <1d7473a8f8b814e536f9fdbd29d90591f1952f73.1454589800.git.vdavydov@virtuozzo.com>
 <20160204205210.GF8208@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160204205210.GF8208@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 04, 2016 at 03:52:10PM -0500, Johannes Weiner wrote:
> On Thu, Feb 04, 2016 at 04:03:39PM +0300, Vladimir Davydov wrote:
> > Show how much memory is allocated to kernel stacks.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks.

> 
> Thanks, this looks good. The only thing that strikes me is that you
> appended the new stat items to the enum, but then prepended them to
> the doc and stat file sections. Why is that?

No reason. Let's rearrange the enum fields to be consistent with the
stat file output.

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index aaf564881303..d6300313b298 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -52,10 +52,10 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
 	MEM_CGROUP_STAT_NSTATS,
 	/* default hierarchy stats */
-	MEMCG_SOCK = MEM_CGROUP_STAT_NSTATS,
+	MEMCG_KERNEL_STACK = MEM_CGROUP_STAT_NSTATS,
 	MEMCG_SLAB_RECLAIMABLE,
 	MEMCG_SLAB_UNRECLAIMABLE,
-	MEMCG_KERNEL_STACK,
+	MEMCG_SOCK,
 	MEMCG_NR_STAT,
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
