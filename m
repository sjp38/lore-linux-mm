Date: Wed, 22 Nov 2000 16:11:04 +0200
From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: max memory limits ???
Message-ID: <20001122161104.C28963@mea-ext.zmailer.org>
References: <3A1BCC05.4080608@SANgate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3A1BCC05.4080608@SANgate.com>; from gabriel@SANgate.com on Wed, Nov 22, 2000 at 03:37:09PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: BenHanokh Gabriel <gabriel@SANgate.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 22, 2000 at 03:37:09PM +0200, BenHanokh Gabriel wrote:
> hi
> 
> can some1 explain the memory limits on the 2.4 kernel
> 
> - what is the maximum amount of physical memory it supports ?

	There are some Alpha systems with 256 GB memory where Linux is
	sometimes tested.   Those processors support up to several
	terabytes of memory (nobody built such maximum machines, though.)

	For intel machines limits are different, of course.
	(PAE36 supports up to 16*4 GB = 64 GB physical address space,
         within which there must be some holes to support e.g. PCI
	 bus address spaces, and system boot rom, to name a few.)

	For intel ia64 -- that is a 64 bit machine, thus it propably
	follows Alpha and UltraSPARC model in this regard.

> - what is the limit for user-space apps ?

	At 32 bit systems:  3.5 GB with extreme tricks, 3 GB for more usual.
	At 64 bit systems -- 2^60 or some such semi-meaningless value.

> - what is the limit for kernel ?

	Whatever the hardware supports.

> - are there any limits on malloc, static-memory, stack-memory ?

	userspace rules.

> - does using HIGHMEM results with performance penalty   ?

	Of course, it causes extra mapping operations on machines
	needing it to support larger memory (intel PAE36 featured
	hardware).  User processes can access all what is mapped
	into them at the same time -- All programs, kernel included
	are limited to 32 bit addresses, but kernel can juggle maps
	to reach areas not mapped in its address space at some moment.

> - anything else ?
> 
> please CC me for any answer
> 
> regards
> Benhanokh Gabriel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
