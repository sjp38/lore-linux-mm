Date: Wed, 30 Jan 2008 22:52:23 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 3/6] sparc64: Use generic percpu linux-2.6.git
Message-ID: <20080130215223.GB28242@elte.hu>
References: <20080130180940.022172000@sgi.com> <20080130180940.506256000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080130180940.506256000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

* travis@sgi.com <travis@sgi.com> wrote:

> Sparc64 has a way of providing the base address for the per cpu area 
> of the currently executing processor in a global register.
> 
> Sparc64 also provides a way to calculate the address of a per cpu area 
> from a base address instead of performing an array lookup.

has this been booted on SPARC64 and does David ACK this conversion?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
