Date: Sun, 9 Apr 2000 01:39:10 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004082321.QAA01209@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004090135050.620-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Apr 2000, Kanoj Sarcar wrote:

>As I mentioned before, have you stress tested this to make sure grabbing

I have stress tested the whole thing (also a few minutes ago to check the
latest patch) but it never locked up so we have to think about it.

Could you explain why you think it's the inverse lock ordering?

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
