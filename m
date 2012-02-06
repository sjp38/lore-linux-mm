Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 5BCA86B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 16:00:38 -0500 (EST)
Received: by dadv6 with SMTP id v6so6474660dad.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 13:00:37 -0800 (PST)
Date: Mon, 6 Feb 2012 13:00:05 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] compact_pgdat: workaround lockdep warning in kswapd
In-Reply-To: <20120206124952.75702d5c.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1202061251580.2505@eggly.anvils>
References: <alpine.LSU.2.00.1202061129040.2144@eggly.anvils> <20120206124952.75702d5c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org

On Mon, 6 Feb 2012, Andrew Morton wrote:
> On Mon, 6 Feb 2012 11:40:08 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > I get this lockdep warning from swapping load on linux-next
> > (20120201 but I expect the same from more recent days):
> 
> The patch looks good as a standalone optimisation/cleanup.  The lack of
> clarity on the lockdep thing is a concern - I have a feeling we'll be
> bitten again.

lockdep's delphic mutterings generally strain my brain; but it has an
embarrassing habit of proving right after you think it's plain wrong.

> 
> This fix seems to be applicable to mainline?

No, that call from kswapd to compact_pgdat() comes from a recent
mmotm patch by Rik, "vmscan: kswapd carefully call compaction"
(but I suspect my patch doesn't fit in immediately after that,
I think there were maybe more changes in between).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
