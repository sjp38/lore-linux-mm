Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 388596B025F
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 11:29:59 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id n8so102319643ybn.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:29:59 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id b73si15806104wmi.47.2016.08.15.08.29.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 08:29:58 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id o80so11720596wme.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:29:58 -0700 (PDT)
Date: Mon, 15 Aug 2016 17:29:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH stable-4.4 1/3] mm: memcontrol: fix cgroup creation
 failure after many small jobs
Message-ID: <20160815152955.GH3360@dhcp22.suse.cz>
References: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
 <1471273606-15392-2-git-send-email-mhocko@kernel.org>
 <20160815151604.GA5468@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160815151604.GA5468@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Stable tree <stable@vger.kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nikolay Borisov <kernel@kyup.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon 15-08-16 11:16:04, Johannes Weiner wrote:
> On Mon, Aug 15, 2016 at 05:06:44PM +0200, Michal Hocko wrote:
> > @@ -4173,11 +4213,17 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
> >  
> >  	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
> >  	if (!memcg->stat)
> > -		goto out_free;
> > +		goto out_idr;
> 
> Spurious left-over from the previous version?

Yes, b0rked during the rebase. I will repost this patch.

Sorry about that and thanks for catching that!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
