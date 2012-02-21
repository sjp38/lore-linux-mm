Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id E8DBE6B00EC
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:26:18 -0500 (EST)
Received: by dadv6 with SMTP id v6so9024584dad.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 14:26:18 -0800 (PST)
Date: Tue, 21 Feb 2012 14:25:54 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 4/10] mm/memcg: apply add/del_page to lruvec
In-Reply-To: <20120221172042.20f407fe.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1202211421170.2012@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils> <alpine.LSU.2.00.1202201530530.23274@eggly.anvils> <20120221172042.20f407fe.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Many thanks for inspecting these, and so soon.

On Tue, 21 Feb 2012, KAMEZAWA Hiroyuki wrote:
> 
> Hmm.. a nitpick.
> 
> You do 
>   lruvec = mem_cgroup_page_lruvec(page, zone);
> 
> What is the difference from
> 
>   lruvec = mem_cgroup_page_lruvec(page, page_zone(page)) 
> 
> ?

I hope they were equivalent: I just did it that way because in all cases
the zone had already been computed, so that saved recomputing it - as I
understand it, in some layouts (such as mine) it's pretty cheap to work
out the page's zone, but in others an expense to be avoided.

But then you discovered that it soon got removed again anyway.

Hugh

> 
> If we have a function
>   lruvec = mem_cgroup_page_lruvec(page)
> 
> Do we need 
>   lruvec = mem_cgroup_page_lruvec_zone(page, zone) 
> 
> ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
