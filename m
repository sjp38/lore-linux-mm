Date: Wed, 21 Jun 2000 15:41:04 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <200006212037.NAA59219@google.engr.sgi.com>
References: <20000621200418Z131176-21004+46@kanga.kvack.org> from "Timur Tabi" at Jun 21, 2000 02:57:52 PM
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Message-Id: <20000621204734Z131177-21003+32@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Kanoj Sarcar <kanoj@google.engr.sgi.com> on Wed, 21
Jun 2000 13:37:14 -0700 (PDT)


> Even though there is unused space, that might be padding out certain
> data structures to cache line aligned sizes, causing lesser cache
> line eviction etc, at the cost of few more bytes of unused space. On
> certain applications, this can cause a noticeable improvement.

Oh, that has to do with this comment in mmzone.h:

 * Right now a zonelist takes up less than a cacheline. We never
 * modify it apart from boot-up, and only a few indices are used,
 * so despite the zonelist table being relatively big, the cache
 * footprint of this construct is very small.

But isn't that talking about the individual zonelist_t structures, not the
entire node_zonelists array?  I mean, we're talking about 224 UNUSED array
elements, which is much bigger than any cache line.  And since the stuff is
never used, it's never cached either.



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
