Date: Tue, 6 Feb 2001 11:02:32 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] thinko in mm/filemap.c (242p1)
In-Reply-To: <20010206135857.J18574@jaquet.dk>
Message-ID: <Pine.LNX.4.21.0102061102150.1535-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rasmus Andersen <rasmus@jaquet.dk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Feb 2001, Rasmus Andersen wrote:

> So we start the writeout in the three first lines and wait for
> them in the last three. Without my patch we write dirty_pages
> out again in the second run.

OK, I guess it makes sense then ... ;)

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
