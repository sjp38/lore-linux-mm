Date: Mon, 1 Dec 2008 08:32:50 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
In-Reply-To: <1228138641.14439.18.camel@penberg-laptop>
Message-ID: <Pine.LNX.4.64.0812010828150.14977@quilx.com>
References: <20081201083128.GB2529@wotan.suse.de>
 <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com>
 <20081201120002.GB10790@wotan.suse.de>  <4933E2C3.4020400@gmail.com>
 <1228138641.14439.18.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Alexey Starikovskiy <aystarik@gmail.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008, Pekka Enberg wrote:

> Why do you think Nick's patch is going to _increase_ memory consumption?
> SLUB _already_ merges the ACPI caches with kmalloc caches so you won't
> see any difference there. For SLAB, it's a gain because there's not
> enough activity going on which results in lots of unused space in the
> slabs (which is, btw, the reason SLUB does slab merging in the first
> place).

The patch is going to increase memory consumption because the use of
the kmalloc array means that the allocated object sizes are rounded up to
the next power of two.

I would recommend to keep the caches. Subsystem specific caches help to
simplify debugging and track the memory allocated for various purposes in
addition to saving the rounding up to power of two overhead.
And with SLUB the creation of such caches usually does not require
additional memory.

Maybe it would be best to avoid kmalloc as much as possible.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
