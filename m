Date: Thu, 8 Jul 1999 10:00:30 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFT][PATCH] 2.3.10 pre5 SMP/vm fixes
In-Reply-To: <199907080719.AAA00822@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9907080959220.6648-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Thu, 8 Jul 1999, Kanoj Sarcar wrote:
> 
> *****************************************************************
> 3. In mm/memory.c, a new comment claims:
> "The adding of pages is protected by the MM semaphore"
> which is not quite correct, since swapoff does not hold this semaphore. 

The fix is to fix swapoff, not to change the comment.

page_table_lock is _not_ going to be added to this path - I refuse to add
locks to common cases just to protect against things that never run in
practice.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
