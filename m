Message-ID: <48AD69EA.9090202@linux-foundation.org>
Date: Thu, 21 Aug 2008 08:13:14 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch] mm: rewrite vmap layer
References: <20080818133224.GA5258@wotan.suse.de>	<48AADBDC.2000608@linux-foundation.org>	<20080820090234.GA7018@wotan.suse.de>	<48AC244F.1030104@linux-foundation.org> <87y72q3kem.fsf@skyscraper.fehenstaub.lan>
In-Reply-To: <87y72q3kem.fsf@skyscraper.fehenstaub.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:

> I have not much clue about the users but shouldn't you use vmalloc
> anyway if you don't need physically contiguous pages?

physical memory has the advantage that it does not need a page table and its
therefore more efficient to access. Plus the overhead of having to maintain a
mapping is gone. Memory is suitable for I/O without scatter gather etc etc.

> So while it would be usable then to have both vmap and vunmap work in
> atomic context, I don't really get the fallback use case..?

Classic example: A network driver wants contiguous memory for a jumbo frame.

Fallback to scatter gather is possible but not as effective.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
