Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E76E06B01B5
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 04:30:30 -0400 (EDT)
Date: Fri, 2 Jul 2010 10:30:26 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/7] hugepage migration
Message-ID: <20100702083026.GB12221@basil.fritz.box>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 02, 2010 at 02:47:19PM +0900, Naoya Horiguchi wrote:
> This is a patchset for hugepage migration.

Thanks for working on this.
> 
> There are many users of page migration such as soft offlining,
> memory hotplug, memory policy and memory compaction,
> but this patchset adds hugepage support only for soft offlining
> as the first step.

Is that simply because the callers are not hooked up yet 
for the other cases, or more fundamental issues?


> I tested this patchset with 'make func' in libhugetlbfs and
> have gotten the same result as one from 2.6.35-rc3.

Is there a tester for the functionality too? (e.g. mce-test test cases)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
