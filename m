Date: Thu, 17 May 2001 23:10:16 +0300
From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: Running out of vmalloc space
Message-ID: <20010517231016.L5947@mea-ext.zmailer.org>
References: <3B04069C.49787EC2@fc.hp.com> <20010517221610.K5947@mea-ext.zmailer.org> <20010517212310.A5122@caldera.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010517212310.A5122@caldera.de>; from hch@caldera.de on Thu, May 17, 2001 at 09:23:10PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@caldera.de>
Cc: David Pinedo <dp@fc.hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 17, 2001 at 09:23:10PM +0200, Christoph Hellwig wrote:
> > On Thu, May 17, 2001 at 11:13:00AM -0600, David Pinedo wrote:
> > [ Why vmalloc() space is so small ? ]
> > 
> >   Hua Ji summarized quite well what the kernel does, and where.
> > 
> >   There are 32bit machines which *can* access whole 4G kernel space
> >   separate from simultaneous 4G user space, however i386 is not one
> >   of those.
> 
> Kanoj Sarcar has written a patch for Linux 2.2 to allow exactly this.
> Take a look at http://oss.sgi.com/projects/bigmem/, the page also
> contains a nice explanation of what the changes actually do.

   It doesn't supply separate SIMULTANEOUS address spaces.
   It does pageing table juggling by having some 0.2 GB always
   mapped, and then switching things back and forth at tables.

   Kanoj's approach gives larger address spaces for both spaces
   (user, and kernel), but it can't circumvent i386 hardware
   limitations.

   And like Kanoj notes, there are performance penalities.
   If a way can be found which shows none of those penalties,
   Linus would accept the code, I believe.

> 	Christoph

/Matti Aarnio
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
