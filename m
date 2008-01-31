Date: Wed, 30 Jan 2008 17:03:06 -0800 (PST)
Message-Id: <20080130.170306.174974383.davem@davemloft.net>
Subject: Re: [PATCH 3/6] sparc64: Use generic percpu linux-2.6.git
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080130215223.GB28242@elte.hu>
References: <20080130180940.022172000@sgi.com>
	<20080130180940.506256000@sgi.com>
	<20080130215223.GB28242@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 30 Jan 2008 22:52:23 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: travis@sgi.com, Geert.Uytterhoeven@sonycom.com, torvalds@linux-foundation.org, tglx@linutronix.de, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> * travis@sgi.com <travis@sgi.com> wrote:
> 
> > Sparc64 has a way of providing the base address for the per cpu area 
> > of the currently executing processor in a global register.
> > 
> > Sparc64 also provides a way to calculate the address of a per cpu area 
> > from a base address instead of performing an array lookup.
> 
> has this been booted on SPARC64 and does David ACK this conversion?

Conceptually I'm fine with the changes.

I had these for testing in my backlog right before I came to
LCA08 and I won't be able to do any real testing until I get back
home on Feb 4th.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
