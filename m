Date: Wed, 2 Jan 2008 13:44:33 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch] i386: avoid expensive ppro ordering workaround for
 default 686 kernels
Message-ID: <20080102134433.6ca82011@the-village.bc.nu>
In-Reply-To: <20080102110225.GA16154@wotan.suse.de>
References: <20071218012632.GA23110@wotan.suse.de>
	<20071222005737.2675c33b.akpm@linux-foundation.org>
	<20071223055730.GA29288@wotan.suse.de>
	<20071222223234.7f0fbd8a.akpm@linux-foundation.org>
	<20071223071529.GC29288@wotan.suse.de>
	<alpine.LFD.0.9999.0712230900310.21557@woody.linux-foundation.org>
	<20080101234133.4a744329@the-village.bc.nu>
	<20080102110225.GA16154@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

> Take a different approach: after this patch, we just disable all but one CPU on those
> systems, and print a warning. Also printed is a suggestion for a new CONFIG option that
> can be enabled for the previous behaviour.

How does that help. The processor isn't the only bus master.

Maybe this works as a SuSE specific convenience solution aligned to
your particular build pattern but it isn't the right solution for
upstream IMHO. 

We should either

- re-order the assumed processor generations supported to put VIA C3/C5
above Preventium Pro
- fix the gcc or gcc settings not to generate invalid cmov instructions
on 686. cmov is slower on all the modern processors anyway.

And you change the assumption that 586 < 686 < PPro < PII < PIII ...

to 586 < 686 < PPro < C3 < PII < ...

then selecting VIA C3 support will get you a kernel with the properties
all the distribution vendors want for their higher end mainstream kernel -
"runs on modern systems".

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
