Subject: Re: Aggressive swapout with 2.4.1pre4+
References: <Pine.LNX.4.21.0101160138140.1556-100000@freak.distro.conectiva>
	<87hf2z731l.fsf@atlas.iskon.hr>
From: Christoph Rohland <cr@sap.com>
In-Reply-To: <87hf2z731l.fsf@atlas.iskon.hr>
Message-ID: <m3wvbuei5b.fsf@linux.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: 17 Jan 2001 08:56:08 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: zlatko@iskon.hr
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Zlatko Calusic <zlatko@iskon.hr> writes:

> Now looking at the pre7 (not yet compiled) I see we will have really
> impressive 2.4.1. reiserfs, Jens' blk, VM fixed... sheesh... what will
> be left for fixing? ;)

swapoff handling? (See the messages about undead swap entry) on
lkml. The whole try_to_unuse scheme is broken (reproduceable on UP)

Greetings
                Christoph

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
