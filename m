Date: Thu, 25 May 2000 12:01:18 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Reply-To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: shm_alloc and friends
In-Reply-To: <200005251520.QAA02278@raistlin.arm.linux.org.uk>
Message-ID: <Pine.LNX.3.96.1000525115511.22721B-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, riel@nl.linux.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 May 2000, Russell King wrote:

> SHM uses it on *pages* allocated from __get_free_page() and kmalloc, which are
> not page tables.
> 
> Therefore, really SHM's use of pte_clear is a hack in the extreme, breaking the
> architecture independence of the page table macros.

Okay, so how about changing the SHM code to make use of pte_alloc and co?
If we do that, then we can also make the optimisation of sharing ptes for
really big SHM segments.

		-ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
