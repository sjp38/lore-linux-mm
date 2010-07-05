Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D2E0C6B01B2
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 04:49:40 -0400 (EDT)
Date: Mon, 5 Jul 2010 17:44:15 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/7] hugepage migration
Message-ID: <20100705084415.GA29648@spritzera.linux.bs1.fc.nec.co.jp>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100702083026.GB12221@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100702083026.GB12221@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 02, 2010 at 10:30:26AM +0200, Andi Kleen wrote:
> On Fri, Jul 02, 2010 at 02:47:19PM +0900, Naoya Horiguchi wrote:
> > This is a patchset for hugepage migration.
> 
> Thanks for working on this.
> > 
> > There are many users of page migration such as soft offlining,
> > memory hotplug, memory policy and memory compaction,
> > but this patchset adds hugepage support only for soft offlining
> > as the first step.
> 
> Is that simply because the callers are not hooked up yet 
> for the other cases, or more fundamental issues?

Yes, it's just underway.
I hope we have no critical problems to implement other cases at the time.

> 
> > I tested this patchset with 'make func' in libhugetlbfs and
> > have gotten the same result as one from 2.6.35-rc3.
> 
> Is there a tester for the functionality too? (e.g. mce-test test cases)

Yes.
I'll send patches on mce-test suite later.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
