Date: Wed, 22 Dec 1999 10:08:11 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [patch] mmap<->write deadlock fix, plus bug in block_write_zero_range
In-Reply-To: <Pine.LNX.3.96.991222003426.18406A-100000@kanga.kvack.org>
Message-ID: <Pine.BSO.4.10.9912221003380.20066-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 1999, Benjamin C.R. LaHaise wrote:
> The patch to filemap.c changes filemap_nopage to use __find_page_nolock
> rather than __find_get_page which waits for the page to become unlocked
> before returning (maybe __find_get_page was meant to check PageUptodate?),
> since filemap_nopage checks PageUptodate before proceeding -- which is
> consistent with do_generic_file_read.

i've tried this before several times.  i could never get the system to
perform as well under benchmark load using find_page_nolock as when using
find_get_page. the throughput difference was about 5%, if i recall.  i
haven't explained this to myself yet.

perhaps a better fix would be to take out some of the page lock complexity
from filemap_nopage?  dunno.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
