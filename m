From: Russell King <rmk@arm.linux.org.uk>
Message-Id: <200005251604.RAA02556@raistlin.arm.linux.org.uk>
Subject: Re: shm_alloc and friends
Date: Thu, 25 May 2000 17:04:10 +0100 (BST)
In-Reply-To: <Pine.LNX.3.96.1000525115511.22721B-100000@kanga.kvack.org> from "Benjamin C.R. LaHaise" at May 25, 2000 12:01:18 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: blah@kvack.org
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin C.R. LaHaise writes:
> Okay, so how about changing the SHM code to make use of pte_alloc and co?
> If we do that, then we can also make the optimisation of sharing ptes for
> really big SHM segments.

It's unneeded that its using indirect pointers - the code in no way is
reliant on a two level scheme at all.

Note that this array is only used so that SHM can keep track of the ptes
its allocated for paging them in/out of memory.  It's not used as actual
page tables.
   _____
  |_____| ------------------------------------------------- ---+---+-
  |   |         Russell King        rmk@arm.linux.org.uk      --- ---
  | | | |   http://www.arm.linux.org.uk/~rmk/aboutme.html    /  /  |
  | +-+-+                                                     --- -+-
  /   |               THE developer of ARM Linux              |+| /|\
 /  | | |                                                     ---  |
    +-+-+ -------------------------------------------------  /\\\  |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
