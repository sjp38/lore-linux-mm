Message-ID: <48EB6341.3060101@linux-foundation.org>
Date: Tue, 07 Oct 2008 08:25:21 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH next 2/3] slub defrag: dma_kmalloc_cache add_tail
References: <Pine.LNX.4.64.0810050319001.22004@blonde.site>	 <Pine.LNX.4.64.0810050325440.22004@blonde.site> <1223279207.30581.2.camel@penberg-laptop>
In-Reply-To: <1223279207.30581.2.camel@penberg-laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for finding the DMA cache issues. DMA caches are rarely used since Andi
tried to get rid of all of them for x86.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
