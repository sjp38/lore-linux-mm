Date: Wed, 26 Jan 2000 01:48:43 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: 2.2.1{3,4,5pre*} VM bug found
In-Reply-To: <Pine.LNX.4.10.10001251906370.14600-100000@d251.suse.de>
Message-ID: <Pine.LNX.4.10.10001260146290.1373-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 25 Jan 2000, Andrea Arcangeli wrote:

> Before calling schedule() you always gets registered in a
> waitqueue so you can't deadlock or wait too much.
> 
> If something there is the opposite problem. If you do:
> 
> 	__set_current_state(TASK_UNINTERRUPTIBLE);
> 	get_page(GFP_KERNEL);
> 	XXXXXXXXXXXXXXXXXXXX
> 	schedule();
> 
> then at point XXXXXXX you may become a task running and you don't
> block anymore.

The problem in this case is that schedule() may be called
from within get_page(GFP_KERNEL). This already was possible
in 2.2.14 and before (if the task had to wait for I/O on
try_to_free_pages()), but the explicit schedule() in my
stuff in 2.2.15pre4 amplified the problem and made it
visible.

A fix for this problem is in one of my other emails and
at my web page:  http://www.surriel.com/patches/

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
