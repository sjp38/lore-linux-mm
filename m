Date: Wed, 13 Sep 2000 22:25:14 -0700
Message-Id: <200009140525.WAA21446@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: 
	<Pine.LNX.4.21.0009140119560.1075-100000@duckman.distro.conectiva>
	(message from Rik van Riel on Thu, 14 Sep 2000 01:30:26 -0300 (BRST))
Subject: Re: [PATCH *] VM patch for 2.4.0-test8
References: <Pine.LNX.4.21.0009140119560.1075-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

In page_launder() about halfway down there is this sequence of tests
on LRU pages:

if (!clearedbuf) {
 ...
} else if (!page->mapping) {
 ...
} else if (page_count(page) > 1) {
} else /* page->mapping && page_count(page) == 1 */ {
 ...
}

Above this sequence we've done a page_cache_get.  For the final case
in the tests above (page->mapping != NULL && page_count(page) == 1)
have you checked if this ever happens or is even possible?

If the page is a page cache page (ie. page->mapping != NULL) it
should hold a reference.  Adding in our reference, the count should
always thus be > 1.

What did I miss?

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
