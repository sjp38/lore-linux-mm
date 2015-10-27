Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 02DAB6B0254
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 06:55:16 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so219814134pad.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 03:55:15 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id tc1si30348671pac.120.2015.10.27.03.55.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 03:55:15 -0700 (PDT)
Received: by pasz6 with SMTP id z6so219404631pas.2
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 03:55:15 -0700 (PDT)
Date: Tue, 27 Oct 2015 19:55:06 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151027105506.GB18741@mtj.duckdns.org>
References: <20151023083316.GB2410@dhcp22.suse.cz>
 <20151023103630.GA4170@mtj.duckdns.org>
 <20151023111145.GH2410@dhcp22.suse.cz>
 <201510232125.DAG82381.LMJtOQFOHVOSFF@I-love.SAKURA.ne.jp>
 <20151023182343.GB14610@mtj.duckdns.org>
 <201510251952.CEF04109.OSOtLFHFVFJMQO@I-love.SAKURA.ne.jp>
 <20151027092231.GC9891@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151027092231.GC9891@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Tue, Oct 27, 2015 at 10:22:31AM +0100, Michal Hocko wrote:
...
> stable kernels without causing any other regressions. 2) is the way
> to move forward for next kernels and we should really think whether
> WQ_MEM_RECLAIM should imply also WQ_HIGHPRI by default. If there is a
> general consensus that there are legitimate WQ_MEM_RECLAIM users which
> can do without the other flag then I am perfectly OK to use it for
> vmstat and oom sysrq dedicated workqueues.

I don't think flagging these things is a good approach.  These are too
easy to miss.  If this is a problem which needs to be solved, which
I'm not convined it is at this point, the right thing to do would be
doing stall detection and kicking the next work item automatically.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
