Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DF83D6B01F7
	for <linux-mm@kvack.org>; Wed, 12 May 2010 01:20:50 -0400 (EDT)
Subject: Re: [PATCH 03/25] lmb: Introduce for_each_lmb() and new accessors,
 and use it
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.2.00.1005101735560.3401@localhost.localdomain>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
	 <alpine.LFD.2.00.1005101735560.3401@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 12 May 2010 15:20:32 +1000
Message-ID: <1273641632.21352.107.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-05-10 at 17:39 +0200, Thomas Gleixner wrote:
> > +#define for_each_lmb(lmb_type, region)                                       \
> > +     for (reg = lmb.lmb_type.regions;                                \
> > +          region < (lmb.lmb_type.regions + lmb.lmb_type.cnt);        \
> > +          region++)
> > +
> 
> Can you please make this:
> 
> #define for_each_lmb(lmb_type, region, __iter)                          \
>         for (__iter = lmb.lmb_type.regions;                             \
>              region < (lmb.lmb_type.regions + lmb.lmb_type.cnt);        \
>              region++)
> 
> so we do not have the iterator name hardcoded inside the macro body.

As a matter of fact, we didn't, but I made a typo on the first one:

-	for (reg = lmb.lmb_type.regions;                                   \
+	for (region = lmb.lmb_type.regions;                                \
		region < (lmb.lmb_type.regions + lmb.lmb_type.cnt);        \
	        region++)

I'll fix that in my series.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
