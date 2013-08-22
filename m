Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 9D1FA6B0036
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 02:51:50 -0400 (EDT)
Date: Thu, 22 Aug 2013 15:51:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 06/20] mm, hugetlb: return a reserved page to a
 reserved pool if failed
Message-ID: <20130822065156.GB13415@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-7-git-send-email-iamjoonsoo.kim@lge.com>
 <87mwobgyii.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mwobgyii.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Wed, Aug 21, 2013 at 03:24:13PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > If we fail with a reserved page, just calling put_page() is not sufficient,
> > because put_page() invoke free_huge_page() at last step and it doesn't
> > know whether a page comes from a reserved pool or not. So it doesn't do
> > anything related to reserved count. This makes reserve count lower
> > than how we need, because reserve count already decrease in
> > dequeue_huge_page_vma(). This patch fix this situation.
> 
> You may want to document you are using PagePrivate for tracking
> reservation and why it is ok to that.

Okay! I will do it in next spin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
