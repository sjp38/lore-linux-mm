Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 05F766B00B6
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 04:31:48 -0400 (EDT)
Date: Fri, 19 Mar 2010 17:30:25 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/2] pagemap: add #ifdefs CONFIG_HUGETLB_PAGE on code
	walking hugetlb vma
Message-ID: <20100319083025.GA13107@spritzerA.linux.bs1.fc.nec.co.jp>
References: <1268979996-12297-1-git-send-email-n-horiguchi@ah.jp.nec.com> <20100319152934.c4243698.kamezawa.hiroyu@jp.fujitsu.com> <20100319065334.GB12389@spritzerA.linux.bs1.fc.nec.co.jp> <20100319161504.2c5c65b5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100319161504.2c5c65b5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, Mar 19, 2010 at 04:15:04PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 19 Mar 2010 15:53:34 +0900
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > On Fri, Mar 19, 2010 at 03:29:34PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Fri, 19 Mar 2010 15:26:35 +0900
> > > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > > 
> > > > If !CONFIG_HUGETLB_PAGE, pagemap_hugetlb_range() is never called.
> > > > So put it (and its calling function) into #ifdef block.
> > > > 
> > > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > 
> > > Hmm? What is benefit ? Is this broken now ?
> > > 
> > 
> > Not broken, but this is needed to avoid build error with patch 2/2 applied,
> > where I move huge_pte_offset() (not defined when !HUGETLB_PAGE)
> > into pagemap_hugetlb_range().
> > 
> 
> I think this should be merged with 2/2....if necessary.
> 

I split them for ease of review.
Also removing unused code is beneficial as it reduces kernel binary size.

But if you really want, I can merge them into one patch.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
