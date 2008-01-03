Date: Thu, 3 Jan 2008 22:23:58 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch] i386: avoid expensive ppro ordering workaround for
 default 686 kernels
Message-ID: <20080103222358.3632785d@lxorguk.ukuu.org.uk>
In-Reply-To: <1199391643.7291.15.camel@pasglop>
References: <20071218012632.GA23110@wotan.suse.de>
	<20071222005737.2675c33b.akpm@linux-foundation.org>
	<20071223055730.GA29288@wotan.suse.de>
	<20071222223234.7f0fbd8a.akpm@linux-foundation.org>
	<20071223071529.GC29288@wotan.suse.de>
	<alpine.LFD.0.9999.0712230900310.21557@woody.linux-foundation.org>
	<20080101234133.4a744329@the-village.bc.nu>
	<20080102110225.GA16154@wotan.suse.de>
	<20080102134433.6ca82011@the-village.bc.nu>
	<20080103041708.GB26487@wotan.suse.de>
	<20080103142330.111d4067@lxorguk.ukuu.org.uk>
	<1199391643.7291.15.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 04 Jan 2008 07:20:43 +1100
> > Whether that actually matters in any code we have I don't know.
> 
> It matters with writes to MMIO at least, I don't know if your PPro bug
> can cause that to be re-ordered tho.

In certain cases yes - the 3Dfx Voodoo cards were particularly good at
triggering it as they map the command registers cleverly to get bursts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
