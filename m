Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 40F9B6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 02:37:41 -0400 (EDT)
Date: Wed, 31 Jul 2013 15:37:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 01/18] mm, hugetlb: protect reserved pages when
 softofflining requests the pages
Message-ID: <20130731063740.GA4212@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-2-git-send-email-iamjoonsoo.kim@lge.com>
 <CAJd=RBCUJg5GJEQ2_heCt8S9LZzedGLbvYvivFkmvfMChPqaCg@mail.gmail.com>
 <20130731022751.GA2548@lge.com>
 <CAJd=RBD=SNm9TG-kxKcd-BiMduOhLUubq=JpRwCy_MmiDtO9Tw@mail.gmail.com>
 <20130731044101.GE2548@lge.com>
 <CAJd=RBDr72T+O+aNdb-HyB3U+k5JiVWMoXfPNA0y-Hxw-wDD-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBDr72T+O+aNdb-HyB3U+k5JiVWMoXfPNA0y-Hxw-wDD-g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Wed, Jul 31, 2013 at 02:21:38PM +0800, Hillf Danton wrote:
> On Wed, Jul 31, 2013 at 12:41 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > On Wed, Jul 31, 2013 at 10:49:24AM +0800, Hillf Danton wrote:
> >> On Wed, Jul 31, 2013 at 10:27 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> >> > On Mon, Jul 29, 2013 at 03:24:46PM +0800, Hillf Danton wrote:
> >> >> On Mon, Jul 29, 2013 at 1:31 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> >> >> > alloc_huge_page_node() use dequeue_huge_page_node() without
> >> >> > any validation check, so it can steal reserved page unconditionally.
> >> >>
> >> >> Well, why is it illegal to use reserved page here?
> >> >
> >> > If we use reserved page here, other processes which are promised to use
> >> > enough hugepages cannot get enough hugepages and can die. This is
> >> > unexpected result to them.
> >> >
> >> But, how do you determine that a huge page is requested by a process
> >> that is not allowed to use reserved pages?
> >
> > Reserved page is just one for each address or file offset. If we need to
> > move this page, this means that it already use it's own reserved page, this
> > page is it. So we should not use other reserved page for moving this page.
> >
> Hm, how do you determine "this page" is not buddy?

If this page comes from the buddy, it doesn't matter. It imply that
this mapping cannot use reserved page pool, because we always allocate
a page from reserved page pool first.

Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
