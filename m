Message-ID: <418D8138.9080401@yahoo.com.au>
Date: Sun, 07 Nov 2004 12:58:16 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
References: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com> <418CA535.1030703@yahoo.com.au> <20041106103103.GC2890@holomorphy.com> <418CAA44.3090007@yahoo.com.au> <20041106105314.GD2890@holomorphy.com> <418CB06F.1080405@yahoo.com.au> <20041106120624.GE2890@holomorphy.com> <418CBED7.6050609@yahoo.com.au> <20041106122355.GF2890@holomorphy.com> <418D7235.7010501@yahoo.com.au> <20041107011113.GJ2890@holomorphy.com>
In-Reply-To: <20041107011113.GJ2890@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:

> 
> No, they remain an option and a good one. The space requirements are
> not an issue. If Lameter's customers have 10000 cpus they have the RAM
> and kernel virtualspace for split counters.
> 

I said not an option for 2.6. Which I still believe they are not. Yes
they are an option for a private kernel, as may be the address walking
method first posted.

> Your purported "tests" have a rather obvious predetermined conclusion.
> Some minute amount of overhead for normal machines will be exaggerated
> in a supercomputer environment, and all of the detriments will be
> carefully hidden by avoiding monitoring processes or monitoring only
> low numbers of them.
> 

I thought Christoph would be very interested to see the worst cases in
semi real world workloads that his systems actually run.

I didn't realise this is part of a conspiracy to covertly back out all
your work. Maybe Jeff Merkey is behind it, and you're the last freedom
loving kernel hacker who won't sell out? ;)

> The proposal, on the other hand, has received more objections since my
> own, and from various sources.
> 

Yes, I was CCed on them, even. We're past the fact that it won't get
into the kernel - I just meant maybe it's acceptable for Christoph
(although it seems unlikely to not have failure cases, even for him).

> Now to brace myself for another of your petty "last word" shenanigans.
> 

I tried to think up some witty remark to go here but couldn't.

OK, sorry. Whatever I've done to offend you I didn't intend it. We don't
always seem to be talking on the same level... Can we try to be more
light hearted about things? I'm really not interested in shenanigans of
any kind with you.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
