Date: Thu, 17 May 2001 22:16:10 +0300
From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: Running out of vmalloc space
Message-ID: <20010517221610.K5947@mea-ext.zmailer.org>
References: <3B04069C.49787EC2@fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B04069C.49787EC2@fc.hp.com>; from dp@fc.hp.com on Thu, May 17, 2001 at 11:13:00AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Pinedo <dp@fc.hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 17, 2001 at 11:13:00AM -0600, David Pinedo wrote:
[ Why vmalloc() space is so small ? ]

  Hua Ji summarized quite well what the kernel does, and where.

  There are 32bit machines which *can* access whole 4G kernel space
  separate from simultaneous 4G user space, however i386 is not one
  of those.

  PAE36 doesn't help either -- aside of the PHYSICAL memory addressability
  increase, the problem is in 4G choke point in address calculations which
  causes  32-bit segment register value be added on  32-bits address, but
  only for the low 32 bits, loosing "up-shifted" top 4 bits.  The mapping
  tables will then expand that 32-bit result to 36 bits of PAE.

  If you can come up with some magic instruction which does data move
  from/to alternate memory mapping context than what is currently running
  (e.g. userspace or kernel), preferrably privileged instruction, a LOT
  of people would be very glad -- and very nearly overnight we could 
  supply 4G space for both user and kernel spaces.

  In Motorola 68k series there is such a thing, called 'movec'.

> Thanks for any information anyone can provide.
>  
> David Pinedo
> Hewlett-Packard Company
> Fort Collins, Colorado
> dp@fc.hp.com

/Matti Aarnio  -- who much prefers clean 64-bit pointers...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
