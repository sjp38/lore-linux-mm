Subject: Re: A scrub daemon (prezeroing)
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <Pine.LNX.4.61L.0502022000470.9448@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
	 <1106828124.19262.45.camel@hades.cambridge.redhat.com>
	 <20050202153256.GA19615@logos.cnet>
	 <Pine.LNX.4.61L.0502022000470.9448@blysk.ds.pg.gda.pl>
Content-Type: text/plain
Date: Wed, 02 Feb 2005 21:33:45 +0000
Message-Id: <1107380025.18239.30.camel@baythorne.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 2005-02-02 at 21:00 +0000, Maciej W. Rozycki wrote:
>  E.g. the Broadcom's MIPS64-based SOCs have four general purpose DMA 
> engines onchip which can transfer data to/from the memory controller in 
> 32-byte chunks over the 256-bit internal bus.  We have hardly any use for 
> these devices and certainly not for all four of them.

On machines like the Ocelot, I keep intending to abuse one of the DMA
engines for access to the DiskOnChip. Really must dig the Ocelot out of
the dusty pile of toys... :)

-- 
dwmw2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
