Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BA8EB6B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:59:38 -0400 (EDT)
Date: Fri, 10 Jun 2011 19:58:58 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
	instead of failing
Message-ID: <20110610185858.GN24424@n2100.arm.linux.org.uk>
References: <alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com> <20110601181918.GO3660@n2100.arm.linux.org.uk> <alpine.LFD.2.02.1106012043080.3078@ionos> <alpine.DEB.2.00.1106011205410.17065@chino.kir.corp.google.com> <alpine.LFD.2.02.1106012134120.3078@ionos> <4DF1C9DE.4070605@jp.fujitsu.com> <20110610004331.13672278.akpm@linux-foundation.org> <BANLkTimC8K2_H7ZEu2XYoWdA09-3XxpV7Q@mail.gmail.com> <20110610091233.GJ24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101150280.17197@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1106101150280.17197@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

On Fri, Jun 10, 2011 at 11:54:16AM -0700, David Rientjes wrote:
> On Fri, 10 Jun 2011, Russell King - ARM Linux wrote:
> 
> > > Should one submit a patch adding a warning to GFP_DMA allocations
> > > w/o ZONE_DMA, or the idea of the original patch is wrong?
> > 
> > Linus was far from impressed by the original commit, saying:
> > | Using GFP_DMA is reasonable in a driver - on platforms where that
> > | matters, it should allocate from the DMA zone, on platforms where it
> > | doesn't matter it should be a no-op.
> > 
> > So no, not even a warning.
> > 
> 
> Any words of wisdom for users with CONFIG_ZONE_DMA=n that actually use 
> drivers where they need GFP_DMA?  The page allocator should just silently 
> return memory from anywhere?

See Linus' reply.  I quote again "on platforms where it doesn't matter it
should be a no-op".  If _you_ have a problem with that _you_ need to
discuss it with _Linus_, not me.  I'm not going to be a middle-man sitting
between two people with different opinions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
