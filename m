Date: Thu, 17 May 2001 18:39:31 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Running out of vmalloc space
Message-ID: <20010517183931.V2617@redhat.com>
References: <3B04069C.49787EC2@fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B04069C.49787EC2@fc.hp.com>; from dp@fc.hp.com on Thu, May 17, 2001 at 11:13:00AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Pinedo <dp@fc.hp.com>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 17, 2001 at 11:13:00AM -0600, David Pinedo wrote:

> On Linux, HP supports up to two FX10 boards in the system.  In order to
> use two FX10 boards, the kernel driver needs to map the frame buffer and
> control space for both of the boards.  That's a lot of address space,
> 2*(16M+32M)=96M to be exact.  Using this much virtual address space on a
> stock RH7.1 smp kernel on a system with 0.5G of memory didn't seem to
> be a problem.  However, a colleague reported a problem to me on his
> system with 1.0G of memory -- the X server was exiting with an error
> message indicating that it couldn't map both devices.

You obviously want to be able to map this memory into the X server's
virtual address space, but do you really need to map it into the
kernel's VA too?  

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
