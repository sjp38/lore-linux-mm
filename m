Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1F9556B004A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 23:13:58 -0400 (EDT)
Date: Fri, 22 Oct 2010 11:13:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/3] page_isolation: codeclean fix comment and rm
 unneeded val init
Message-ID: <20101022031352.GA12317@localhost>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
 <20101021140105.GA9709@localhost>
 <AANLkTi=TnFswpyZc874_ydTvVD7Tn67OC9=oL_e=tnp9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=TnFswpyZc874_ydTvVD7Tn67OC9=oL_e=tnp9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2010 at 10:34:01AM +0800, Bob Liu wrote:
> On Thu, Oct 21, 2010 at 10:01 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Thu, Oct 21, 2010 at 09:28:19PM +0800, Bob Liu wrote:
> >> function __test_page_isolated_in_pageblock() return 1 if all pages
> >> in the range is isolated, so fix the comment.
> >> value pfn will be init in the following loop so rm it.
> >
> > This is a bit confusing, but the original comment should be intended
> > for test_pages_isolated()..
> 
> Maybe it used to but now it said "zone->lock must be held before call this",
> so it is the comment for __test_page_isolated_in_pageblock() nomore
> test_pages_isolated(),
> so fix the comment as this patch did.

OK.

The comment still looks a bit awkward though. There are
redundant/inconsistent "... range is free(means isolated) or not",
"... range is isolated." and "all pages are free or Marked as
ISOLATED". And the "start_pfn" is only found in test_pages_isolated().

Thanks,
Fengguang

> >> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> >> ---
> >> A mm/page_isolation.c | A  A 3 +--
> >> A 1 files changed, 1 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> >> index 5e0ffd9..4ae42bb 100644
> >> --- a/mm/page_isolation.c
> >> +++ b/mm/page_isolation.c
> >> @@ -86,7 +86,7 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
> >> A  * all pages in [start_pfn...end_pfn) must be in the same zone.
> >> A  * zone->lock must be held before call this.
> >> A  *
> >> - * Returns 0 if all pages in the range is isolated.
> >> + * Returns 1 if all pages in the range is isolated.
> >> A  */
> >> A static int
> >> A __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
> >> @@ -119,7 +119,6 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
> >> A  A  A  struct zone *zone;
> >> A  A  A  int ret;
> >>
> >> - A  A  pfn = start_pfn;
> >> A  A  A  /*
> >> A  A  A  A * Note: pageblock_nr_page != MAX_ORDER. Then, chunks of free page
> >> A  A  A  A * is not aligned to pageblock_nr_pages.
> >> --
> >> 1.5.6.3
> >
> -- 
> Regards,
> --Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
