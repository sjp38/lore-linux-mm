Received: from hpfcla.fc.hp.com (hpfcla.fc.hp.com [15.254.48.2])
	by atlrel2.hp.com (Postfix) with ESMTP id E489C2CD
	for <linux-mm@kvack.org>; Wed, 23 May 2001 12:15:37 -0400 (EDT)
Received: from gplmail.fc.hp.com (nsmail@wslmail.fc.hp.com [15.1.92.20])
	by hpfcla.fc.hp.com (8.9.3 (PHNE_22672)/8.9.3 SMKit7.01) with ESMTP id KAA23626
	for <linux-mm@kvack.org>; Wed, 23 May 2001 10:15:37 -0600 (MDT)
Message-ID: <3B0BE1D4.59BBB28@fc.hp.com>
Date: Wed, 23 May 2001 10:14:12 -0600
From: David Pinedo <dp@fc.hp.com>
MIME-Version: 1.0
Subject: Re: Running out of vmalloc space
References: <3B04069C.49787EC2@fc.hp.com> <20010517183931.V2617@redhat.com> <3B045546.312BA42E@fc.hp.com> <3B0AF30D.8D25806A@fc.hp.com> <20010523103518.X8080@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Tue, May 22, 2001 at 05:15:26PM -0600, David Pinedo wrote:
> > I followed up on the suggestion of several folks to not map the graphics
> > board into kernel vm space. While investigating how to do that, I
> > discovered that the frame buffer space did not need to be mapped -- it
> > was already being mapped with the control space. So instead of needing
> > (32M+16M)*2=96M of vmalloc space, I only need 32M*2=64M. That change
> > seemed easier than figuring out how not to map the board into kernel vm
> > space, so...
> 
> ...so you'll end up with a driver which will work fine as long as
> nobody tries to load it in parallel with another driver which tries to
> pull the same stunt.  It's an easy way out which doesn't work if
> everybody takes the same easy way out.
> 
> I *really* think you need to be avoiding the mapping in the first
> place if at all possible.
> 
> Cheers,
>  Stephen


The graphics kernel driver needs to access the device, so it needs to be
mapped into kernel vm space. I might be able to get away with not
mapping all of the device. For example, the driver only accesses a
subset of the registers on the graphics board, and doesn't access the
framebuffer. I have a customer waiting for other bug fixes, so such a
change would have to take a lower priority.

I could easily imagine a scenario on a future graphics device where the
kernel driver accesses a large percentage of the address space of the
device, so the demand on kernel vm memory space would be high. As
framebuffers get larger in the future, the need for kernel vm space will
also increase.

David P
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
