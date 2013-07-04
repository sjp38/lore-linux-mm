Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 92EA26B0034
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 00:29:26 -0400 (EDT)
Date: Thu, 4 Jul 2013 13:29:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/5] mm, page_alloc: support multiple pages allocation
Message-ID: <20130704042925.GB7132@lge.com>
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1372840460-5571-2-git-send-email-iamjoonsoo.kim@lge.com>
 <0000013fa540f411-a89dd4a2-0fc9-428d-ad1e-5fa032413911-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013fa540f411-a89dd4a2-0fc9-428d-ad1e-5fa032413911-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 03, 2013 at 03:57:45PM +0000, Christoph Lameter wrote:
> On Wed, 3 Jul 2013, Joonsoo Kim wrote:
> 
> > @@ -298,13 +298,15 @@ static inline void arch_alloc_page(struct page *page, int order) { }
> >
> >  struct page *
> >  __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> > -		       struct zonelist *zonelist, nodemask_t *nodemask);
> > +		       struct zonelist *zonelist, nodemask_t *nodemask,
> > +		       unsigned long *nr_pages, struct page **pages);
> >
> 
> Add a separate function for the allocation of multiple pages instead?

Hello.

I will try it, but, I don't like to implement a separate function.
Please reference my reply to [0/5].

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
