Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BC7678D0047
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 01:54:08 -0500 (EST)
Subject: Re: [PATCH/v2] mm/memblock: Properly handle overlaps and fix error
 path
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20110310064614.GE9289@elte.hu>
References: <1299466980.8833.973.camel@pasglop>
	 <4D77E5E0.6010706@kernel.org> <1299705610.22236.390.camel@pasglop>
	 <20110310064614.GE9289@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Mar 2011 17:53:38 +1100
Message-ID: <1299740018.22236.469.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Yinghai Lu <yinghai@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2011-03-10 at 07:46 +0100, Ingo Molnar wrote:
> > Ah interesting, so you did have a case of overlap that wasn't properly
> > handled as well.
> > 
> > If there is no objection, I'll queue that up in powerpc-next for the
> > upcoming merge window (soon now).
> 
> I think it would be better to do it via -mm, as x86 and other architectures are now 
> affected by memblock changes as well. 

No objection, Andrew, are you picking this up ?

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
