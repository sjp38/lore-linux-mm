From: Russell King <rmk@arm.linux.org.uk>
Message-Id: <200003271834.TAA09757@flint.arm.linux.org.uk>
Subject: Re: [PATCH] Re: kswapd
Date: Mon, 27 Mar 2000 19:34:13 +0100 (BST)
In-Reply-To: <200003270800.AAA65612@google.engr.sgi.com> from "Kanoj Sarcar" at Mar 27, 2000 12:00:21 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: riel@nl.linux.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar writes:
> On a more serious note, I know too little about the application load 
> that Rik/Russell is talking about to understand what's going on, but
> I have the vague suspicion that Rik's patch is just a part fix to the 
> problem, and that maybe we might be doing too many kswapd wakes ups
> via the balancing code. 

My situation is very simple - one copy of xaudio playing mp3s.  Nothing
else.  No swapping.  No nothing.  Just one xaudio (and the occasional
cron and atd running) playing mp3s from a NFS server.  Load average < 1.
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
