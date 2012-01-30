Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id E00816B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 16:02:11 -0500 (EST)
Received: by pbaa12 with SMTP id a12so5191170pba.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 13:02:11 -0800 (PST)
Date: Mon, 30 Jan 2012 13:01:46 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [LSF/MM TOPIC] [ATTEND] mm track: RAM utilization and page
 replacement topics
In-Reply-To: <f6fc422f-fbc2-4a19-b723-82c23f6aa3fe@default>
Message-ID: <alpine.LSU.2.00.1201301248440.4548@eggly.anvils>
References: <f6fc422f-fbc2-4a19-b723-82c23f6aa3fe@default>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Fri, 27 Jan 2012, Dan Magenheimer wrote:
> Some (related) topics proposed for the MM track:
> 
> 1) Optimizing the utilization of RAM as a resource, i.e. how do we teach the
>    kernel to NOT use all RAM when it doesn't really "need" it.  See
>    http://lwn.net/Articles/475681/ (or if you don't want to read the whole
>    article, start with "Interestingly, ..." four paragraphs from the end).
> 
> 2) RAMster now exists and works... where are the holes and what next?
>    http://marc.info/?l=linux-mm&m=132768187222840&w=2 
> 
> 3) Next steps in the page replacement algorithm:
> 	a) WasActive https://lkml.org/lkml/2012/1/25/300 
> 	b) readahead http://marc.info/?l=linux-scsi&m=132750980203130 
> 
> 4) Remaining impediments for merging frontswap
> 
> 5) Page flags and 64-bit-only... what are the tradeoffs?

Yes, this last one is something I want to discuss too.  If page_cgroup
hadn't grown so small, I'd be suggesting to squeeze some more flag bits
(or better, the node/zone info) into the 32-bit struct page lru pointers.

But with page_cgroup now ready to fit into the 64-bit struct page (which
contains an empty field from SLUB's alignment demands), it might - might -
be time to enlarge the 32-bit struct page slightly.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
