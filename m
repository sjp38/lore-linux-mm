Subject: Re: interrupt context
From: Robert Love <rml@tech9.net>
In-Reply-To: <200304141851.h3EIpZjV015008@sith.maoz.com>
References: <200304141851.h3EIpZjV015008@sith.maoz.com>
Content-Type: text/plain
Message-Id: <1050346609.3664.55.camel@localhost>
Mime-Version: 1.0
Date: 14 Apr 2003 14:56:50 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Hall <jhall@maoz.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-04-14 at 14:51, Jeremy Hall wrote:

> On a UP machine, is it possible for two interrupts to occur at once? as 
> in, can card a create an interrupt while card b is in interrupt context?

Yes.  Normally, all interrupts are enabled (the interrupt system is on)
but the _current_ interrupt line is masked out.  Thus you will never get
a recursive interrupt (A while processing A) but you may get A while
processing B.

Note if SA_INTERRUPT flag was given to request_irq() then the interrupt
is a "fast" interrupt and runs with all interrupts disabled on the local
processor.

> what about an SMP machine operating in UP mode (nosmp)

By nature of above, yes.

If you need to ensure concurrency is protected in your interrupt
handler, grab a lock and disable interrupts around the critical region.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
