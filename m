Message-ID: <40225D1F.8090103@cyberone.com.au>
Date: Fri, 06 Feb 2004 02:11:27 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] mm improvements
References: <16416.64425.172529.550105@laputa.namesys.com>	<Pine.LNX.4.44.0402041459420.3574-100000@localhost.localdomain>	<16417.3444.377405.923166@laputa.namesys.com>	<4021A6BA.5000808@cyberone.com.au> <16418.19751.234876.491644@laputa.namesys.com>
In-Reply-To: <16418.19751.234876.491644@laputa.namesys.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Nikita Danilov wrote:

>To my surprise I have just found that
>
>ftp://ftp.namesys.com/pub/misc-patches/unsupported/extra/2004.02.04/p10-trasnfer-dirty-on-refill.patch
>
>[yes, I know there is a typo in the name.]
>
>patch improves performance quite measurably. It implements a suggestion
>made in the comment in refill_inactive_zone():
>
> 			/*
>			 * probably it would be useful to transfer dirty bit
>			 * from pte to the @page here.
> 			 */
>
>To do this page_is_dirty() function is used (the same one as used by
>dont-unmap-on-pageout.patch), which is implemented in
>check-pte-dirty.patch.
>
>I ran
>
>$ time build.sh 10 11
>
>(attached) and get following elapsed time:
>
>without patch: 3818.320, with patch: 3368.690 (11% improvement).
>
>

That looks nice. I promise I will test your new patches, but
can you tell me if I've misread this patch?

2004.02.04/p0f-check-pte-dirty.patch:
function page_is_dirty:
if not PageDirect, then for each pte:

+				pte_dirty = page_pte_is_dirty(page, pte_paddr);
+				if (pte_dirty != 0)
+					ret = pte_dirty;


Won't this leave ret in a random state? Should it be ret++?

Nick


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
