Message-ID: <20000927181334.A14797@saw.sw.com.sg>
Date: Wed, 27 Sep 2000 18:13:34 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: the new VMt
References: <20000925213201.C2615@redhat.com> <Pine.LNX.4.21.0009261020020.11007-100000@alloc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0009261020020.11007-100000@alloc>; from "Mark Hemment" on Tue, Sep 26, 2000 at 01:10:30PM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hemment <markhe@veritas.com>
Cc: yodaiken@fsmlabs.com, Jamie Lokier <lk@tantalophile.demon.co.uk>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hello,

On Tue, Sep 26, 2000 at 01:10:30PM +0100, Mark Hemment wrote:
> 
> On Mon, 25 Sep 2000, Stephen C. Tweedie wrote: 
> > So you have run out of physical memory --- what do you do about it?
> 
>   Why let the system get into the state where it is neccessary to kill a
> process?
>   Per-user/task resource counters should prevent unprivileged users from
> soaking up too many resources.  That is the DoS protection.
> 
[snip]
>   It is possible to do true, system wide, resource counting of physical
> memory and swap space, and to deny a fork() or mmap() which would cause
> over committing of memoy resources if everyone cashed in their
> requirements.
[snip]

People use overcommitting not because they are fans of the idea.
Overcommitting simply is the _efficient_ way of resource sharing.
It's a waste of resources to reserve memory+swap for the case that every
running process decides to modify libc code (and, thus, should receive its
private copy of the pages).   A real waste!
I always agree to take the risk of some applications being killed in such a
case of all processes turning crazy.

The approach I believe in is:
 - ensure that accidental or intentional madness of applications of one user
   may cause only limited damage to other users; and
 - introduce a way to tell the kernel that some applications should be
   saved longer than others when troubles begin and ways to set up some
   guaranteed amounts for important processes.
Certainly, a lot of processes may consume more than their guarantee until
bad things start to happen.  Then the rules of user protection and killing
order apply.
That's how I develop the resource control in the beancounter patch
ftp://ftp.sw.com.sg/pub/Linux/people/saw/kernel/user_beancounter/UserBeancounter.html#s7

Best regards
		Andrey
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
