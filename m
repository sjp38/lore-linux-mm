Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A02B28D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:40:37 -0500 (EST)
Received: by iwn40 with SMTP id 40so1449537iwn.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 22:40:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1295591340-1862-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1295591340-1862-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Fri, 21 Jan 2011 15:40:35 +0900
Message-ID: <AANLkTikOdCzhsw3_JQtbJOmA8CRm2hCZEY0LLw5uYtmM@mail.gmail.com>
Subject: Re: [PATCH 3/7] remove putback_lru_pages() in hugepage migration context
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <tatsu@ab.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>, tony.luck@intel.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,

On Fri, Jan 21, 2011 at 3:28 PM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> This putback_lru_pages() is inserted at cf608ac19c to allow
> memory compaction to count the number of migration failed pages.
>
> But we should not do it for a hugepage because page->lru of a hugepage
> is used differently from that of a normal page:
>
> =A0 in-use hugepage : page->lru is unlinked,
> =A0 free hugepage =A0 : page->lru is linked to the free hugepage list,
>
> so putting back hugepages to LRU lists collapses this rule.
> We just drop this change (without any impact on memory compaction.)
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>

As I said previously, It seems mistake during patch merge.
I didn't add it in my original patch. You can see my final patch.
https://lkml.org/lkml/2010/8/24/248

Anyway, I realized it recently so I sent the patch to Andrew.
Could you see this one?
https://lkml.org/lkml/2011/1/20/241

Thanks for notice me.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
