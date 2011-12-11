Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id D205F6B0062
	for <linux-mm@kvack.org>; Sat, 10 Dec 2011 19:00:38 -0500 (EST)
Date: Sun, 11 Dec 2011 01:00:36 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: XFS causing stack overflow
Message-ID: <20111211000036.GH24062@one.firstfloor.org>
References: <CAAnfqPAm559m-Bv8LkHARm7iBW5Kfs7NmjTFidmg-idhcOq4sQ@mail.gmail.com> <20111209115513.GA19994@infradead.org> <20111209221956.GE14273__25752.826271537$1323469420$gmane$org@dastard> <m262hop5kc.fsf@firstfloor.org> <20111210221345.GG14273@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111210221345.GG14273@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, xfs@oss.sgi.com, "Ryan C. England" <ryan.england@corvidtec.com>

> Where does the x86-64 do the interrupt stack switch?

in entry_64.S

> 
> I know the x86 32 bit interrupt handler switches to an irq/softirq
> context stack, but the 64 bit one doesn't appear to. Indeed,
> arch/x86/kernel/irq_{32,64}.c are very different, and only the 32
> bit irq handler switches to another stack to process the
> interrupts...

x86-64 always used interrupt stacks and has used softirq stacks
for a long time. 32bit got to it much later (the only good 
thing left from that 4k stack "experiment")

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
