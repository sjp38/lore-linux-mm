Date: Tue, 1 May 2001 10:14:36 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: <mingo@elte.hu>
Subject: Re: RFC: Bouncebuffer fixes
In-Reply-To: <20010429154227.E11395@athlon.random>
Message-ID: <Pine.LNX.4.33.0105011013200.4030-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org, alan@lxorguk.ukuu.org.uk, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Apr 2001, Andrea Arcangeli wrote:

> just in case, also make sure you merged in my fixes as well, the first
> patch I seen was buggy and could deadlock the machine for MM unrelated
> reasons.

all the deadlock-unrelated fixes were merged into the -ac tree long ago,
so that is certainly not the cause of the deadlock.

please re-check whether there are any fixes missing in the latest ac tree
+ Arjan's fixes.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
