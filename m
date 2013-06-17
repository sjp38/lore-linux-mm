Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 3E3E06B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 10:01:10 -0400 (EDT)
Date: Mon, 17 Jun 2013 16:01:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v4] Soft limit rework
Message-ID: <20130617140108.GE5018@dhcp22.suse.cz>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
 <20130611154353.GF31277@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130611154353.GF31277@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

On Tue 11-06-13 17:43:53, Michal Hocko wrote:
> JFYI, I have rebased the series on top of the current mmotm tree to
> catch up with Mel's changes in reclaim and other small things here and
> there. To be sure that the things are still good I have started my tests
> again which will take some time.

And it took way more time than I would like but the current mmotm is
broken and crashes/hangs and misbehaves in strange ways. At first I
thought it is my -mm git tree that is broken but then when I started
testing with linux-next I could see issues as well. I was able to reduce
the space to slab shrinkers rework but bisection led to nothing
reasonable. I will report those issues in a separate email when I
collect all necessary information.

In the meantime I will retest on top of my -mm tree without slab
shrinkers patches applied. This should be OK for the soft reclaim work
because memcg shrinkers are still not merged into mm tree and they
shouldn't be affected by the soft reclaim as the reclaim is per
shrink_zone now.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
