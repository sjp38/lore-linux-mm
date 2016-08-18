Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB4F6B025E
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 02:40:06 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k135so6088167lfb.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 23:40:06 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id l11si28715173wmg.37.2016.08.17.23.40.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 23:40:04 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i5so3294600wmg.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 23:40:04 -0700 (PDT)
Date: Thu, 18 Aug 2016 08:40:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] fs: super.c: Add tracepoint to get name of
 superblock shrinker
Message-ID: <20160818064001.GB30162@dhcp22.suse.cz>
References: <cover.1471496832.git.janani.rvchndrn@gmail.com>
 <600943d0701ae15596c36194684453fef9ee075e.1471496833.git.janani.rvchndrn@gmail.com>
 <20160818063239.GO2356@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160818063239.GO2356@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Thu 18-08-16 07:32:39, Al Viro wrote:
> On Thu, Aug 18, 2016 at 02:09:31AM -0400, Janani Ravichandran wrote:
> 
> >  static LIST_HEAD(super_blocks);
> > @@ -64,6 +65,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
> >  	long	inodes;
> >  
> >  	sb = container_of(shrink, struct super_block, s_shrink);
> > +	trace_mm_shrinker_callback(shrink, sb->s_type->name);
> 
> IOW, we are (should that patch be accepted) obliged to keep the function in
> question and the guts of struct shrinker indefinitely.

I am not aware that trace points are considered a stable ABI. Is that
documented anywhere? We have changed/removed some of them in the
past. If there is a debugging tool parsing them the tool itself is
responsible to keep track of any changes.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
