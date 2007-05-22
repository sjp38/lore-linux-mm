Date: Tue, 22 May 2007 13:12:30 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] mm: swap prefetch improvements
Message-ID: <20070522111230.GA15616@elte.hu>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705222054.46488.kernel@kolivas.org> <20070522105710.GA12833@elte.hu> <200705222104.20580.kernel@kolivas.org> <20070522111104.GA14950@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070522111104.GA14950@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Antonino Ingargiola <tritemio@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Con Kolivas <kernel@kolivas.org> wrote:
 
> > hm, what do you call 'journal writeout' here that would be happening 
> > on my system?
> 
> Not really sure what you have in terms of fs, but here even with 
> nothing going on, ext3 writes to disk every 5 seconds with kjournald.

i have ext3, but it doesnt do that on my box. Also, i would have noticed 
any IO activity in the 'swap prefetch off' case. When i said completely 
idle, i really meant it ;-)

so swap-prefetch stops for 5 seconds for no apparent reason.
 
	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
