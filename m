Date: Wed, 7 May 2003 17:54:27 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: VM limits on AMD64
Message-ID: <20030507155427.GM11820@dualathlon.random>
References: <Pine.GHP.4.02.10302121019090.19866-100000@alderaan.science-computing.de> <Pine.LNX.4.53.0305071628130.3486@picard.science-computing.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.53.0305071628130.3486@picard.science-computing.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oliver Tennert <tennert@science-computing.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2003 at 04:32:40PM +0200, Oliver Tennert wrote:
> 
> Hello,
> 
> I have a few very simple questions:
> 
> 1.) The current VM userspace limit for 2.4.x kernels on AMD64 systems in
> 64bit long mode is 512 G. What is the limit in the current 2.5.x kernels?

512G, can be changed fairly easily, but there was no need of that yet.
it's something for 2.7.

> 2.) If it is still 512G, will that change until 2.6 comes out?

not plan to change it at the moment.

> 3.) What is the exact usage of the rest (i.e. 16 Exabyte minus 512 Gig)? I
> know of something like a split kernel mapping/direct mapping. What is
> exactly is meant by that?

there is no global ram limit, only the user address space is limited,
everything else will be used fully as cache, inodes, kernel internal
metadata and whatever (there's no special highmem). so there is no
limitation at all for the rest.  Only the address space is currently
limited to 512G due the 3 level pagetables in the kernel common code.

> 4.) Is the kernel VM permanently mapped as in IA32?

yes, but that's not the reason of the limitation of 512G, the fact user
and kernel shares the same address space is perfectly fine and it
doesn't impose any restriction in a 64bit arch (unlike the 32bit archs ;).

Andrea

[ I assume you really wanted to CC to linux-mm by adding
  linux-mm-www@nl.linux.org to the CC list of your email ]
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
