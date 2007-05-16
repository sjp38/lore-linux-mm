Date: Wed, 16 May 2007 00:02:36 -0700 (PDT)
Message-Id: <20070516.000236.71091606.davem@davemloft.net>
Subject: Re: Slab allocators: Define common size limitations
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.62.0705160855470.24080@pademelon.sonytel.be>
References: <Pine.LNX.4.64.0705152313490.5832@schroedinger.engr.sgi.com>
	<Pine.LNX.4.62.0705160855470.24080@pademelon.sonytel.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Date: Wed, 16 May 2007 08:58:39 +0200 (CEST)
Return-Path: <owner-linux-mm@kvack.org>
To: Geert.Uytterhoeven@sonycom.com
Cc: clameter@sgi.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

> E.g. for one of the PS3 drivers I need a physically contiguous 256
> KiB-aligned block of 256 KiB. Currently I'm using __alloc_bootmem()
> for that, but maybe kmalloc() becomes a suitable alternative now?

I'm allocating up to 1MB for per-process TLB hash tables
on sparc64.  But I can gracefully handle failures and it's
just a performance tweak to use such large sized tables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
