Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id D662F6B0072
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 03:39:51 -0400 (EDT)
Date: Tue, 27 Aug 2013 16:40:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 03/20] mm, hugetlb: fix subpool accounting handling
Message-ID: <20130827074016.GA6795@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-4-git-send-email-iamjoonsoo.kim@lge.com>
 <87vc2zgzpn.fsf@linux.vnet.ibm.com>
 <20130822065038.GA13415@lge.com>
 <87y57u19ur.fsf@linux.vnet.ibm.com>
 <20130822074752.GH13415@lge.com>
 <871u5gehcg.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871u5gehcg.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Mon, Aug 26, 2013 at 06:31:35PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > On Thu, Aug 22, 2013 at 12:38:12PM +0530, Aneesh Kumar K.V wrote:
> >> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> >> 
> >> > Hello, Aneesh.
> >> >
> >> > First of all, thank you for review!
> >> >
> >> > On Wed, Aug 21, 2013 at 02:58:20PM +0530, Aneesh Kumar K.V wrote:
> >> >> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> >> >> 
> >> >> > If we alloc hugepage with avoid_reserve, we don't dequeue reserved one.
> >> >> > So, we should check subpool counter when avoid_reserve.
> >> >> > This patch implement it.
> >> >> 
> >> >> Can you explain this better ? ie, if we don't have a reservation in the
> >> >> area chg != 0. So why look at avoid_reserve. 
> >> >
> >> > We don't consider avoid_reserve when chg != 0.
> >> > Look at following code.
> >> >
> >> > +       if (chg || avoid_reserve)
> >> > +               if (hugepage_subpool_get_pages(spool, 1))
> >> >
> >> > It means that if chg != 0, we skip to check avoid_reserve.
> >> 
> >> when whould be avoid_reserve == 1 and chg == 0 ?
> >
> > In this case, we should do hugepage_subpool_get_pages(), since we don't
> > get a reserved page due to avoid_reserve.
> 
> As per off-list discussion we had around this, please add additional
> information in commit message explaining when we have
> avoid_reserve == 1 and chg == 0

Okay!

> 
> Something like the below copied from call site.
> 
> 	 /* If the process that created a MAP_PRIVATE mapping is about to
> 	  * perform a COW due to a shared page count, attempt to satisfy
> 	  * the allocation without using the existing reserves
>           */
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
