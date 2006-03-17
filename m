Date: Fri, 17 Mar 2006 10:06:53 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [ck] Re: [PATCH] mm: yield during swap prefetching
Message-ID: <20060317090653.GC13387@elte.hu>
References: <200603081013.44678.kernel@kolivas.org> <20060307152636.1324a5b5.akpm@osdl.org> <cone.1141774323.5234.18683.501@kolivas.org> <200603090036.49915.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200603090036.49915.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: ck@vds.kolivas.org, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Con Kolivas <kernel@kolivas.org> wrote:

> > We do have SCHED_BATCH but even that doesn't really have the desired
> > effect. I know how much yield sucks and I actually want it to suck as much
> > as yield does.
> 
> Thinking some more on this I wonder if SCHED_BATCH isn't a strong 
> enough scheduling hint if it's not suitable for such an application. 
> Ingo do you think we could make SCHED_BATCH tasks always wake up on 
> the expired array?

yep, i think that's a good idea. In the worst case the starvation 
timeout should kick in.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
