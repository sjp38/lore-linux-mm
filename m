Date: Mon, 1 May 2000 19:38:51 -0600 (MDT)
From: Roel van der Goot <roel@cs.ualberta.ca>
Subject: Re: [PATCH] pre7-1 semicolon & nicely readable
In-Reply-To: <Pine.LNX.4.21.0005012222540.7508-100000@duckman.conectiva>
Message-ID: <Pine.SOL.3.96.1000501193548.4093L-100000@sexsmith.cs.ualberta.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Mon, 1 May 2000, Rik van Riel wrote:

> In fact, the <10 test is only there to prevent infinite looping
> for when a process with 0 swap_cnt "slips through" the tests above.

In case of a "slip through" variable i will have a different
value after the loop. But I understand from your reply that you
covered that case.

Cheers,
Roel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
