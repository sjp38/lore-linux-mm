Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 2ACCF6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 18:37:59 -0500 (EST)
Date: Tue, 20 Dec 2011 15:37:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [v2] mempolicy: refix mbind_range() vma issue
Message-Id: <20111220153757.8d80af1e.akpm@linux-foundation.org>
In-Reply-To: <20111220192850.GB3870@cmpxchg.org>
References: <20111212112000.GB18789@cmpxchg.org>
	<1324405032-22281-1-git-send-email-kosaki.motohiro@gmail.com>
	<20111220192850.GB3870@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Caspar Zhang <caspar@casparzhang.com>, Stephen Wilson <wilsons@start.ca>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, 20 Dec 2011 20:28:50 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Minchan Kim <minchan.kim@gmail.com>
> > CC: Caspar Zhang <caspar@casparzhang.com>
> 
> Looks good to me now, thanks.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Since this can corrupt virtual mappings and was released with 3.2, I
> think we also want this:
> 
> Cc: stable@kernel.org [3.2.x]

I assume you meant 3.1.x  And into mainline for 3.2?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
