Date: Tue, 2 May 2000 11:54:19 +0100 (BST)
From: Chris Evans <chris@ferret.lmh.ox.ac.uk>
Subject: Re: [PATCH] pre7-1 semicolon & nicely readableB
In-Reply-To: <Pine.LNX.4.21.0005012222540.7508-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0005021152330.10854-100000@ferret.lmh.ox.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Roel van der Goot <roel@cs.ualberta.ca>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Mon, 1 May 2000, Rik van Riel wrote:

> I want to inform you that you're wrong. The only difference is
> in readability.

[..]

> In fact, the <10 test is only there to prevent infinite looping
> for when a process with 0 swap_cnt "slips through" the tests above.

If such a value should never "slip through", then, for readability, you
want an assert (e.g. BUG() ).

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
