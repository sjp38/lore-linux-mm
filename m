Date: Fri, 4 Aug 2000 08:41:28 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200008041541.IAA88364@apollo.backplane.com>
Subject: Re: RFC: design for new VM
References: <Pine.LNX.4.21.0008031243070.24022-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Chris Wedgwood <cw@f00f.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

    Three or four times in the last year I've gotten emails from 
    people looking for 'VM documentation' or 'books they could read'.
    I couldn't find a blessed thing!  Oh, sure, there are papers strewn
    about, but most are very focused on single aspects of a VM design.
    I have yet to find anything that covers the whole thing.  I've written
    up an occassional 'summary piece' for FreeBSD, e.g. the Jan 2000 Daemon
    News article, but that really isn't adequate.

    The new Linux VM design looks exciting!  I will be paying close 
    attention to your progress with an eye towards reworking some of
    FreeBSD's code.  Except for one or two eyesores (1) the FreeBSD code is
    algorithmically sound, but pieces of the implementation are rather
    messy from years of patching.  When I first started working on it
    the existing crew had a big bent towards patching rather then
    rewriting and I had to really push to get some of my rewrites
    through.  The patching had reached the limits of the original 
    code-base's flexibility.

    note(1) - the one that came up just last week was the O(N) nature
    of the FreeBSD VM maps (linux uses an AVL tree here).  These work
    fine for 95% of the apps out there but turn into a sludgepile for
    things like malloc debuggers and distributed shared memory systems
    which want to mprotect() on a page-by-page basis.   The second eyesore
    is the lack of physically shared page table segments for 'standard'
    processes.  At the moment, it's an all (rfork/RFMEM/clone) or nothing
    (fork) deal.  Physical segment sharing outside of clone is something
    Linux could use to, I don't think it does it either.  It's not easy to
    do right.

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
