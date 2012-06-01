Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 9E5816B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 13:54:53 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3980401dak.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 10:54:53 -0700 (PDT)
Date: Fri, 1 Jun 2012 10:54:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] rename MEM_CGROUP_STAT_SWAPOUT as
 MEM_CGROUP_STAT_NR_SWAP
In-Reply-To: <20120601165320.GA1761@cmpxchg.org>
Message-ID: <alpine.LSU.2.00.1206011047430.9814@eggly.anvils>
References: <4FC89BC4.9030604@jp.fujitsu.com> <20120601165320.GA1761@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, akpm@linux-foundation.org

On Fri, 1 Jun 2012, Johannes Weiner wrote:
> On Fri, Jun 01, 2012 at 07:39:00PM +0900, Kamezawa Hiroyuki wrote:
> > MEM_CGROUP_STAT_SWAPOUT represents the usage of swap rather than
> > the number of swap-out events. Rename it to be MEM_CGROUP_STAT_NR_SWAP.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Wouldn't MEM_CGROUP_STAT_SWAP be better?  It's equally descriptive but
> matches the string.  And we also don't have NR_ for cache, rss, mapped
> file etc.

That's just what I thought too.

You can attach Acked-by: Hugh Dickins <hughd@google.com>
to MEM_CGROUP_STAT_SWAP and MEM_CGROUP_CHARGE_TYPE_ANON.

Oh, and to a patch deleting MEM_CGROUP_CHARGE_TYPE_FORCE!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
