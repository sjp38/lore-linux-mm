Date: Mon, 24 Nov 2008 13:49:39 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 8/8] mm: add add_to_swap stub
In-Reply-To: <4929DF54.8050104@redhat.com>
Message-ID: <Pine.LNX.4.64.0811241340140.17541@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
 <Pine.LNX.4.64.0811232205180.4142@blonde.site> <4929DF54.8050104@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 23 Nov 2008, Rik van Riel wrote:
> Hugh Dickins wrote:
> > 
> > This was intended as a source cleanup, but looking more closely, it turns
> > out that the !CONFIG_SWAP case was going to keep_locked for an anonymous
> > page, whereas now it goes to the more suitable activate_locked, like the
> > CONFIG_SWAP nr_swap_pages 0 case.
> 
> If there is no swap space available, we will not scan the
> anon pages at all.

Ah, yes, you explained that to me already a few months ago: sorry.

I thought it might be the case, but didn't spot where, so actually
ran !CONFIG_SWAP, counting how many add_to_swap()s occurred, before
sending in the patch - I wasn't sure how big a deal to make of the
keep_locked issue in the comment.

On one run I _did_ see a flurry of add_to_swap()s, but wasn't able
to reproduce it - found it hard to get the balance right between
trying to swap and OOMing, and my test wasn't very inventive.

It didn't seem worth pursuing further at the time, but now you say
"we will not scan the anon pages at all", I wonder if I ought to
try to reproduce it, to see how we came to be trying add_to_swap()
in that case?  Or is there a corner case you know of, and it's not
worth worrying further?

> 
> Hmm, maybe we need a special simplified get_scan_ratio()
> for !CONFIG_SWAP?

But without adding #ifdef CONFIG_SWAPs back in: patch follows.

> 
> > Signed-off-by: Hugh Dickins <hugh@veritas.com>
> 
> Acked-by: Rik van Riel <riel@redhat.com>

Thanks a lot for looking at these.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
