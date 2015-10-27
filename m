Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B40236B0038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 07:30:48 -0400 (EDT)
Received: by pasz6 with SMTP id z6so220244736pas.2
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 04:30:48 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id j6si61230479pbq.56.2015.10.27.04.30.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 04:30:47 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so220656735pad.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 04:30:47 -0700 (PDT)
Date: Tue, 27 Oct 2015 20:30:40 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for
 zone_reclaimable()checks
Message-ID: <20151027113040.GA22729@mtj.duckdns.org>
References: <20151023083316.GB2410@dhcp22.suse.cz>
 <20151023103630.GA4170@mtj.duckdns.org>
 <20151023111145.GH2410@dhcp22.suse.cz>
 <20151023182109.GA14610@mtj.duckdns.org>
 <20151027091603.GB9891@dhcp22.suse.cz>
 <201510272007.HHI18717.MOOtJQHSVFOLFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510272007.HHI18717.MOOtJQHSVFOLFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Tue, Oct 27, 2015 at 08:07:38PM +0900, Tetsuo Handa wrote:
> Can't we have a waitqueue like
> http://lkml.kernel.org/r/201510142121.IDE86954.SOVOFFQOFMJHtL@I-love.SAKURA.ne.jp ?

There's no reason to complicate it.  It wouldn't buy anything
meaningful.  Can we please stop trying to solve a non-existent
problem?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
