Date: Thu, 14 Sep 2000 01:18:56 -0700
Message-Id: <200009140818.BAA21978@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <yttg0n3lcyr.fsf@serpe.mitica> (quintela@fi.udc.es)
Subject: Re: [PATCH *] VM patch for 2.4.0-test8
References: <Pine.LNX.4.21.0009140119560.1075-100000@duckman.distro.conectiva>
	<200009140525.WAA21446@pizda.ninka.net> <yttg0n3lcyr.fsf@serpe.mitica>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: quintela@fi.udc.es
Cc: riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

   I can only see one place where we add a page to the page cache and
   we don't increase its page count, and it is in grow_buffers().
   Could somebody explain me _why_ we don't need to do a
   page_cache_get(page) in that function?

It's being added only to the LRU lists, not the page cache hashes. It
is a buffer-cache page not a page-cache page (ie. page->mapping ==
NULL).

The alloc_page() returns the page with a single reference, which thus
represents the refence to the page held by the buffer heads
grow_buffers attaches to it.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
