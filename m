Date: Tue, 6 Mar 2001 17:39:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Linux 2.2 vs 2.4 for PostgreSQL
In-Reply-To: <Pine.LNX.4.10.10103061626070.20708-100000@sphinx.mythic-beasts.com>
Message-ID: <Pine.LNX.4.33.0103061738310.1409-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Kirkwood <matthew@hairy.beasts.org>
Cc: linux-mm@kvack.org, Mike Galbraith <mikeg@wen-online.de>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2001, Matthew Kirkwood wrote:

> I have been collecting some postgres benchmark numbers
> on various kernels, which may be of interest to this
> list.
>
> The test was to run "pgbench" with various numbers of
> clients against postgresql 7.1beta4.  The benchmark
> looks rather like a fairly minimal TPC/B, with lots of
> small transactions, all committed.

Sounds like a good benchmark, I'll try it here (once the
hardware problem with the test machines are sorted out).

regards,

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
