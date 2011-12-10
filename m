Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 5D2B66B005C
	for <linux-mm@kvack.org>; Sat, 10 Dec 2011 17:13:49 -0500 (EST)
Date: Sun, 11 Dec 2011 09:13:45 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: XFS causing stack overflow
Message-ID: <20111210221345.GG14273@dastard>
References: <CAAnfqPAm559m-Bv8LkHARm7iBW5Kfs7NmjTFidmg-idhcOq4sQ@mail.gmail.com>
 <20111209115513.GA19994@infradead.org>
 <20111209221956.GE14273__25752.826271537$1323469420$gmane$org@dastard>
 <m262hop5kc.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m262hop5kc.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, xfs@oss.sgi.com, "Ryan C. England" <ryan.england@corvidtec.com>

On Sat, Dec 10, 2011 at 11:52:51AM -0800, Andi Kleen wrote:
> Dave Chinner <david@fromorbit.com> writes:
> >
> > You forgot about interrupt stacking - that trace shows the system
> > took an interrupt at the point of highest stack usage in the
> > writeback call chain.... :/
> 
> The interrupts are always running on other stacks these days
> (even 32bit got switched over).

Where does the x86-64 do the interrupt stack switch?

I know the x86 32 bit interrupt handler switches to an irq/softirq
context stack, but the 64 bit one doesn't appear to. Indeed,
arch/x86/kernel/irq_{32,64}.c are very different, and only the 32
bit irq handler switches to another stack to process the
interrupts...

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
