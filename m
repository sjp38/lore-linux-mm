Date: Fri, 18 May 2001 13:24:58 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: Running out of vmalloc space
Message-ID: <20010518132458.A2569@fred.local>
References: <3B04069C.49787EC2@fc.hp.com> <20010517183931.V2617@redhat.com> <3B045546.312BA42E@fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3B045546.312BA42E@fc.hp.com>; from dp@fc.hp.com on Fri, May 18, 2001 at 12:48:38AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Pinedo <dp@fc.hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2001 at 12:48:38AM +0200, David Pinedo wrote:
> Unfortunately, yes. It has to be in the kernel's virtual address space,
> because the kernel graphics driver initiates DMAs to and from the
> graphics board, which can only be done from the kernel using locked down
> physical memory.

If it doesn't do any direct CPU accesses to the graphics board you could
do the DMA even without having the board mapped in the MMU. You just have
to work with physical addresses.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
