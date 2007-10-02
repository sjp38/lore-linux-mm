From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: remove zero_page (was Re: -mm merge plans for 2.6.24)
Date: Wed, 3 Oct 2007 03:45:09 +1000
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
In-Reply-To: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710030345.10026.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Torvalds, Linus" <torvalds@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 02 October 2007 07:22, Andrew Morton wrote:

> remove-zero_page.patch
>
>   Linus dislikes it.  Probably drop it.

I don't know if Linus actually disliked the patch itself, or disliked
my (maybe confusingly worded) rationale?

To clarify: it is not zero_page that fundamentally causes a problem,
but it is a problem that was exposed when I rationalised the page
refcounting in the kernel (and mapcounting in the mm).

I see about 4 things we can do:
1. Nothing
2. Remove zero_page
3. Reintroduce some refcount special-casing for the zero page
4. zero_page per-node or per-cpu or whatever

1 and 2 kind of imply that nothing much sane should use the zero_page
much (the former also implies that we don't care much about those who
do, but in that case, why not go for code removal?).

3 and 4 are if we think there are valid heavy users of zero page, or we
are worried about hurting badly written apps by removing it. If the former,
I'd love to hear about them; if the latter, then it definitely is a valid
concern and I have a patch to avoid refcounting (but if this is the case
then I do hope that one day we can eventually remove it).


> mm-use-pagevec-to-rotate-reclaimable-page.patch
> mm-use-pagevec-to-rotate-reclaimable-page-fix.patch
> mm-use-pagevec-to-rotate-reclaimable-page-fix-2.patch
> mm-use-pagevec-to-rotate-reclaimable-page-fix-function-declaration.patch
> mm-use-pagevec-to-rotate-reclaimable-page-fix-bug-at-include-linux-mmh220.p
>atch
> mm-use-pagevec-to-rotate-reclaimable-page-kill-redundancy-in-rotate_reclaim
>able_page.patch
> mm-use-pagevec-to-rotate-reclaimable-page-move_tail_pages-into-lru_add_drai
>n.patch
>
>   I guess I'll merge this.  Would be nice to have wider perfromance testing
>   but I guess it'll be easy enough to undo.

Care to give it one more round through -mm? Is it easy enough to
keep? I haven't had a chance to review it, which I'd like to do at some
point (and I don't think it would hurt to have a bit more testing).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
