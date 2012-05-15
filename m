Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 27B266B0081
	for <linux-mm@kvack.org>; Tue, 15 May 2012 16:53:48 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so211122pbb.14
        for <linux-mm@kvack.org>; Tue, 15 May 2012 13:53:47 -0700 (PDT)
Date: Tue, 15 May 2012 13:53:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mm/memcg: apply add/del_page to lruvec
In-Reply-To: <4FB21988.40503@openvz.org>
Message-ID: <alpine.LSU.2.00.1205151337230.1416@eggly.anvils>
References: <alpine.LSU.2.00.1205132152530.6148@eggly.anvils> <alpine.LSU.2.00.1205132201210.6148@eggly.anvils> <4FB0E985.9000107@openvz.org> <alpine.LSU.2.00.1205141252060.1693@eggly.anvils> <4FB21988.40503@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 15 May 2012, Konstantin Khlebnikov wrote:
> Hugh Dickins wrote:
> > 
> > I had been hoping to get this stage, where I think we're still in
> > agreement (except perhaps on the ordering of function arguments!),
> > into 3.5 as a basis for later discussion.
> 
> Yeah, my version differs mostly in function's names and ordering of
> arguments.
> I use 'long' for last argument in mem_cgroup_update_lru_size(),
> and call it once in isolate_lru_pages(), rather than for each isolated page.

That sounds very sensible, now that lumpy isn't switching lruvecs:
can be done alongside the similarly deferred __mod_zone_page_state()s.

> You have single mem_cgroup_page_lruvec() variant, and this is biggest
> difference
> between our versions. So, Ok, nothing important at this stage.
> 
> Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Thanks a lot, I appreciate you going back to delve in, despite being
put off by appearances earlier.  Yes, I'm only dealing with the trivial
passing down of lruvec instead of zone here, where I felt we'd be sure
to more or less agree.  It seemed the right follow-on to your lruvec
work in vmscan.c, giving us both a good base in 3.5-rc1 on which to
try out our more interesting bits.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
