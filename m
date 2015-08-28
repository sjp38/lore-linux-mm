Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 492006B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 14:32:13 -0400 (EDT)
Received: by ykek5 with SMTP id k5so10152421yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 11:32:13 -0700 (PDT)
Received: from mail-yk0-x232.google.com (mail-yk0-x232.google.com. [2607:f8b0:4002:c07::232])
        by mx.google.com with ESMTPS id j137si4607903ywg.114.2015.08.28.11.32.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 11:32:12 -0700 (PDT)
Received: by ykek5 with SMTP id k5so10151867yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 11:32:11 -0700 (PDT)
Date: Fri, 28 Aug 2015 14:32:09 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/4] memcg: fix over-high reclaim amount
Message-ID: <20150828183209.GA9423@mtj.duckdns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-2-git-send-email-tj@kernel.org>
 <20150828170612.GA21463@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828170612.GA21463@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

Hello,

On Fri, Aug 28, 2015 at 07:06:13PM +0200, Michal Hocko wrote:
> I do not think this a better behavior. If you have parallel charges to
> the same memcg then you can easilly over-reclaim  because everybody
> will reclaim the maximum rather than its contribution.
> 
> Sure we can fail to reclaim the target and slowly grow over high limit
> but that is to be expected. This is not the max limit which cannot be
> breached and external memory pressure/reclaim is there to mitigate that.

Ah, I see, yeah, over-reclaim can happen.  How about just wrapping the
over-high reclaim with a per-memcg mutex?  Do we gain anything by
putting multiple tasks into the reclaim path?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
