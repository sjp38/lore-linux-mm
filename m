From: Russell King <rmk@arm.linux.org.uk>
Message-Id: <200005251436.PAA02081@raistlin.arm.linux.org.uk>
Subject: Re: shm_alloc and friends
Date: Thu, 25 May 2000 15:36:16 +0100 (BST)
In-Reply-To: <E12uyfj-0007vF-00@the-village.bc.nu> from "Alan Cox" at May 25, 2000 03:31:38 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: riel@nl.linux.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox writes:
> > Problems:
> >  - memsetting the vmalloced area to initialise the pte's.
> >    (Note: pte_clear can't be used, because that is expected to be used
> 
> Sorry that breaks S/390. You cannot use memset here.

Suggestions on a fix for that?
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
