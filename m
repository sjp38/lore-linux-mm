Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1116B003D
	for <linux-mm@kvack.org>; Sat, 14 Feb 2009 18:31:41 -0500 (EST)
Date: Sat, 14 Feb 2009 15:31:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
Message-Id: <20090214153124.73132bf9.akpm@linux-foundation.org>
In-Reply-To: <20090214230802.GE20477@elte.hu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz>
	<20090213152836.0fbbfa7d.akpm@linux-foundation.org>
	<20090214230802.GE20477@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, orenl@cs.columbia.edu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Sun, 15 Feb 2009 00:08:02 +0100 Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > Similar to the way in which perfectly correct and normal kernel
> > sometimes has to be changed because it unexpectedly upsets the -rt
> > patch.
> 
> Actually, regarding -rt, we try to keep that in two buckets:
> 
>  1) Normal kernel code works but is unclean or structured less
>     than ideal. In this case we restructure the mainline code,
>     but that change stands on its own four legs, without any
>     -rt considerations.
> 
>  2) Normal kernel code that is clean - i.e. a change that only
>     matters to -rt. In this case we dont touch the mainline code,
>     nor do we bother mainline.
> 
> Do you know any specific example that falls outside of those categories?
> 

It happens fairly regularly.  Problems with irqs-off regions, problems
with preempt_disable() regions (came up just yesterday with a patch from
Jeremy).

Plus some convert-to-sleeping-lock conversions over the years which
weren't obviously needed in mainline.  Or which at least had -rt
motivations.  But that's different.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
