Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 111436B0253
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:14:23 -0400 (EDT)
Received: by pasz6 with SMTP id z6so89176156pas.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:14:22 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id rn4si21731032pbc.138.2015.10.22.08.14.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 08:14:22 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so89323464pad.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:14:22 -0700 (PDT)
Date: Fri, 23 Oct 2015 00:14:14 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151022151414.GF30579@mtj.duckdns.org>
References: <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022142155.GB30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220923130.23591@east.gentwo.org>
 <20151022142429.GC30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220925160.23638@east.gentwo.org>
 <20151022143349.GD30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Hello,

On Thu, Oct 22, 2015 at 09:41:11AM -0500, Christoph Lameter wrote:
> > If this is actually a legit busy-waiting cyclic dependency, just let
> > me know.
> 
> There is no dependency of the vmstat updater on anything.
> They can run anytime. If there is a dependency then its created by the
> kworker subsystem itself.

Sure, the other direction is from workqueue concurrency detection.  I
was asking whether a work item can busy-wait on vmstat_update work
item cuz that's what confuses workqueue.  Looking at the original
dump, the pool has two idle workers indicating that the workqueue
wasn't short of execution resources and it really looks like that work
item was live-locking the pool.  I'll go ahead and add WQ_IMMEDIATE.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
