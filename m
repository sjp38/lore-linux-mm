Received: by fenrus.demon.nl
	via sendmail from stdin
	id <m13BL5l-000OVtC@amadeus.home.nl> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Sun, 9 Jul 2000 19:42:09 +0200 (CEST)
Message-Id: <m13BL5l-000OVtC@amadeus.home.nl>
Date: Sun, 9 Jul 2000 19:42:09 +0200 (CEST)
From: arjan@fenrus.demon.nl (Arjan van de Ven)
Subject: Re: sys_exit() and zap_page_range()
In-Reply-To: <3965EC8E.5950B758@uow.edu.au> <20000709103011.A3469@fruits.uzix.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Philipp Rumpf <prumpf@uzix.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In article <20000709103011.A3469@fruits.uzix.org> you wrote:

> In fact, I think it will become obvious soon that iterating through user
> page tables without rescheduling isn't _ever_ a good idea - then both the
> spin_lock and the conditional_reschedule could be moved into for_each_pte
> (well, maybe for_each_pte_user or something) and we'd actually end up
> with readable code for zap_page_range.

And we'll get into that trouble anyway when we allow user pagetables to 
be swapped out to disk as well.... (2.5 or 2.7 issue though)

Greetings,
   Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
