Date: Thu, 13 Jan 2000 18:12:45 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <200001122111.NAA68159@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0001131806190.1648-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jan 2000, Kanoj Sarcar wrote:

>+There are two reasons to be requesting non __GFP_WAIT allocations:
>+the caller can not sleep (typically intr context), or does not want
>+to incur cost overheads of page stealing and possible swap io.

You may be in a place where you can sleep but you can't do I/O to avoid
deadlocking and so you shouldn't use __GFP_IO and nothing more (it has
nothing to do with __GFP_WAIT).

But if it can sleep and there aren't deadlock conditons going on and it
doesn't use __GFP_WAIT, it means it's buggy and has to be fixed.

I have not read the rest and the patch yet (I'll continue ASAP).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
