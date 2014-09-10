Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id E33776B003B
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:05:10 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so5554576wes.7
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:05:10 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id gq8si21489329wjc.23.2014.09.10.10.05.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 10:05:09 -0700 (PDT)
Received: by mail-wi0-f173.google.com with SMTP id em10so2563594wid.0
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:05:09 -0700 (PDT)
Date: Wed, 10 Sep 2014 19:05:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140910170506.GL25219@dhcp22.suse.cz>
References: <54061505.8020500@sr71.net>
 <5406262F.4050705@intel.com>
 <54062F32.5070504@sr71.net>
 <20140904142721.GB14548@dhcp22.suse.cz>
 <5408CB2E.3080101@sr71.net>
 <20140905092537.GC26243@dhcp22.suse.cz>
 <20140910162936.GI25219@dhcp22.suse.cz>
 <54108314.80400@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54108314.80400@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave@sr71.net>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 10-09-14 09:57:56, Dave Hansen wrote:
> On 09/10/2014 09:29 AM, Michal Hocko wrote:
> > I do not have a bigger machine to play with unfortunately. I think the
> > patch makes sense on its own. I would really appreciate if you could
> > give it a try on your machine with !root memcg case to see how much it
> > helped. I would expect similar results to your previous testing without
> > the revert and Johannes' patch.
> 
> So you want to see before/after this patch:
> 
> Subject: [PATCH] mm, memcg: Do not kill release batching in
>  free_pages_and_swap_cache
> 
> And you want it on top of a kernel with the revert or without?

Revert doesn't make any difference if you run the load inside a memcg
(without any limit set).
So just before and after the patch would be sufficient.

Thanks a lot Dave!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
