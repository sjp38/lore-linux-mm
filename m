Date: Tue, 15 Jun 1999 09:32:19 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: filecache/swapcache questions
In-Reply-To: <199906150716.AAA88552@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.05.9906150930310.13631-100000@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 1999, Kanoj Sarcar wrote:

> Q1. Is it really needed to put all the swap pages in the swapper_inode
> i_pages?

Yes, see below.

> How will it be possible for a page to be in the swapcache, for its
> reference count to be 1 (which has been checked just before), and for
> its swap_count(page->offset) to also be 1? I can see this being
> possible only if an unmap/exit path might lazily leave a anonymous
> page in the swap cache, but I don't believe that happens.

It does happen. We use a 'two-stage' reclamation process instead
of page aging. It seems to work wonderfully -- nice page aging
properties without the overhead. Plus, it automatically balances
swap and cache memory since the same reclamation routine passes
over both types of pages.


Rik -- Open Source: you deserve to be in control of your data.
+-------------------------------------------------------------------+
| Le Reseau netwerksystemen BV:               http://www.reseau.nl/ |
| Linux Memory Management site:   http://www.linux.eu.org/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
