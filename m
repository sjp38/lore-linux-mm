Message-ID: <4929DC82.4090103@redhat.com>
Date: Sun, 23 Nov 2008 17:43:14 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] mm: reuse_swap_page replaces can_share_swap_page
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site> <Pine.LNX.4.64.0811232156120.4142@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0811232156120.4142@blonde.site>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> A good place to free up old swap is where do_wp_page(), or do_swap_page(),
> is about to redirty the page: the data on disk is then stale and won't be
> read again; and if we do decide to write the page out later, using the
> previous swap location makes an unnecessary disk seek very likely.

Better still, it frees up swap space that will never be read
anyway.  This helps with workloads that push the system closer
to the edge and helps leave read-only pages on swap, avoiding
IO.

> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
