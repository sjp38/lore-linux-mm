From: Russell King <rmk@arm.linux.org.uk>
Message-Id: <200003270642.HAA07740@flint.arm.linux.org.uk>
Subject: Re: [PATCH] Re: kswapd
Date: Mon, 27 Mar 2000 07:42:32 +0100 (BST)
In-Reply-To: <200003270239.SAA97539@google.engr.sgi.com> from "Kanoj Sarcar" at Mar 26, 2000 06:39:14 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: riel@nl.linux.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar writes:
> > Without my patch kswapd uses between 50 and 70% CPU time
> > in a particular workload. Now it uses between 3 and 5%.
> 
> Can you explain how this is happening? I can see that in your patch,
> kswapd does not go thru the loop if need_resched is set, but with
> a single node, 3 zones, I would find it hard to explain such a 
> difference.

kswapd was running until it had a quantum, whether or not it had to
free any more pages.

> > Oh, and the latency problem probably has been fixed too...
> 
> What latency problem? I still believe that the pre3 code is doing
> the right thing, assuming 2.3.43 was doing the right thing.

Check out the linux-kernel archives, specifically for my mails about
NFS/sound problems - it is not good for processes (eg, rpciod) to be
starved of CPU time up to 200-400ms.  It was basically impossible to
play mp3s without the playback basically "stopping" for that period.

(without the patch in, I see kswapd using 200ms-400ms.  With the patch
in, it only uses >10ms very very rarely).
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
