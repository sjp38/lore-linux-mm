Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 48A786B0201
	for <linux-mm@kvack.org>; Wed, 12 May 2010 01:24:47 -0400 (EDT)
Subject: Re: [PATCH 05/25] lmb: Factor the lowest level alloc function
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.2.00.1005111428470.3401@localhost.localdomain>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
	 <alpine.LFD.2.00.1005111428470.3401@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 12 May 2010 15:24:09 +1000
Message-ID: <1273641849.21352.109.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-05-11 at 14:30 +0200, Thomas Gleixner wrote:
> On Mon, 10 May 2010, Benjamin Herrenschmidt wrote:
> >  
> > @@ -396,33 +406,24 @@ u64 __init __lmb_alloc_base(u64 size, u64 align, u64 max_addr)
> >  	if (max_addr == LMB_ALLOC_ANYWHERE)
> >  		max_addr = LMB_REAL_LIMIT;
> >  
> > +	/* Pump up max_addr */
> > +	if (max_addr == LMB_ALLOC_ANYWHERE)
> > +		max_addr = ~(u64)0;
> > +	
> 
>   That if is pretty useless as you set max_addr to LMB_REAL_LIMIT
>   right above.

Well, actually no :-) LMB_REAL_LIMIT can actually be == to
LMB_ALLOC_ANYWHERE which at this stage in the series is still 0, so we
must not miss the second bit.

Subsequent patches remove this anyways as LMB_ALLOC_ANYWHERE gets turned
into ~0 which makes more sense.

So it's a bit weird looking, but it's correct and transitory code only.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
