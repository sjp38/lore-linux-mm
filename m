Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 858246B0075
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 18:05:15 -0500 (EST)
Date: Mon, 12 Dec 2011 10:05:11 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: XFS causing stack overflow
Message-ID: <20111211230511.GH14273@dastard>
References: <CAAnfqPAm559m-Bv8LkHARm7iBW5Kfs7NmjTFidmg-idhcOq4sQ@mail.gmail.com>
 <20111209115513.GA19994@infradead.org>
 <20111209221956.GE14273__25752.826271537$1323469420$gmane$org@dastard>
 <m262hop5kc.fsf@firstfloor.org>
 <20111210221345.GG14273@dastard>
 <20111211000036.GH24062@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111211000036.GH24062@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, xfs@oss.sgi.com, "Ryan C. England" <ryan.england@corvidtec.com>

On Sun, Dec 11, 2011 at 01:00:36AM +0100, Andi Kleen wrote:
> > Where does the x86-64 do the interrupt stack switch?
> 
> in entry_64.S
> 
> > 
> > I know the x86 32 bit interrupt handler switches to an irq/softirq
> > context stack, but the 64 bit one doesn't appear to. Indeed,
> > arch/x86/kernel/irq_{32,64}.c are very different, and only the 32
> > bit irq handler switches to another stack to process the
> > interrupts...
> 
> x86-64 always used interrupt stacks and has used softirq stacks
> for a long time. 32bit got to it much later (the only good 
> thing left from that 4k stack "experiment")

Oh, it's hidden in the "SAVE_ARGS_IRQ" macro. 

But that happens before do_IRQ is called, so what is the do_IRQ call
chain doing on this stack given that we've already supposed to have
switched to the interrupt stack before do_IRQ is called?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
