Date: Sun, 9 Apr 2000 01:58:52 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004082318.QAA60782@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004090140470.633-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Apr 2000, Kanoj Sarcar wrote:

>[..] if you were to send out a list of
>the specific races it is fixing. (Something like my above race example).

Hug, writing the traces for all the possible races would take me really
lots of time. Writing traces is fine for showing _the_ buggy path, but it
doesn't seems the right approch for explaning and understanding how some
new code works. The comment should explain how the new locking works
against swapoff. I'd very much prefer specific questions and
comments.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
