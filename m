Date: Fri, 4 Feb 2005 10:28:01 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: A scrub daemon (prezeroing)
Message-ID: <20050204092801.GE10347@wotan.suse.de>
References: <1106828124.19262.45.camel@hades.cambridge.redhat.com> <20050202153256.GA19615@logos.cnet> <Pine.LNX.4.58.0502021103410.12695@schroedinger.engr.sgi.com> <20050202163110.GB23132@logos.cnet> <Pine.LNX.4.61.0502022204140.2678@chimarrao.boston.redhat.com> <16898.46622.108835.631425@cargo.ozlabs.ibm.com> <Pine.LNX.4.58.0502031650590.26551@schroedinger.engr.sgi.com> <16899.2175.599702.827882@cargo.ozlabs.ibm.com> <Pine.LNX.4.58.0502032220430.28851@schroedinger.engr.sgi.com> <16899.15980.791820.132469@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16899.15980.791820.132469@cargo.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, David Woodhouse <dwmw2@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> > advantage of all the optimizations that modern memory subsystems have for
> > linear accesses. And if hardware exists that can offload that from the cpu
> > then the cpu caches are only minimally affected.
> 
> I can believe that prezeroing could provide a benefit on some
> machines, but I don't think it will provide any on ppc64.

On modern x86 clears can be done quite quickly (no memory read access) with 
write combining writes. The problem is just that this will force the 
page out of cache. If there is any chance that the CPU will be accessing
the data soon it's better to do the slower cached RMW clear.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
