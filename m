Received: from hpfcla.fc.hp.com (hpfcla.fc.hp.com [15.254.48.2])
	by atlrel1.hp.com (Postfix) with ESMTP id 16986CDF
	for <linux-mm@kvack.org>; Thu, 17 May 2001 18:49:44 -0400 (EDT)
Received: from gplmail.fc.hp.com (nsmail@wslmail.fc.hp.com [15.1.92.20])
	by hpfcla.fc.hp.com (8.9.3 (PHNE_22672)/8.9.3 SMKit7.01) with ESMTP id QAA08439
	for <linux-mm@kvack.org>; Thu, 17 May 2001 16:49:43 -0600 (MDT)
Received: from fc.hp.com (dome.fc.hp.com [15.1.89.118])
          by gplmail.fc.hp.com (Netscape Messaging Server 3.6)  with ESMTP
          id AAA4E9D for <linux-mm@kvack.org>;
          Thu, 17 May 2001 16:49:38 -0600
Message-ID: <3B045546.312BA42E@fc.hp.com>
Date: Thu, 17 May 2001 16:48:38 -0600
From: David Pinedo <dp@fc.hp.com>
MIME-Version: 1.0
Subject: Re: Running out of vmalloc space
References: <3B04069C.49787EC2@fc.hp.com> <20010517183931.V2617@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Thu, May 17, 2001 at 11:13:00AM -0600, David Pinedo wrote:
> 
> > On Linux, HP supports up to two FX10 boards in the system.  In order to
> > use two FX10 boards, the kernel driver needs to map the frame buffer and
> > control space for both of the boards.  That's a lot of address space,
> > 2*(16M+32M)=96M to be exact.  Using this much virtual address space on a
> > stock RH7.1 smp kernel on a system with 0.5G of memory didn't seem to
> > be a problem.  However, a colleague reported a problem to me on his
> > system with 1.0G of memory -- the X server was exiting with an error
> > message indicating that it couldn't map both devices.
> 
> You obviously want to be able to map this memory into the X server's
> virtual address space, but do you really need to map it into the
> kernel's VA too?
> 
> Cheers,
>  Stephen


Unfortunately, yes. It has to be in the kernel's virtual address space,
because the kernel graphics driver initiates DMAs to and from the
graphics board, which can only be done from the kernel using locked down
physical memory.

Thanks for all the replies to the questions I raised.

David Pinedo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
