Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 6ACFB6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 22:25:16 -0400 (EDT)
Date: Tue, 09 Apr 2013 22:24:58 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1365560698-qyvvld1y-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAHGf_=oL7dORGCJZtLxrwc9cGgrakAsfAOJ4xx659nDmQd=rcw@mail.gmail.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515F68BB.3010601@gmail.com>
 <1365538036-pu7x5mck-mutt-n-horiguchi@ah.jp.nec.com>
 <CAHGf_=o+GQ9PJy=rkO1zxhd81NpyTvDQA7phN8StX2+EQ+ZE=g@mail.gmail.com>
 <1365547416-z92y6qa9-mutt-n-horiguchi@ah.jp.nec.com>
 <CAHGf_=oL7dORGCJZtLxrwc9cGgrakAsfAOJ4xx659nDmQd=rcw@mail.gmail.com>
Subject: Re: [PATCH 09/10] memory-hotplug: enable memory hotplug to handle
 hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 09, 2013 at 09:56:58PM -0400, KOSAKI Motohiro wrote:
> On Tue, Apr 9, 2013 at 6:43 PM, Naoya Horiguchi
...
> > MIGRATE_ISOLTE is changed only within the range [start_pfn, end_pfn)
> > given as the argument of __offline_pages (see also start_isolate_page_range),
> > so it's set only for pages within the single memblock to be offlined.
> 
> When partial memory hot remove, that's correct behavior. different
> node is not required.
> 
> > BTW, in previous discussion I already agreed with checking migrate type
> > in hugepage allocation code (maybe it will be in dequeue_huge_page_vma(),)
> > so what you concern should be solved in the next post.
> 
> Umm.. Maybe I missed such discussion. Do you have a pointer?

Please see the bottom of the following:
  http://thread.gmane.org/gmane.linux.kernel.mm/96665/focus=96920
It's not exactly the same, but we need to prevent the allocation
from the memblock under hotremoving not only to be efficient,
but also to avoid the race.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
