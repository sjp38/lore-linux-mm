Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AC7A16B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 05:47:07 -0400 (EDT)
Date: Mon, 13 Jun 2011 11:47:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
Message-ID: <20110613094704.GD10563@tiehlicka.suse.cz>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 01-06-11 08:25:11, Johannes Weiner wrote:
> Hi,
> 
> this is the second version of the memcg naturalization series.  The
> notable changes since the first submission are:
> 
>     o the hierarchy walk is now intermittent and will abort and
>       remember the last scanned child after sc->nr_to_reclaim pages
>       have been reclaimed during the walk in one zone (Rik)
> 
>     o the global lru lists are never scanned when memcg is enabled
>       after #2 'memcg-aware global reclaim', which makes this patch
>       self-sufficient and complete without requiring the per-memcg lru
>       lists to be exclusive (Michal)
> 
>     o renamed sc->memcg and sc->current_memcg to sc->target_mem_cgroup
>       and sc->mem_cgroup and fixed their documentation, I hope this is
>       better understandable now (Rik)
> 
>     o the reclaim statistic counters have been renamed.  there is no
>       more distinction between 'pgfree' and 'pgsteal', it is now
>       'pgreclaim' in both cases; 'kswapd' has been replaced by
>       'background'
> 
>     o fixed a nasty crash in the hierarchical soft limit check that
>       happened during global reclaim in memcgs that are hierarchical
>       but have no hierarchical parents themselves
> 
>     o properly implemented the memcg-aware unevictable page rescue
>       scanner, there were several blatant bugs in there
> 
>     o documentation on new public interfaces
> 
> Thanks for your input on the first version.

I have finally got through the whole series, sorry that it took so long,
and I have to say that I like it. There is just one issue I can see that
was already discussed by you and Ying regarding further soft reclaim
enhancement. I think it will be much better if that one comes as a
separate patch though.

So thank you for this work and I am looking forward for a new version.
I will try to give it some testing as well.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
