Date: Sat, 24 Mar 2001 15:23:35 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Reduce Linux memory requirements for an Embedded PC
Message-ID: <20010324152335.B11686@redhat.com>
References: <3ABC7008.B9EB4047@razdva.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ABC7008.B9EB4047@razdva.cz>; from pdusil@razdva.cz on Sat, Mar 24, 2001 at 10:59:36AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Petr Dusil <pdusil@razdva.cz>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Mar 24, 2001 at 10:59:36AM +0100, Petr Dusil wrote:
> 
> memory as soon as possible, but again without starting any daemon only
> with bash running I got 7MB. I am asking you, is there any option to
> tell Linux kernel "save the memory" or what are the general
> recommendations to minimize amount of memory the kernel consumes?

First of all, bash and glibc are both fairly large chunks of code.
There are much smaller shells available, and there is at least one
miniature libc intended for embedded use.

Secondly, how are you booting the fs?  ramdisks (including initrd) are
fairly wasteful of memory if used as a root filesystem; ramfs for
writable data and cramfs for a static boot fs are much better choices.

Cheers, 
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
