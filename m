Date: Mon, 30 Apr 2001 15:26:18 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: Hopefully a simple question on /proc/pid/mem
In-Reply-To: <Pine.LNX.3.96.1010430145934.30664D-100000@kanga.kvack.org>
Message-ID: <Pine.GSO.4.21.0104301508550.5737-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Richard F Weber <rfweber@link.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 30 Apr 2001, Benjamin C.R. LaHaise wrote:

> On Mon, 30 Apr 2001, Alexander Viro wrote:
> 
> > I wonder what's wrong with reading from /proc/<pid>/mem, though - it's
> > using the same code as ptrace.
> 
> We can actually do this cleanly now that we have proper page_dirty
> semantics for raw io.  The original reason for disabling /proc/*/mem was
> that it left big gaping holes in the mm code in 2.0, and it hasn't been
> repaired since.

ITYM "disabling _write_ on /proc/*/mem". Read is OK. Anyway, current
mem_write() uses the same code as PTRACE_POKEDATA, so if the latter works,
the former also should be OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
