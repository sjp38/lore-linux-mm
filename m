Date: Tue, 25 Apr 2000 18:17:55 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: classzone VM
Message-ID: <Pine.LNX.4.21.0004251800080.9768-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

I redesigned the VM to work all classzone based instead of the current
strict zone based design. This way the memory management subsystem will
always be able to do the right choice. Classzone design is able to
optimizes the zone usage and page recycling load. There are things that
can't be done right with a strict zone based memory managemnt.

The only case where the classzone design doesn't work is if we'll need to
allocate from ZONE_NORMAL and we don't want to fallback into ZONE_DMA (so
if we really want to allocate from a single zone). But this isn't going to
be necessary even in the long term. The only reason zones exists in the
first place is because there's been different hardware generations and of
course the new generation was more powerful and so it was obviously able
to handle also the memory of the previous generation hardware. This isn't
going to change (new generation hardware will keep to be able to handle
the lower generation hardware) and so classzone design will keep to be the
optimal design IMVHO.

The patch is not a one liner and I can split it in pieces soon indeed.

However this is the first version and it may also be buggy, it's running
succesfully only since one half an hour ago so I prefer to think some more
about the code and to wait to get some more comment before entering the
cleanup phase :).

I'd like to know if people who had MM troubles with 2.3.99-prex gets they
problems fixed with the below patch applied.

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/patches/v2.3/2.3.99-pre6-pre5/classzone-VM-1.bz2

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
