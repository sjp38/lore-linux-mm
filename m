Date: Mon, 15 Jan 2001 06:16:25 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: swapout selection change in pre1
In-Reply-To: <20010115102445.B18014@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.21.0101150605550.12963-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jan 2001, Jamie Lokier wrote:

> Freeing pages aggressively from a process that's paging lots will make
> that process page more, meaning more aggressive freeing etc. etc.

First, we are not necessarily freeing pages from the process. We're just
unmapping the pages and putting them on the inactive lists so they can be
actually written to swap later when they become relatively old (because
the process did not faulted the page in).

Also, the process which is trying to free pages by itself will almost
certainly do IO (to sync dirty pages), which avoids it from screwing up
the system. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
