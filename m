Message-ID: <3914264A.B6A660E@ucla.edu>
Date: Sat, 06 May 2000 07:03:54 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: [DATAPOINT] pre7-6 will not swap
References: <Pine.LNX.4.21.0005061844560.4627-100000@duckman.conectiva> <39149B81.B92C8741@sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Once again, I'm back to asking, should we be swapping at all?
> Shouldn't shrink_mmap() be finding pages to throw out?
> 

Thats a good question.  However, it also misses part of the point.

The reason for the bad performance is not mainly that there is too
little swapout.  The WRONG PAGES are swapped out!  The system spends
most of its I/O bandwith doing page-in's.

Remember, on my system, the VM swapped out the quake ENGINE, which was
running 100% of the time, in order to keep unused daemons blocking on
select in core.

That is just wrong.  Right?

-benRI
-- 
"I want to be in the light, as He is in the Light,
 I want to shine like the stars in the heavens." - DC Talk, "In the
Light"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
