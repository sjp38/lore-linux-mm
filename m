Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A35356B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:02:25 -0400 (EDT)
Date: Thu, 26 May 2011 13:02:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
In-Reply-To: <1306432645.16757.137.camel@jaguar>
Message-ID: <alpine.DEB.2.00.1105261300550.23596@router.home>
References: <20110516202605.274023469@linux.com>  <20110516202625.197639928@linux.com> <1306432645.16757.137.camel@jaguar>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, tj@kernel.org

On Thu, 26 May 2011, Pekka Enberg wrote:

> On Mon, 2011-05-16 at 15:26 -0500, Christoph Lameter wrote:
> > plain text document attachment (cmpxchg_double_x86)
> > A simple implementation that only supports the word size and does not
> > have a fallback mode (would require a spinlock).
> >
> > And 32 and 64 bit support for cmpxchg_double. cmpxchg double uses
> > the cmpxchg8b or cmpxchg16b instruction on x86 processors to compare
> > and swap 2 machine words. This allows lockless algorithms to move more
> > context information through critical sections.
> >
> > Set a flag CONFIG_CMPXCHG_DOUBLE to signal the support of that feature
> > during kernel builds.
> >
> > Signed-off-by: Christoph Lameter <cl@linux.com>
>
> You forgot to CC Tejun for this patch.

Ok. I can do that but the patch is not in the same context of the per cpu
stuff that we worked on earlier. This is fully locked version of
cmpxchg_double.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
