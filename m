Date: Tue, 25 May 2004 07:09:37 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
Message-ID: <20040525050937.GZ29378@dualathlon.random>
References: <1085371988.15281.38.camel@gaston> <Pine.LNX.4.58.0405232134480.25502@ppc970.osdl.org> <1085373839.14969.42.camel@gaston> <Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org> <20040525034326.GT29378@dualathlon.random> <Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org> <20040525042054.GU29378@dualathlon.random> <Pine.LNX.4.58.0405242137210.32189@ppc970.osdl.org> <Pine.LNX.4.58.0405242141150.32189@ppc970.osdl.org> <20040525045958.GY29378@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040525045958.GY29378@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Ben LaHaise <bcrl@kvack.org>, linux-mm@kvack.org, Architectures Group <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> all. However I wonder what happens for PROT_WRITE? How can you make a

I understood now how it works with PROT_WRITE too, it's not FOR but URE
being tweaked together with ACCESSED. This has been a very big misread I
did when I was doing alpha stuff some year ago. that's why I was so
confident it was only setting it during the first page fault and never
clearing it again. Sounds good that it can be emulated fully, I thought
it wasn't even feasible at all.

thanks a lot for pointing out this huge mistake.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
