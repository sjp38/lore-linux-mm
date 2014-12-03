Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id BC9066B007D
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 10:54:53 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id b13so20295951wgh.32
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 07:54:53 -0800 (PST)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id wo10si40625190wjc.32.2014.12.03.07.54.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 07:54:53 -0800 (PST)
Received: by mail-wg0-f47.google.com with SMTP id n12so20385101wgh.34
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 07:54:53 -0800 (PST)
Date: Wed, 3 Dec 2014 16:54:51 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcontrol.c:  Cleaning up function that are not
 used anywhere
Message-ID: <20141203155451.GI23236@dhcp22.suse.cz>
References: <1417560083-27157-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
 <20141203152231.GA2822@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141203152231.GA2822@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 03-12-14 10:22:31, Johannes Weiner wrote:
> On Tue, Dec 02, 2014 at 11:41:23PM +0100, Rickard Strandqvist wrote:
> > Remove function mem_cgroup_lru_names_not_uptodate() that is not used anywhere.
> > 
> > This was partially found by using a static code analysis program called cppcheck.
> > 
> > Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> > ---
> >  mm/memcontrol.c |    5 -----
> >  1 file changed, 5 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index d6ac0e3..5edd1fe 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4379,11 +4379,6 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
> >  }
> >  #endif /* CONFIG_NUMA */
> >  
> > -static inline void mem_cgroup_lru_names_not_uptodate(void)
> > -{
> > -	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
> > -}
> 
> That assertion doesn't work in an unused function, but we still want
> this check.  Please move the BUILD_BUG_ON() to the beginning of
> memcg_stat_show() instead.

Ohh. I have completely missed the point of the check! Moving the check
to memcg_stat_show sounds like a good idea.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
