Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 912796B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 11:33:34 -0400 (EDT)
Date: Fri, 19 Jul 2013 17:33:32 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v3 0/8] extend hugepage migration
Message-ID: <20130719153332.GG6123@two.firstfloor.org>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 18, 2013 at 05:34:24PM -0400, Naoya Horiguchi wrote:
> Here is the 3rd version of hugepage migration patchset.
> I rebased it onto v3.11-rc1 and applied most of your feedbacks.
> 
> Some works referred to in previous discussion (shown below) are not included
> in this patchset, but likely to be done after this work.
>  - using page walker in check_range
>  - split page table lock for pmd/pud based hugepage (maybe applicable to thp)

I did a quick read through the patchkit and it looks all good to me.
It also closes a long standing gap. Thanks!

Acked-by: Andi Kleen <ak@linux.intel.com>

> Hugepage migration of 1GB hugepage is not enabled for now, because
> I'm not sure whether users of 1GB hugepage really want it.
> We need to spare free hugepage in order to do migration, but I don't
> think that users want to 1GB memory to idle for that purpose
> (currently we can't expand/shrink 1GB hugepage pool after boot).

I think we'll need 1GB migration sooner or later. As memory sizes
go up 1GB use will be more common, and the limitation of not
expanding/shrinking 1GB will be eventually fixed.

It would be just a straight forward extension of your patchkit,
right?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
