Date: Fri, 5 Nov 1999 17:21:05 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [Patch] shm cleanups
In-Reply-To: <qwwzows9anf.fsf@sap.com>
Message-ID: <Pine.LNX.4.10.9911051718010.1871-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: Ingo Molnar <mingo@chiara.csoma.elte.hu>, Rik van Riel <riel@nl.linux.org>, MM mailing list <linux-mm@kvack.org>, woodman@missioncriticallinux.com, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On 5 Nov 1999, Christoph Rohland wrote:

>Yes I know it is questionable, but if prepare_highmem_swapout fails we
>are in the highmem area and probably most of the rest of shm is also
>there. So we only consume a lot of CPU if going on and calling

If prepare_highmem_swapout fails maybe all the regular pages are allocated
in the rest of the shm segment and to free them and do progresses you
should continue to properly shrink the VM.

>prepare_highmem_swapout again and again..

That will happen in the patological unlikely to happen case so the
performance of such path is not an issue.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
