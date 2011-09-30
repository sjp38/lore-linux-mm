Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1379000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 13:02:02 -0400 (EDT)
Date: Fri, 30 Sep 2011 10:01:58 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: Re: RFC -- new zone type
Message-ID: <20110930170158.GC7007@labbmf-linux.qualcomm.com>
References: <20110928180909.GA7007@labbmf-linux.qualcomm.com>
 <m2aa9nhzjf.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m2aa9nhzjf.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Larry Bassel <lbassel@codeaurora.org>, linux-mm@kvack.org, vgandhi@codeaurora.org

On 29 Sep 11 13:19, Andi Kleen wrote:
> Larry Bassel <lbassel@codeaurora.org> writes:
> >
> > It was suggested to me that a new zone type which would be similar
> > to the "movable zone" but is only allowed to contain pages
> > that can be discarded (such as text) could solve this problem,
> 
> This may not actually be a win because if the text pages are needed
> afterwards the act of rereading them from disk would likely take longer
> than the copying.

Yes, I'm aware of this (they'd actually be coming from flash
which is even slower, right?).

> 
> The so you many not get latency before, but after.
> 
> Essentially robbing Peter to pay Paul.

Yes, the goal is to create this large contiguous memory
quickly, even if performance is worse later on for a while.

> 
> If the goal is to just spread the latency over a longer time
> I'm sure there are better ways to do that than to add a new zone.

I myself am not an advocate of creating this new zone (because
I think there may not be a lot of benefit to it for the
amount of work involved), but I want to solicit people's
opinions about it and collect suggestions (such as Dan's)
about alternate approaches that may be better/closer
to already implemented (I'd likely have to port them
to ARM as they probably were developed for x86, but I don't
think that's a problem) that will handle our use case.

I wonder if another reasonable approach might be a combination
of memory compaction in the background when the machine
is otherwise idle, combined with occasional killing of
processes that haven't been used for a long time (this is
going to be run on an android user environment, android
likes to leave lots of unused processes running in the
background).

> 
> -Andi

Larry

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
