Date: Tue, 10 Oct 2000 12:32:50 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] OOM killer API (was: [PATCH] VM fix for 2.4.0-test9 &
 OOM handler)
In-Reply-To: <20001010170708.C784@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.21.0010101231120.11122-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Oct 2000, Ingo Oeser wrote:

> before you argue endlessly about the "Right OOM Killer (TM)", I
> did a small patch to allow replacing the OOM killer at runtime.
> 
> So now you can stop arguing about the one and only OOM killer,
> implement it, provide it as module and get back to the important
> stuff ;-)

This is definately a cool toy for people who have doubts
that my OOM killer will do the wrong thing in their
workloads.

If anyone can demonstrate that the current OOM killer is
doing the wrong thing and has a replacement algorithm
available, please let us know ... ;)

[lets move the discussion back to a less theoretical and
more practical point of view]

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
