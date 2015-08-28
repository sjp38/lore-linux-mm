Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id CF91E6B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 17:14:28 -0400 (EDT)
Received: by ykdz80 with SMTP id z80so28149308ykd.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 14:14:28 -0700 (PDT)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id r126si4883237ywf.185.2015.08.28.14.14.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 14:14:28 -0700 (PDT)
Received: by ykay144 with SMTP id y144so12835878yka.2
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 14:14:26 -0700 (PDT)
Date: Fri, 28 Aug 2015 17:14:23 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150828211423.GC11089@htj.dyndns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
 <20150828171322.GC21463@dhcp22.suse.cz>
 <20150828204554.GM9610@esperanza>
 <20150828205301.GB11089@htj.dyndns.org>
 <20150828210704.GN9610@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828210704.GN9610@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hey,

On Sat, Aug 29, 2015 at 12:07:04AM +0300, Vladimir Davydov wrote:
> We should probably think about introducing some kind of watermarks that
> would trigger memcg reclaim, asynchronous or direct, on exceeding
> them.

Yeah, for max + kmemcg case, we eventually should do something similar
to the global case where we try to kick off async reclaim before we
hit the hard wall.  Ultimately, I think punting reclaims to workqueue
or return-path is a good idea anyway, so maybe it can be all part of
the same mechanism.  Given that the high limit is the primary control
mechanism on the default hierarchy, it should be fine for now.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
