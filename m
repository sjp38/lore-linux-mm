Date: Thu, 16 Nov 2000 15:37:28 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Question about pte_alloc()
Message-ID: <20001116153728.E703@nightmaster.csn.tu-chemnitz.de>
References: <3A12363A.3B5395AF@cse.iitkgp.ernet.in> <20001115105639.C3186@redhat.com> <3A132470.4F93CFF5@cse.iitkgp.ernet.in> <20001115154729.H3186@redhat.com> <3A144453.D0724CC1@cse.iitkgp.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3A144453.D0724CC1@cse.iitkgp.ernet.in>; from sganguly@cse.iitkgp.ernet.in on Thu, Nov 16, 2000 at 03:32:19PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 16, 2000 at 03:32:19PM -0500, Shuvabrata Ganguly wrote:
> i know that. but i dont want to wire the pages. i want the driver to allocate
> pages, fill them up with data and then transfer them to the user, which would
> enable the kernel to swap them  but then i cant touch page tables at interrupt
> time.

Why don't you use an allocator/deliver thread, a ringbuffer and
throw away the overflowing packets, while signalling the sender,
that you are satiated for the moment? The overflowing packets
will be resent later anyway.

If you receive sth., you just put it into the deliver queue and
wake the thread to deliver (==map) it.

BTW: Zero copy might become pointless if you use threads or play
   VM-Tricks.

BTW2: Are you aware of U-Net and VIA?

Regards

Ingo Oeser
-- 
To the systems programmer, users and applications
serve only to provide a test load.
<esc>:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
