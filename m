From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14480.38919.179054.61948@dukat.scot.redhat.com>
Date: Thu, 27 Jan 2000 19:09:59 +0000 (GMT)
Subject: Re: 2.2.1{3,4,5pre*} VM bug found
In-Reply-To: <Pine.LNX.4.10.10001260146290.1373-100000@mirkwood.dummy.home>
References: <Pine.LNX.4.10.10001251906370.14600-100000@d251.suse.de>
	<Pine.LNX.4.10.10001260146290.1373-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 26 Jan 2000 01:48:43 +0100 (CET), Rik van Riel
<riel@nl.linux.org> said:

> The problem in this case is that schedule() may be called
> from within get_page(GFP_KERNEL). This already was possible
> in 2.2.14 and before (if the task had to wait for I/O on
> try_to_free_pages()), but the explicit schedule() in my
> stuff in 2.2.15pre4 amplified the problem and made it
> visible.

It's not only possible, it is explicitly legal.  It always has been.
You _must_ call it with GFP_ATOMIC if you can't afford to block (or,
alternatively, call it without __GFP_IO, or with the PF_MEMALLOC flag).

> A fix for this problem is in one of my other emails 

It's not a problem.  If callers are expecting GFP_KERNEL to be atomic,
then _that_ is a problem, but it is perfectly all right for GFP_KERNEL
allocations to block.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
