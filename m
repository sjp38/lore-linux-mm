Date: Fri, 18 May 2001 18:44:59 +0200
From: Christoph Hellwig <hch@ns.caldera.de>
Subject: Re: Running out of vmalloc space
Message-ID: <20010518184459.A14299@caldera.de>
References: <3B04069C.49787EC2@fc.hp.com> <20010517183931.V2617@redhat.com> <3B045546.312BA42E@fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B045546.312BA42E@fc.hp.com>; from dp@fc.hp.com on Thu, May 17, 2001 at 04:48:38PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Pinedo <dp@fc.hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 17, 2001 at 04:48:38PM -0600, David Pinedo wrote:
> Unfortunately, yes. It has to be in the kernel's virtual address space,
> because the kernel graphics driver initiates DMAs to and from the
> graphics board, which can only be done from the kernel using locked down
> physical memory.

Take a look at drivers/char/raw.c on how to lock down userpages.

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
