Date: Thu, 17 May 2001 21:23:10 +0200
From: Christoph Hellwig <hch@caldera.de>
Subject: Re: Running out of vmalloc space
Message-ID: <20010517212310.A5122@caldera.de>
References: <3B04069C.49787EC2@fc.hp.com> <20010517221610.K5947@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010517221610.K5947@mea-ext.zmailer.org>; from matti.aarnio@zmailer.org on Thu, May 17, 2001 at 10:16:10PM +0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matti Aarnio <matti.aarnio@zmailer.org>
Cc: David Pinedo <dp@fc.hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 17, 2001 at 10:16:10PM +0300, Matti Aarnio wrote:
> On Thu, May 17, 2001 at 11:13:00AM -0600, David Pinedo wrote:
> [ Why vmalloc() space is so small ? ]
> 
>   Hua Ji summarized quite well what the kernel does, and where.
> 
>   There are 32bit machines which *can* access whole 4G kernel space
>   separate from simultaneous 4G user space, however i386 is not one
>   of those.

Kanoj Sarcar has written a patch for Linux 2.2 to allow exactly this.
Take a look at http://oss.sgi.com/projects/bigmem/, the page also
contains a nice explanation of what the changes actually do.

	Christoph

-- 
Whip me.  Beat me.  Make me maintain AIX.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
