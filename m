Date: Thu, 14 Sep 2000 13:53:33 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH *] VM patch for 2.4.0-test8
In-Reply-To: <200009140525.WAA21446@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0009141351510.10822-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2000, David S. Miller wrote:

> In page_launder() about halfway down there is this sequence of tests
> on LRU pages:
> 
> if (!clearedbuf) {
>  ...
> } else if (!page->mapping) {
>  ...
> } else if (page_count(page) > 1) {
> } else /* page->mapping && page_count(page) == 1 */ {
>  ...
> }
> 
> Above this sequence we've done a page_cache_get.

Indeed, you're right. This bug certainly explains some
of the performance things I've seen in the stress test
last night...

Btw, in case you're wondering ... the box /survived/
a stress test that would get programs killed on quite
a few "stable" kernels we've been shipping lately. ;)

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
