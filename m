Date: Tue, 15 Jun 1999 22:24:38 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: filecache/swapcache questions
In-Reply-To: <199906151551.IAA74604@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.03.9906152223590.534-100000@mirkwood.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, sct@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 1999, Kanoj Sarcar wrote:

> I still can't see how this can happen. Note that try_to_swap_out
> either does a get_swap_page/swap_duplicate on the swaphandle,
> which gets the swap_count up to 2, or if it sees a page already in
> the swapcache, it just does a swap_duplicate. Either way, if the
> only reference on the physical page is from the swapcache, there
> will be at least one more reference on the swap page other than
> due to the swapcache. What am I missing?

When the swap I/O (if needed) finishes, the page count is
decreased by one.

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
