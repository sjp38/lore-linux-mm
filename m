Date: Sun, 20 Jul 2003 10:27:43 +0800
From: Eugene Teo <eugene.teo@eugeneteo.net>
Subject: Re: Linux free issue
Message-ID: <20030720022743.GD16983@eugeneteo.net>
Reply-To: Eugene Teo <eugene.teo@eugeneteo.net>
References: <MEHFFGFJPAFEOBAA@mailcity.com> <Pine.LNX.4.44.0307191037530.26759-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0307191037530.26759-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Vinay I K <abcxyz1@lycos.com>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

<quote sender="Rik van Riel">
> On Sat, 19 Jul 2003, Vinay I K wrote:
> 
> > http://mail.nl.linux.org/linux-mm/1998-08/msg00028.html
> > 
> > I am a bit confused. When we call free in Linux, is the memory not given
> > back to the system(just cached)? What is the state of the issue in the
> > latest Linux Kernel?
> 
> The issue is not in the Linux kernel at all, but in glibc.
> It is the C library that has (after careful measuring and
> optimising) made the decision to not call the system call
> to free memory but instead keep it for later use.

I agree with Riel. It has nothing to do with the kernel,
but the implementation of the dynamic memory allocator
in the userspace C library.

The actual implementation might differ a little but the
general idea is that whenever you do a free, it deallocates
the region of memory by storing this "freed" space to a free
list. You will notice that the heap offset is not decreased
by using the sbrk syscall. The next time you call malloc,
it will search through the free list, and if a space matches,
that spaces will be used to your program. Otherwise, it will
increase the heap, allocate a region of memory you specified 
for your program instead.

Eugene

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
