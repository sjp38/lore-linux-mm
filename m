Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 692D36B023B
	for <linux-mm@kvack.org>; Tue, 11 May 2010 00:56:41 -0400 (EDT)
Subject: Re: [PATCH 21/25] lmb: Add "start" argument to lmb_find_base()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <AANLkTimhvJUX2S2eIY8rpw4TnUrDUFicMxEZkLK3hu1N@mail.gmail.com>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-19-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-20-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-21-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-22-git-send-email-benh@kernel.crashing.org>
	 <AANLkTimhvJUX2S2eIY8rpw4TnUrDUFicMxEZkLK3hu1N@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 11 May 2010 14:56:26 +1000
Message-ID: <1273553786.21352.2.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-05-10 at 16:37 -0700, Yinghai Lu wrote:

> >                if (lmbsize < size)
> >                        continue;
> > -               base = min(lmbbase + lmbsize, max_addr);
> > -               res_base = lmb_find_region(lmbbase, base, size, align);
> > -               if (res_base != LMB_ERROR)
> > -                       return res_base;
> > +               if ((lmbbase + lmbsize) <= start)
> > +                       break;
> > +               bottom = max(lmbbase, start);
> > +               top = min(lmbbase + lmbsize, end);
> > +               if (bottom >= top)
> > +                       continue;
> > +               found = lmb_find_region(lmbbase, top, size, align);
>                                                                ^^^^^^^^^
> should use bottom  here

Correct, I missed that when converting.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
