Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id CAF476B0031
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 11:36:36 -0400 (EDT)
Date: Fri, 7 Jun 2013 17:36:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM Killer and add_to_page_cache_locked
Message-ID: <20130607153635.GJ8117@dhcp22.suse.cz>
References: <51B05616.9050501@adocean-global.com>
 <20130606155323.GD24115@dhcp22.suse.cz>
 <51B1F8B3.8030108@adocean-global.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51B1F8B3.8030108@adocean-global.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Nowojski <piotr.nowojski@adocean-global.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 07-06-13 17:13:55, Piotr Nowojski wrote:
> W dniu 06.06.2013 17:57, Michal Hocko pisze:
> >>>In our system we have hit some very annoying situation (bug?) with
> >>>cgroups. I'm writing to you, because I have found your posts on
> >>>mailing lists with similar topic. Maybe you could help us or point
> >>>some direction where to look for/ask.
> >>>
> >>>We have system with ~15GB RAM (+2GB SWAP), and we are running ~10
> >>>heavy IO processes. Each process is using constantly 200-210MB RAM
> >>>(RSS) and a lot of page cache. All processes are in cgroup with
> >>>following limits:
> >>>
> >>>/sys/fs/cgroup/taskell2 $ cat memory.limit_in_bytes
> >>>memory.memsw.limit_in_bytes
> >>>14183038976
> >>>15601344512
> >I assume that memory.use_hierarchy is 1, right?
> System has been rebooted since last test, so I can not guarantee
> that it was set for 100%, but it should have been. Currently I'm
> rerunning this scenario that lead to the described problem with:
> 
> /sys/fs/cgroup/taskell2# cat memory.use_hierarchy ../memory.use_hierarchy
> 1
> 0

OK, good. Your numbers suggeste that the hierachy _is_ in use. I just
wanted to be 100% sure.

[...]
> >The core thing to find out is why the hard limit reclaim is not able to
> >free anything. Unfortunatelly we do not have memcg reclaim statistics so
> >it would be a bit harder. I would start with the above patch first and
> >then I can prepare some debugging patches for you.
> I will try 3.6 (probably 3.7) kernel after weekend - unfortunately

I would simply try 3.9 (stable) and skip those two.

> repeating whole scenario is taking 10-30 hours because of very
> slowly growing page cache.

OK, this is good to know.

> >Also does 3.4 vanila (or the stable kernel) behave the same way? Is the
> >current vanilla behaving the same way?
> I don't know, we are using standard kernel that comes from Ubuntu.

yes, but I guess ubuntu, like any other distro puts some pathces on top
of vanilla kernel.

> >Finally, have you seen the issue for a longer time or it started showing
> >up only now?
> >
> This system is very new. We have started testing scenario which
> triggered OOM something like one week ago and we have immediately
> hit this issue. Previously, with different scenarios and different
> memory usage by processes we didn't have this issue.

OK

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
