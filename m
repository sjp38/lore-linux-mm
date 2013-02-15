Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 0A2416B0009
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 20:28:59 -0500 (EST)
Received: by mail-ve0-f201.google.com with SMTP id 14so310821vea.2
        for <linux-mm@kvack.org>; Thu, 14 Feb 2013 17:28:59 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 0/7] memcg targeted shrinking
References: <1360328857-28070-1-git-send-email-glommer@parallels.com>
Date: Thu, 14 Feb 2013 17:28:57 -0800
In-Reply-To: <1360328857-28070-1-git-send-email-glommer@parallels.com>
	(Glauber Costa's message of "Fri, 8 Feb 2013 17:07:30 +0400")
Message-ID: <xr93ip5unz52.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org

On Fri, Feb 08 2013, Glauber Costa wrote:

> This patchset implements targeted shrinking for memcg when kmem limits are
> present. So far, we've been accounting kernel objects but failing allocations
> when short of memory. This is because our only option would be to call the
> global shrinker, depleting objects from all caches and breaking isolation.
>
> This patchset builds upon the recent work from David Chinner
> (http://oss.sgi.com/archives/xfs/2012-11/msg00643.html) to implement NUMA
> aware per-node LRUs. I build heavily on its API, and its presence is implied.
>
> The main idea is to associate per-memcg lists with each of the LRUs. The main
> LRU still provides a single entry point and when adding or removing an element
> from the LRU, we use the page information to figure out which memcg it belongs
> to and relay it to the right list.
>
> This patchset is still not perfect, and some uses cases still need to be
> dealt with. But I wanted to get this out in the open sooner rather than
> later. In particular, I have the following (noncomprehensive) todo list:
>
> TODO:
> * shrink dead memcgs when global pressure kicks in.
> * balance global reclaim among memcgs.
> * improve testing and reliability (I am still seeing some stalls in some cases)

Do you have a git tree with these changes so I can see Dave's numa LRUs
plus these changes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
