MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16898.46622.108835.631425@cargo.ozlabs.ibm.com>
Date: Fri, 4 Feb 2005 10:39:10 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: A scrub daemon (prezeroing)
In-Reply-To: <Pine.LNX.4.61.0502022204140.2678@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
	<1106828124.19262.45.camel@hades.cambridge.redhat.com>
	<20050202153256.GA19615@logos.cnet>
	<Pine.LNX.4.58.0502021103410.12695@schroedinger.engr.sgi.com>
	<20050202163110.GB23132@logos.cnet>
	<Pine.LNX.4.61.0502022204140.2678@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Christoph Lameter <clameter@sgi.com>, David Woodhouse <dwmw2@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Rik van Riel writes:

> I'm not convinced.  Zeroing a page takes 2000-4000 CPU
> cycles, while faulting the page from RAM into cache takes
> 200-400 CPU cycles per cache line, or 6000-12000 CPU
> cycles.

On my G5 it takes ~200 cycles to zero a whole page.  In other words it
takes about the same time to zero a page as to bring in a single cache
line from memory.  (PPC has an instruction to establish a whole cache
line of zeroes in modified state without reading anything from
memory.)

Thus I can't see how prezeroing can ever be a win on ppc64.

Regards,
Paul.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
