Date: Fri, 4 Jan 2008 16:27:00 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch] i386: avoid expensive ppro ordering workaround for
 default 686 kernels
Message-ID: <20080104162700.3aef1806@lxorguk.ukuu.org.uk>
In-Reply-To: <20080103231017.GA25880@wotan.suse.de>
References: <20071222005737.2675c33b.akpm@linux-foundation.org>
	<20071223055730.GA29288@wotan.suse.de>
	<20071222223234.7f0fbd8a.akpm@linux-foundation.org>
	<20071223071529.GC29288@wotan.suse.de>
	<alpine.LFD.0.9999.0712230900310.21557@woody.linux-foundation.org>
	<20080101234133.4a744329@the-village.bc.nu>
	<20080102110225.GA16154@wotan.suse.de>
	<20080102134433.6ca82011@the-village.bc.nu>
	<20080103041708.GB26487@wotan.suse.de>
	<20080103142330.111d4067@lxorguk.ukuu.org.uk>
	<20080103231017.GA25880@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

> > The cost on a 586 SMP box (ie pentium) is basically nil. All cross CPU
> > transactions are hideously slow anyway locked or not.
> 
> That's wrong. Firstly, spinlocks are very often retaken by the same CPU, and they

Go time it. It certainly used to be the case.

> On 586 SMP systems, didn't lock ops actually go out on the bus, and hence are much
> more expensive than they are today (although today they are still one or two orders
> of magnitude more expensive than regular memory ops).

All cross CPU cache stuff goes that way, not that may P5 SMP boxes are
running today except in Mr Bottomley's residence.

> And if you build a kernel which is to support 686, PII, and later, you don't want
> them by default either, most probably.

I want a kernel for VIA C3 or later which happens to include K6 (still
common), PII+ and maybe not PPro.

So your patch should go in the bitbucket by the sound of it and Adrian's
get merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
