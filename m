Message-ID: <4929DF54.8050104@redhat.com>
Date: Sun, 23 Nov 2008 17:55:16 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/8] mm: add add_to_swap stub
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site> <Pine.LNX.4.64.0811232205180.4142@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0811232205180.4142@blonde.site>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> If we add a failing stub for add_to_swap(),
> then we can remove the #ifdef CONFIG_SWAP from mm/vmscan.c.
> 
> This was intended as a source cleanup, but looking more closely, it turns
> out that the !CONFIG_SWAP case was going to keep_locked for an anonymous
> page, whereas now it goes to the more suitable activate_locked, like the
> CONFIG_SWAP nr_swap_pages 0 case.

If there is no swap space available, we will not scan the
anon pages at all.

Hmm, maybe we need a special simplified get_scan_ratio()
for !CONFIG_SWAP?

> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
