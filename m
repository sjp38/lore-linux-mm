Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id BD6F36B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 14:21:23 -0400 (EDT)
Received: by pasz6 with SMTP id z6so124549177pas.2
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 11:21:23 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id sk1si31266398pbc.113.2015.10.23.11.21.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 11:21:22 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so124776617pad.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 11:21:22 -0700 (PDT)
Date: Sat, 24 Oct 2015 03:21:09 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151023182109.GA14610@mtj.duckdns.org>
References: <20151022140944.GA30579@mtj.duckdns.org>
 <20151022150623.GE26854@dhcp22.suse.cz>
 <20151022151528.GG30579@mtj.duckdns.org>
 <20151022153559.GF26854@dhcp22.suse.cz>
 <20151022153703.GA3899@mtj.duckdns.org>
 <20151022154922.GG26854@dhcp22.suse.cz>
 <20151022184226.GA19289@mtj.duckdns.org>
 <20151023083316.GB2410@dhcp22.suse.cz>
 <20151023103630.GA4170@mtj.duckdns.org>
 <20151023111145.GH2410@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151023111145.GH2410@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Hello,

On Fri, Oct 23, 2015 at 01:11:45PM +0200, Michal Hocko wrote:
> > The problem here is not lack
> > of execution resource but concurrency management misunderstanding the
> > situation. 
> 
> And this sounds like a bug to me.

I don't know.  I can be argued either way, the other direction being a
kernel thread going RUNNING non-stop is buggy.  Given how this has
been a complete non-issue for all the years, I'm not sure how useful
plugging this is.

> Don't we have some IO related paths which would suffer from the same
> problem. I haven't checked all the WQ_MEM_RECLAIM users but from the
> name I would expect they _do_ participate in the reclaim and so they
> should be able to make a progress. Now if your new IMMEDIATE flag will

Seriously, nobody goes full-on RUNNING.

> guarantee that then I would argue that it should be implicit for
> WQ_MEM_RECLAIM otherwise we always risk a similar situation. What would
> be a counter argument for doing that?

Not serving any actual purpose and degrading execution behavior.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
