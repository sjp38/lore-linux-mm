Date: Wed, 27 Sep 2000 09:42:45 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VM
In-Reply-To: <20000926211016.A416@bug.ucw.cz>
Message-ID: <Pine.LNX.4.21.0009270935380.993-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Sep 2000, Pavel Machek wrote:

> Okay, I'm user on small machine and I'm doing stupid thing: I've got
> 6MB ram, and I keep inserting modules. I insert module_1mb.o. Then I
> insert module_1mb.o. Repeat. How does it end? I think that
> kmalloc(GFP_KERNEL) *has* to return NULL at some point.

if a stupid root user keeps inserting bogus modules :-) then thats a
problem, no matter what. I can DoS your system if given the right to
insert arbitrary size modules, even if kmalloc returns NULL. For such
things explicit highlevel protection is needed - completely independently
of the VM allocation issues. Returning NULL in kmalloc() is just a way to
say: 'oops, we screwed up somewhere'. And i'd suggest to not work around
such screwups by checking for NULL and trying to handle it. I suggest to
rather fix those screwups.

the __GFP_SOFT suggestion handles these things nicely.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
