Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 988526B004A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 19:11:23 -0400 (EDT)
Subject: Re: [PATCH 1/2] mm: Move definition of MIN_MEMORY_BLOCK_SIZE to a
 header
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20110701121408.GC28008@elte.hu>
References: <1308013070.2874.784.camel@pasglop>
	 <20110701121408.GC28008@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 02 Jul 2011 09:11:06 +1000
Message-ID: <1309561866.14501.254.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Fri, 2011-07-01 at 14:14 +0200, Ingo Molnar wrote:
> * Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > The macro MIN_MEMORY_BLOCK_SIZE is currently defined twice in two .c
> > files, and I need it in a third one to fix a powerpc bug, so let's
> > first move it into a header
> > 
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > ---
> > 
> > Ingo, Thomas: Who needs to ack the x86 bit ? I'd like to send that
> > to Linus asap with the powerpc fix.
> 
> Acked-by: Ingo Molnar <mingo@elte.hu>
> 
> (btw., you can consider obvious cleanups as being implicitly acked by 
> me and don't need to block fixes on me.)

Ok thanks !

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
