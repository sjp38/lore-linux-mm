Date: Fri, 17 Jan 2003 01:26:53 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Kernel BUG(oops) does not occur after upgrading glibc
Message-ID: <20030117092653.GS919@holomorphy.com>
References: <OF5B129FA7.EE286E9B-ON65256CB1.003172CC@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF5B129FA7.EE286E9B-ON65256CB1.003172CC@in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Srikrishnan Sundararajan <srikrishnan@in.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 17, 2003 at 02:33:46PM +0530, Srikrishnan Sundararajan wrote:
> I got the following oops message using my S/390 VM-type linux image with
> 2GB of memory. (Kernel BUG at page_alloc.c:91!)
> Using 2.4.19. I was running a test program which keeps on allocating memory
> using malloc and assigns values  (with proper checking of return value of
> malloc. ) While using brk( ) system call, I did not get any problems.
> When I upgraded my glibc from version 2.2.5 to 2.3.1, the oops or Kernel
> BUG no longer occurred. As it was a "Kernel BUG" in the first place, do we
> still consider this as a BUG in the kernel or purely an error in glibc
> which was fixed in the 2.3.1 version?
> My inference is that using malloc which is part of the older glibc (2.2.5)
> was corrupting a kernel data structure, which resulted in the oops during
> swap_out.
> Note: I was not able to reproduce this problem on intel. I do not have any
> nVidia driver.

A BUG() is a BUG(); I suggest downgrading glibc, reproducing the
problem, and submitting a bugreport.


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
