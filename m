Date: Fri, 25 Aug 2000 12:45:18 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: pgd/pmd/pte and x86 kernel virtual addresses
In-Reply-To: <20000825153600Z131177-250+6@kanga.kvack.org>
Message-ID: <Pine.LNX.3.96.1000825124300.23502A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Aug 2000, Timur Tabi wrote:

> What I'm trying to do is allocate some memory via get_free_pages, and then mark
> that memory as uncacheable.

ioremap_nocache should be able to do what you want.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
