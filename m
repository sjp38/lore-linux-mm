Date: Thu, 17 May 2007 10:45:00 +0200 (CEST)
From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: Slab allocators: Define common size limitations
In-Reply-To: <200705162342.08601.arnd@arndb.de>
Message-ID: <Pine.LNX.4.62.0705171044030.1803@pademelon.sonytel.be>
References: <Pine.LNX.4.64.0705152313490.5832@schroedinger.engr.sgi.com>
 <Pine.LNX.4.62.0705160855470.24080@pademelon.sonytel.be> <200705162342.08601.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2007, Arnd Bergmann wrote:
> On Wednesday 16 May 2007, Geert Uytterhoeven wrote:
> > What are the changes a large allocation will actually succeed?
> > Is there an alignment rule for large allocations?
> > 
> > E.g. for one of the PS3 drivers I need a physically contiguous 256 KiB-aligned
> > block of 256 KiB. Currently I'm using __alloc_bootmem() for that, but maybe
> > kmalloc() becomes a suitable alternative now?
> 
> kmalloc is limited to 128KiB on most architectures. Normally there is no
> need to use it anyway, just use __get_free_pages(). It will generally
> succeed at early boot time, but not after the system has been running
> for some time.

Exactly my understanding. And __get_free_pages() returns PAGE_SIZE-aligned
memory. So I'll keep the current code.

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
