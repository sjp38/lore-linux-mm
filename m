From: Jeremy Hall <jhall@maoz.com>
Message-Id: <200304142109.h3EL90YY016047@sith.maoz.com>
Subject: Re: interrupt context
In-Reply-To: <1050346609.3664.55.camel@localhost> from Robert Love at "Apr 14,
 2003 02:56:50 pm"
Date: Mon, 14 Apr 2003 17:09:00 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Jeremy Hall <jhall@maoz.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In the new year, Robert Love wrote:
> On Mon, 2003-04-14 at 14:51, Jeremy Hall wrote:
> 
> Note if SA_INTERRUPT flag was given to request_irq() then the interrupt
> is a "fast" interrupt and runs with all interrupts disabled on the local
> processor.
> 
with 2.5.67-mm2, it is SA_INTERRUPT|SA_SHIRQ and looks like it can call 
multiple interrupts at once.  I am not sure what SA_SHIRQ does, but this 
does not address the case where one CPU holds an interrupt for one card 
and the other CPU holds the interrupt for the other card.

I moved the line 

rme9652_write(rme9652, RME9652_irq_clear, 0);

to after the snd_pcm_period_elapsed calls in the hopes that they would be 
run in interrupt context, but it did not make a difference.  The backtrace 
looks a little different, but it's still the same crash.

_J
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
