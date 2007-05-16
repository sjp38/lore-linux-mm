From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Slab allocators: Define common size limitations
Date: Wed, 16 May 2007 23:42:07 +0200
References: <Pine.LNX.4.64.0705152313490.5832@schroedinger.engr.sgi.com> <Pine.LNX.4.62.0705160855470.24080@pademelon.sonytel.be>
In-Reply-To: <Pine.LNX.4.62.0705160855470.24080@pademelon.sonytel.be>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705162342.08601.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev@ozlabs.org
Cc: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 16 May 2007, Geert Uytterhoeven wrote:
> What are the changes a large allocation will actually succeed?
> Is there an alignment rule for large allocations?
> 
> E.g. for one of the PS3 drivers I need a physically contiguous 256 KiB-aligned
> block of 256 KiB. Currently I'm using __alloc_bootmem() for that, but maybe
> kmalloc() becomes a suitable alternative now?

kmalloc is limited to 128KiB on most architectures. Normally there is no
need to use it anyway, just use __get_free_pages(). It will generally
succeed at early boot time, but not after the system has been running
for some time.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
