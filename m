Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB4C6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 14:33:11 -0400 (EDT)
Received: by qgev79 with SMTP id v79so3134913qge.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 11:33:11 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id e69si22394795qhc.112.2015.09.01.11.33.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 11:33:10 -0700 (PDT)
Received: by qgev79 with SMTP id v79so3133908qge.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 11:33:10 -0700 (PDT)
Date: Tue, 1 Sep 2015 14:33:07 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/4] memcg: fix over-high reclaim amount
Message-ID: <20150901183307.GC18956@htj.dyndns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-2-git-send-email-tj@kernel.org>
 <20150828170612.GA21463@dhcp22.suse.cz>
 <20150828183209.GA9423@mtj.duckdns.org>
 <20150831075133.GA29723@dhcp22.suse.cz>
 <20150831133840.GA2271@mtj.duckdns.org>
 <20150901125149.GD8810@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150901125149.GD8810@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

Hello,

On Tue, Sep 01, 2015 at 02:51:50PM +0200, Michal Hocko wrote:
> > Is reclaim throughput as determined by CPU cycle bandwidth a
> > meaningful metric? 
> 
> Well, considering it has a direct effect on the latency I would consider
> it quite meaningful.
>
> > I'm having a bit of trouble imagining that this
> > actually would matter especially given that writeback is single
> > threaded per bdi_writeback.
> 
> Sure, if the LRU contains a lot of dirty pages then the writeback will be
> a bottleneck. But LRUs are quite often full of the clean pagecache pages
> which can be reclaimed quickly and efficiently.

I see.  Hmmm... I can imagine the scheduling latencies from
synchronization being a factor.  Alright, if we decide to do this
return-path reclaiming, I'll update the patch to accumulate nr_pages.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
