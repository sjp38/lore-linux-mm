Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 15EB26B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 16:41:23 -0400 (EDT)
Received: by yhjj63 with SMTP id j63so2032662yhj.9
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 13:41:22 -0700 (PDT)
Date: Wed, 11 Jul 2012 13:40:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: Warn about costly page allocation
In-Reply-To: <4FFD15B2.6020001@kernel.org>
Message-ID: <alpine.DEB.2.00.1207111337430.3635@chino.kir.corp.google.com>
References: <1341878153-10757-1-git-send-email-minchan@kernel.org> <20120709170856.ca67655a.akpm@linux-foundation.org> <20120710002510.GB5935@bbox> <alpine.DEB.2.00.1207101756070.684@chino.kir.corp.google.com> <20120711022304.GA17425@bbox>
 <alpine.DEB.2.00.1207102223000.26591@chino.kir.corp.google.com> <4FFD15B2.6020001@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, 11 Jul 2012, Minchan Kim wrote:

> I agree it's an ideal but the problem is that it's too late.
> Once product is released, we have to recall all products in the worst case.
> The fact is that lumpy have helped high order allocation implicitly but we removed it
> without any notification or information. It's a sort of regression and we can't say
> them "Please report us if it happens". It's irresponsible, too.
> IMHO, at least, what we can do is to warn about it before it's too late.
> 

High order allocations that fail should still display a warning message 
when __GFP_NOWARN is not set, so I don't see what this additional warning 
adds.  I don't think it's responsible to ask admins to know what lumpy 
reclaim is, what memory compaction is, or when a system tends to have more 
high order allocations when memory compaction would be helpful.

What we can do, though, is address bug reports as they are reported when 
high order allocations fail and previous kernels are successful.  I 
haven't seen any lately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
