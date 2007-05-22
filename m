Date: Tue, 22 May 2007 12:57:10 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] mm: swap prefetch improvements
Message-ID: <20070522105710.GA12833@elte.hu>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705222037.54741.kernel@kolivas.org> <20070522104648.GA10622@elte.hu> <200705222054.46488.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200705222054.46488.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Antonino Ingargiola <tritemio@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Con Kolivas <kernel@kolivas.org> wrote:

> On Tuesday 22 May 2007 20:46, Ingo Molnar wrote:
> > It clearly should not consider 'itself' as IO activity. This 
> > suggests some bug in the 'detect activity' mechanism, agreed? I'm 
> > wondering whether you are seeing the same problem, or is all 
> > swap-prefetch IO on your system continuous until it's done [or some 
> > other IO comes inbetween]?
> 
> When nothing else is happening anywhere on the system it reads in 
> bursts and goes to sleep during journal writeout.

hm, what do you call 'journal writeout' here that would be happening on 
my system?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
