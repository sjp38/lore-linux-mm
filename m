Subject: Re: A scrub daemon (prezeroing)
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20050202163110.GB23132@logos.cnet>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
	 <1106828124.19262.45.camel@hades.cambridge.redhat.com>
	 <20050202153256.GA19615@logos.cnet>
	 <Pine.LNX.4.58.0502021103410.12695@schroedinger.engr.sgi.com>
	 <20050202163110.GB23132@logos.cnet>
Content-Type: text/plain
Date: Wed, 02 Feb 2005 21:39:54 +0000
Message-Id: <1107380394.18239.34.camel@baythorne.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 2005-02-02 at 14:31 -0200, Marcelo Tosatti wrote:
> Someone should try implementing the zeroing driver for a fast x86 PCI
> device. :)

The BT848/BT878 seems like an ideal candidate. That kind of abuse is
probably only really worth it on an architecture with cache-coherent DMA
though. If you have to flush the cache anyway, you might as well just
zero it from the CPU.

-- 
dwmw2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
