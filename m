From: David Howells <dhowells@redhat.com>
In-Reply-To: <20060708111243.28664.74956.sendpatchset@skynet.skynet.ie> 
References: <20060708111243.28664.74956.sendpatchset@skynet.skynet.ie>  <20060708111042.28664.14732.sendpatchset@skynet.skynet.ie> 
Subject: Re: [PATCH 6/6] Account for memmap and optionally the kernel image as holes 
Date: Mon, 10 Jul 2006 12:30:55 +0100
Message-ID: <7220.1152531055@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, davej@codemonkey.org.uk, tony.luck@intel.com, linux-mm@kvack.org, ak@suse.de, bob.picco@hp.com, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

Mel Gorman <mel@csn.ul.ie> wrote:

> +unsigned long __initdata dma_reserve;

Should this be static?  Or should it be predeclared in a header file
somewhere?

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
