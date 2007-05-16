Date: Wed, 16 May 2007 08:58:39 +0200 (CEST)
From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: Slab allocators: Define common size limitations
In-Reply-To: <Pine.LNX.4.64.0705152313490.5832@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.62.0705160855470.24080@pademelon.sonytel.be>
References: <Pine.LNX.4.64.0705152313490.5832@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux/PPC Development <linuxppc-dev@ozlabs.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007, Christoph Lameter wrote:
> So define a common maximum size for kmalloc. For conveniences sake
> we use the maximum size ever supported which is 32 MB. We limit the maximum
> size to a lower limit if MAX_ORDER does not allow such large allocations.

What are the changes a large allocation will actually succeed?
Is there an alignment rule for large allocations?

E.g. for one of the PS3 drivers I need a physically contiguous 256 KiB-aligned
block of 256 KiB. Currently I'm using __alloc_bootmem() for that, but maybe
kmalloc() becomes a suitable alternative now?

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- Sony Network and Software Technology Center Europe (NSCE)
Geert.Uytterhoeven@sonycom.com ------- The Corporate Village, Da Vincilaan 7-D1
Voice +32-2-7008453 Fax +32-2-7008622 ---------------- B-1935 Zaventem, Belgium

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
