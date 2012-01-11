Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 7B5776B006C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 02:25:49 -0500 (EST)
Received: by ghrr18 with SMTP id r18so205750ghr.14
        for <linux-mm@kvack.org>; Tue, 10 Jan 2012 23:25:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120109213357.148e7927@annuminas.surriel.com>
References: <20120109213156.0ff47ee5@annuminas.surriel.com> <20120109213357.148e7927@annuminas.surriel.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 11 Jan 2012 02:25:26 -0500
Message-ID: <CAHGf_=rj=aDVGWXqdq7fh_LrCFnug_mPNuuE=YdXaWpvwyjfzg@mail.gmail.com>
Subject: Re: [PATCH -mm 2/2] mm: kswapd carefully invoke compaction
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, aarcange@redhat.com, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com

> With CONFIG_COMPACTION enabled, kswapd does not try to free
> contiguous free pages, even when it is woken for a higher order
> request.
>
> This could be bad for eg. jumbo frame network allocations, which
> are done from interrupt context and cannot compact memory themselves.
> Higher than before allocation failure rates in the network receive
> path have been observed in kernels with compaction enabled.
>
> Teach kswapd to defragment the memory zones in a node, but only
> if required and compaction is not deferred in a zone.
>
> Signed-off-by: Rik van Riel <riel@redhat.com>

I agree with we need asynchronous defragmentations feature. But, do we
really need to use kswapd for compaction? While kswapd take a
compaction work, it can't work to make
free memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
