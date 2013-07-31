Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C71C96B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 16:55:17 -0400 (EDT)
Date: Wed, 31 Jul 2013 16:55:06 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1375304106-zw8ye9cc-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130731050250.GH2548@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-9-git-send-email-iamjoonsoo.kim@lge.com>
 <1375121151-dxyftdvy-mutt-n-horiguchi@ah.jp.nec.com>
 <20130731050250.GH2548@lge.com>
Subject: Re: [PATCH 08/18] mm, hugetlb: do hugepage_subpool_get_pages() when
 avoid_reserve
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>

On Wed, Jul 31, 2013 at 02:02:50PM +0900, Joonsoo Kim wrote:
> On Mon, Jul 29, 2013 at 02:05:51PM -0400, Naoya Horiguchi wrote:
> > On Mon, Jul 29, 2013 at 02:31:59PM +0900, Joonsoo Kim wrote:
> > > When we try to get a huge page with avoid_reserve, we don't consume
> > > a reserved page. So it is treated like as non-reserve case.
> > 
> > This patch will be completely overwritten with 9/18.
> > So is this patch necessary?
> 
> Yes. This is a bug fix, so should be separate.
> When we try to allocate with avoid_reserve, we don't use reserved page pool.
> So, hugepage_subpool_get_pages() should be called and returned if failed.
> 
> If we merge these into one, we cannot know that there exists a bug.

OK, so you can merge this with the subpool accounting fix in 6/18
as one fix.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
