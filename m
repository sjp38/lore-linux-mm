Date: Mon, 9 Oct 2000 21:27:00 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091552450.1562-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0010092123280.7197-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Marco Colombo <marco@esi.it>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Rik van Riel wrote:

> > yes. Please remove the above part.
> 
> OK, done.

thanks - i think all the other heuristics are 'fair': processes with more
CPU and run time used are likely to be more important, superuser processes
and direct-hw-access processes ditto.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
