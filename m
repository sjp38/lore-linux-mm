Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 958948D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 19:50:17 -0500 (EST)
Subject: Re: [RFC] memblock; Properly handle overlaps
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <4D72C552.4050406@kernel.org>
References: <1299297946.8833.931.camel@pasglop>
	 <4D71CE24.1090302@kernel.org> <1299311788.8833.937.camel@pasglop>
	 <4D728B8C.2080803@kernel.org> <1299361063.8833.953.camel@pasglop>
	 <4D72B2D0.3080700@kernel.org> <1299363583.8833.964.camel@pasglop>
	 <4D72C552.4050406@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 06 Mar 2011 11:49:54 +1100
Message-ID: <1299372594.8833.966.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H.
 Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>

On Sat, 2011-03-05 at 15:20 -0800, Yinghai Lu wrote:
> 
> maybe we can omit rgn->size == 0 checking here.
> with that case, dummy array will go though to some extra checking.
> 
> if (rgn->base <= base && rend >= end)
> if (base < rgn->base && end >= rgn->base) {
> if (base <= rend && end >= rend) {
> 
> but we can spare more checking regarding
>         rgn->size == 0

Well, the array can be collasped to dummy by the removal of the last
block when doing a top overlap, then on the next loop around, we can
potentially hit the if (base <= rend && end >= rend) test, and loop
again no ?

I'd rather keep the test in .. won't hurt.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
