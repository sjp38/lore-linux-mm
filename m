Date: 15 Feb 2005 13:14:04 +0100
Date: Tue, 15 Feb 2005 13:14:04 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview II
Message-ID: <20050215121404.GB25815@muc.de>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com> <m1vf8yf2nu.fsf@muc.de> <42114279.5070202@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42114279.5070202@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

[Sorry, didn't answer to everything in your mail the first time. 
See previous mail for beginning]

On Mon, Feb 14, 2005 at 06:29:45PM -0600, Ray Bryant wrote:
> migrating, and figure out from that what portions of which pid's
> address spaces need to migrated so that we satisfy the constraints
> given above.  I admit that this may be viewed as ugly, but I really
> can't figure out a better solution than this without shuffling a
> ton of ugly code into the kernel.

I like the concept of marking stuff that shouldn't be migrated
externally (using NUMA policy) better. 

> 
> One issue that hasn't been addressed is the following:  given a
> particular entry in /proc/pid/maps, how does one figure out whether
> that entry is mapped into some other process in the system, one
> that is not in the set of processes to be migrated?   One could

[...]

Marking things externally would take care of that.

> If we did this, we still have to have the page migration system call
> to handle those cases for the tmpfs/hugetlbfs/sysv shm segments whose
> pages were placed by first touch and for which there used to not be
> a memory policy.  As discussed in a previous note, we are not in a

You can handle those with mbind(..., MPOL_F_STRICT); 
(once it is hooked up to page migration) 

Just mmap the tmpfs/shm/hugetlb file in an external program and apply
the policy. That is what numactl supports today too for shm
files like this.

It should work later.


-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
