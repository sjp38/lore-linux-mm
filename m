Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DEB99900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 20:56:12 -0400 (EDT)
Received: by payr10 with SMTP id r10so59900622pay.1
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 17:56:12 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id va2si12890216pbc.53.2015.06.05.17.56.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 17:56:11 -0700 (PDT)
Received: by payr10 with SMTP id r10so59900433pay.1
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 17:56:11 -0700 (PDT)
Date: Sat, 6 Jun 2015 09:56:06 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] memcg: close the race window between OOM detection
 and killing
Message-ID: <20150606005606.GA12744@mtj.duckdns.org>
References: <20150603031544.GC7579@mtj.duckdns.org>
 <20150603144414.GG16201@dhcp22.suse.cz>
 <20150603193639.GH20091@mtj.duckdns.org>
 <20150604093031.GB4806@dhcp22.suse.cz>
 <20150604192936.GR20091@mtj.duckdns.org>
 <20150605143534.GD26113@dhcp22.suse.cz>
 <20150605145759.GA5946@mtj.duckdns.org>
 <20150605152135.GE26113@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150605152135.GE26113@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

Hello, Michal.

On Fri, Jun 05, 2015 at 05:21:35PM +0200, Michal Hocko wrote:
...
> > > TIF_MEMDIE but the allocation path hasn't noticed that because it's passed
> > >         /*
> > >          * Go through the zonelist yet one more time, keep very high watermark
> > >          * here, this is only to catch a parallel oom killing, we must fail if
> > >          * we're still under heavy pressure.
> > >          */
> > >         page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
> > >                                         ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
> > > 
> > > and goes on to kill another task because there is no TIF_MEMDIE
> > > anymore.
> > 
> > Why would this be an issue if we disallow parallel killing?
> 
> I am confused. The whole thread has started by fixing a race in memcg
> and I was asking about the global case which is racy currently as well.

Ah, okay, I thought we were still talking about issues w/ making
things synchronous, but anyways, the above isn't a synchronization
race per-se which is what the original patch was trying to address for
memcg OOM path, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
