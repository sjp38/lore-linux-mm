Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 591FD6B004D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 19:23:34 -0500 (EST)
Date: Fri, 27 Feb 2009 16:22:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: get_nid_for_pfn() returns int
Message-Id: <20090227162249.bcd0813a.akpm@linux-foundation.org>
In-Reply-To: <20090228001400.GC7174@us.ibm.com>
References: <4973AEEC.70504@gmail.com>
	<20090119175919.GA7476@us.ibm.com>
	<20090126223350.610b0283.akpm@linux-foundation.org>
	<20090127210727.GA9592@us.ibm.com>
	<25e057c00902270656x1781d04er5703058e47df455f@mail.gmail.com>
	<20090227213340.GB7174@us.ibm.com>
	<20090227134616.982fb73a.akpm@linux-foundation.org>
	<20090228001400.GC7174@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gary Hade <garyhade@us.ibm.com>
Cc: roel.kluin@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 27 Feb 2009 16:14:00 -0800
Gary Hade <garyhade@us.ibm.com> wrote:

> On Fri, Feb 27, 2009 at 01:46:16PM -0800, Andrew Morton wrote:
>
> > > It is still lingering in -mm:
> > > http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-get_nid_for_pfn-returns-int.patch
> > > 
> > 
> > Should it unlinger?  I have it in the 2.6.30 pile.
> 
> Yes, that would be good. :)

What would be good?  Your answer is ambiguous.

> > Does it actually fix a demonstrable bug?  
> 
> I am not aware of anyone that has actually reproduced the
> problem.

What problem?

All I gave at present is

  From: Roel Kluin <roel.kluin@gmail.com>

  get_nid_for_pfn() returns int

  Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
  Cc: Gary Hade <garyhade@us.ibm.com>

>  I do not believe that we have any systems where 
> it can be reproduced since it would require both
>   (1) a memory section with an uninitialized range of
>       pages and
>   (2) a memory remove event for that memory section.
> As far as I know, none of our systems have (1).  Yasunori Goto
> has a system with (1) but I am not sure if he can do (2).

Please send a new changelog for this patch.

If you believe this patch should be merged into 2.6.29 then please
explain why.  Please also consider whether it should be backported into
2.6.28.x and eariler.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
