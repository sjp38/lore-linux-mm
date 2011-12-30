Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id E48036B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 20:55:28 -0500 (EST)
Received: by iacb35 with SMTP id b35so29428879iac.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 17:55:28 -0800 (PST)
Date: Thu, 29 Dec 2011 17:55:14 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
In-Reply-To: <4EFD04B2.7050407@gmail.com>
Message-ID: <alpine.LSU.2.00.1112291753350.3614@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282037000.1362@eggly.anvils> <20111229145548.e34cb2f3.akpm@linux-foundation.org> <alpine.LSU.2.00.1112291510390.4888@eggly.anvils> <4EFD04B2.7050407@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org

On Thu, 29 Dec 2011, KOSAKI Motohiro wrote:
> 
> When lumpy reclaim occur, isolate_lru_pages() gather much pages than
> SWAP_CLUSTER_MAX.

Oh, good point, I hadn't thought of that.

> However, at that time, I think this patch behave
> better than old. If we release and retake zone lock per 14 pages,
> other tasks can easily steal a part of lumpy reclaimed pages. and then
> long latency wrongness will be happen when system is under large page
> memory allocation pressure. That's the reason why I posted very similar patch
> a long time ago.

Aha, and another good point.  Thank you.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
