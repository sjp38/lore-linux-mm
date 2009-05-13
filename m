Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 824036B0108
	for <linux-mm@kvack.org>; Wed, 13 May 2009 10:30:04 -0400 (EDT)
Subject: Re: do we really want to export more pdflush details in sysctls
From: "Peter W. Morreale" <pmorreale@novell.com>
In-Reply-To: <20090513130811.GE4140@kernel.dk>
References: <20090513130128.GA10382@lst.de>
	 <20090513130811.GE4140@kernel.dk>
Content-Type: text/plain
Date: Wed, 13 May 2009 08:30:24 -0600
Message-Id: <1242225024.19182.174.camel@hermosa>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-05-13 at 15:08 +0200, Jens Axboe wrote:
> On Wed, May 13 2009, Christoph Hellwig wrote:
> > Hi all,
> > 
> > commit fafd688e4c0c34da0f3de909881117d374e4c7af titled
> > "mm: add /proc controls for pdflush threads" adds two more sysctl
> > variables exposing details about pdflush threads.  At the same time
> > Jens Axboe is working on the per-bdi writeback patchset which will
> > hopefull soon get rid of the pdflush threads in their current form.
> > 
> > Is it really a good idea to expose more details now or should we revert
> > this patch before 2.6.30 is out?
> 
> Pained me as well when updating the patchset. I see little value in
> these knobs as it is, I'm imagining that the submitter must have had a
> use case where it made some difference?
> 

No, I didn't.  The rational was as explained in the commit log, merely
that one size (eg: 2-8 threads) didn't fit all cases, so give the admin
a chance at tuning w/o having to recompile.  

More importantly, I didn't know that Jens was working on significant
changes to writeback.  This is sorely needed as from what I see in the
code, writeback is very unfair to 'fast' block devices (when both 'fast'
and 'slow' devices co-exist), and consequently, the apps that reference
them.  

Jens: When do you expect to complete the per-bdi patchset?

In any event, it is not a good idea to expose knobs that will soon be
obviated so please pull the patch. 


Thanks,
-PWM




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
