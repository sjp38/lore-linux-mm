Date: Wed, 26 Apr 2000 23:58:02 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.3.x mem balancing
In-Reply-To: <200004261736.KAA85620@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004262356210.1687-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Mark_H_Johnson.RTS@raytheon.com, linux-mm@kvack.org, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Apr 2000, Kanoj Sarcar wrote:

>[..] As far as I know, such a hook is not used on all
>drivers (in 2.4 timeframe), [..]

That's also why I still have the alpha HIGHMEM support in my TODO list so
we can ship a binary only kernel that doesn't risk to break with >2g RAM.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
