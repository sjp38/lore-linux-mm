Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 158066B01F0
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 03:36:23 -0400 (EDT)
Date: Wed, 14 Apr 2010 17:36:12 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100414073612.GL2493@dastard>
References: <20100413201635.D119.A69D9226@jp.fujitsu.com>
 <20100413143659.GA2493@dastard>
 <20100414155201.D14A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100414155201.D14A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 03:52:10PM +0900, KOSAKI Motohiro wrote:
> > On Tue, Apr 13, 2010 at 08:39:29PM +0900, KOSAKI Motohiro wrote:
> > > Thanks explanation. I haven't noticed direct reclaim consume
> > > 2k stack. I'll investigate it and try diet it.
> > > But XFS 3.5K stack consumption is too large too. please diet too.
> > 
> > It hasn't grown in the last 2 years after the last major diet where
> > all the fat was trimmed from it in the last round of the i386 4k
> > stack vs XFS saga. it seems that everything else around XFS has
> > grown in that time, and now we are blowing stacks again....
> 
> I have dumb question, If xfs haven't bloat stack usage, why 3.5
> stack usage works fine on 4k stack kernel? It seems impossible.

Because on a 32 bit kernel it's somewhere between 2-2.5k of stack
space. That being said, XFS _will_ blow a 4k stack on anything other
than the most basic storage configurations, and if you run out of
memory it is almost guaranteed to do so.

> Please don't think I blame you. I don't know what is "4k stack vs XFS saga".
> I merely want to understand what you said.

Over a period of years there were repeated attempts to make the
default stack size on i386 4k, despite it being known to cause
problems one relatively common configurations. Every time it was
brought up it was rejected, but every few months somebody else made
an attempt to make it the default. There was a lot of flamage
directed at XFS because it was seen as the reason that 4k stacks
were not made the default....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
