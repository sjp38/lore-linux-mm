Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1970F6B006E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 18:30:48 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id b13so15607364wgh.3
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 15:30:46 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j7si27139813wiz.40.2014.12.01.15.30.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 15:30:46 -0800 (PST)
Date: Mon, 1 Dec 2014 18:30:40 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, oom: remove gfp helper function
Message-ID: <20141201233040.GB29642@phnom.home.cmpxchg.org>
References: <alpine.DEB.2.10.1411261416480.13014@chino.kir.corp.google.com>
 <20141127102547.GA18833@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141127102547.GA18833@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Qiang Huang <h.huangqiang@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 27, 2014 at 11:25:47AM +0100, Michal Hocko wrote:
> On Wed 26-11-14 14:17:32, David Rientjes wrote:
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2706,7 +2706,7 @@ rebalance:
> >  	 * running out of options and have to consider going OOM
> >  	 */
> >  	if (!did_some_progress) {
> > -		if (oom_gfp_allowed(gfp_mask)) {
> 		/*
> 		 * Do not attempt to trigger OOM killer for !__GFP_FS
> 		 * allocations because it would be premature to kill
> 		 * anything just because the reclaim is stuck on
> 		 * dirty/writeback pages.
> 		 * __GFP_NORETRY allocations might fail and so the OOM
> 		 * would be more harmful than useful.
> 		 */

I don't think we need to explain the individual flags, but it would
indeed be useful to remark here that we shouldn't OOM kill from
allocations contexts with (severely) limited reclaim abilities.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
