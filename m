Date: Fri, 14 Jan 2000 14:43:42 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <20000114132546.A18109@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.21.0001141441490.316-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lkd@tantalophile.demon.co.uk>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Rik van Riel <riel@nl.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Fri, 14 Jan 2000, Jamie Lokier wrote:

>It would seem logical that when a page in the DMA zone is only held for
>swap cache, it's worth copying it to the regular zone and using the copy
>when the page is needed again to free up DMA pages without hitting the
>disk.

That's basically what I am just doing for preserving regular pages w.r.t.
high pages in replace_with_highmem but currently I am not graceful against
DMA pages yet.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
