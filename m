Date: Fri, 19 Jan 2001 12:45:48 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: <mingo@elte.hu>
Subject: Re: [PATCH] Limited background active list [and pte] scanning 
In-Reply-To: <Pine.LNX.4.21.0101181958290.4610-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.30.0101191245100.1137-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Marcelo,

your patch did not compile as-is because you did not export the
bp_page_aging variable to mm/swap.c.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
