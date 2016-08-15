Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id F10F56B025F
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 11:19:40 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id g67so73470270ybi.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:19:40 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l2si1207826wmb.115.2016.08.15.08.19.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 08:19:39 -0700 (PDT)
Date: Mon, 15 Aug 2016 11:16:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH stable-4.4 1/3] mm: memcontrol: fix cgroup creation
 failure after many small jobs
Message-ID: <20160815151604.GA5468@cmpxchg.org>
References: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
 <1471273606-15392-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471273606-15392-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nikolay Borisov <kernel@kyup.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Mon, Aug 15, 2016 at 05:06:44PM +0200, Michal Hocko wrote:
> @@ -4173,11 +4213,17 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  
>  	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
>  	if (!memcg->stat)
> -		goto out_free;
> +		goto out_idr;

Spurious left-over from the previous version?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
