Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 432196B002B
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 18:23:40 -0400 (EDT)
Received: by lbon3 with SMTP id n3so674673lbo.14
        for <linux-mm@kvack.org>; Thu, 09 Aug 2012 15:23:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120808174549.1b10d51a@cuia.bos.redhat.com>
References: <20120808174549.1b10d51a@cuia.bos.redhat.com>
Date: Thu, 9 Aug 2012 15:23:37 -0700
Message-ID: <CALWz4iwadc+z1zh47Y-ONOZ4EJTgwsQp1RWCRQfwAHboWQVoxQ@mail.gmail.com>
Subject: Re: [RFC][PATCH -mm 0/3] mm,vmscan: reclaim from highest score cgroup
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

On Wed, Aug 8, 2012 at 2:45 PM, Rik van Riel <riel@redhat.com> wrote:
> Instead of doing round robin reclaim over all the cgroups in a zone, we
> reclaim from the highest score cgroup first.
>
> Factors in the scoring are the use ratio of pages in the lruvec
> (recent_rotated / recent_scanned), the size of the lru, the recent amount
> of pressure applied to each lru, whether the cgroup is over its soft limit
> and whether the cgroup has lots of inactive file pages.
>
> This patch series is on top of a recent mmotm with Ying's memcg softreclaim
> patches [2/2] applied.  Unfortunately it turns out that that mmmotm tree
> with Ying's patches does not compile with CONFIG_MEMCG=y, so I am testing
> these patches over the wall untested, as inspiration for others (hi Ying).

Hmm, I don't have build problem before and after your patchset.
Wondering if we are talking about two different trees.  I based my
work on git://github.com/mstsxfx/memcg-devel.git

$ git log --oneline --decorate
f1979e3 (tag: mmotm-2012-07-25-16-41, github-memcg/since-3.5)
remove-__gfp_no_kswapd-fixes-fix

--Ying

>
> This still suffers from the same scalability issue the current code has,
> namely a round robin iteration over all the lruvecs in a zone. We may want
> to fix that in the future by sorting the memcgs/lruvecs in some sort of
> tree, allowing us to find the high priority ones more easily and doing the
> recalculation asynchronously and less often.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
