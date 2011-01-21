Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2B58D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 05:04:26 -0500 (EST)
Date: Fri, 21 Jan 2011 19:00:28 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/7] remove putback_lru_pages() in hugepage migration
 context
Message-ID: <20110121100028.GA11102@spritzera.linux.bs1.fc.nec.co.jp>
References: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1295591340-1862-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <AANLkTikOdCzhsw3_JQtbJOmA8CRm2hCZEY0LLw5uYtmM@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <AANLkTikOdCzhsw3_JQtbJOmA8CRm2hCZEY0LLw5uYtmM@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>, tony.luck@intel.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Jan 21, 2011 at 03:40:35PM +0900, Minchan Kim wrote:
> Hello,
> 
> On Fri, Jan 21, 2011 at 3:28 PM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > This putback_lru_pages() is inserted at cf608ac19c to allow
> > memory compaction to count the number of migration failed pages.
> >
> > But we should not do it for a hugepage because page->lru of a hugepage
> > is used differently from that of a normal page:
> >
> >   in-use hugepage : page->lru is unlinked,
> >   free hugepage   : page->lru is linked to the free hugepage list,
> >
> > so putting back hugepages to LRU lists collapses this rule.
> > We just drop this change (without any impact on memory compaction.)
> >
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Minchan Kim <minchan.kim@gmail.com>
> 
> As I said previously, It seems mistake during patch merge.
> I didn't add it in my original patch. You can see my final patch.
> https://lkml.org/lkml/2010/8/24/248

OK.

> Anyway, I realized it recently so I sent the patch to Andrew.
> Could you see this one?
> https://lkml.org/lkml/2011/1/20/241

This patch seems not to change hugepage soft offline's behavior,
so I have no objection.

-- Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
