Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id A693E6B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 12:44:07 -0400 (EDT)
Date: Wed, 31 Jul 2013 12:43:52 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1375289032-ksc4vltc-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130731051221.GK2548@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-16-git-send-email-iamjoonsoo.kim@lge.com>
 <1375124737-9w10y4c4-mutt-n-horiguchi@ah.jp.nec.com>
 <1375125555-yuwxqz39-mutt-n-horiguchi@ah.jp.nec.com>
 <20130731051221.GK2548@lge.com>
Subject: Re: [PATCH 15/18] mm, hugetlb: move up anon_vma_prepare()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>

On Wed, Jul 31, 2013 at 02:12:21PM +0900, Joonsoo Kim wrote:
> On Mon, Jul 29, 2013 at 03:19:15PM -0400, Naoya Horiguchi wrote:
> > On Mon, Jul 29, 2013 at 03:05:37PM -0400, Naoya Horiguchi wrote:
> > > On Mon, Jul 29, 2013 at 02:32:06PM +0900, Joonsoo Kim wrote:
> > > > If we fail with a allocated hugepage, it is hard to recover properly.
> > > > One such example is reserve count. We don't have any method to recover
> > > > reserve count. Although, I will introduce a function to recover reserve
> > > > count in following patch, it is better not to allocate a hugepage
> > > > as much as possible. So move up anon_vma_prepare() which can be failed
> > > > in OOM situation.
> > > > 
> > > > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > 
> > > Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > 
> > Sorry, let me suspend this Reviewed for a question.
> > If alloc_huge_page failed after we succeeded anon_vma_parepare,
> > the allocated anon_vma_chain and/or anon_vma are safely freed?
> > Or don't we have to free them?
> 
> Yes, it will be freed by free_pgtables() and then unlink_anon_vmas()
> when a task terminate. So, we don't have to free them.

OK, thanks for clarification.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
