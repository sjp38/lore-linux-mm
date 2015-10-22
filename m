Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED9D82F64
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:49:25 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so126588404wic.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:49:25 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id fx2si44416616wic.38.2015.10.22.08.49.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 08:49:24 -0700 (PDT)
Received: by wicfx6 with SMTP id fx6so142008718wic.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:49:24 -0700 (PDT)
Date: Thu, 22 Oct 2015 17:49:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151022154922.GG26854@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org>
 <20151021145505.GE8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022150623.GE26854@dhcp22.suse.cz>
 <20151022151528.GG30579@mtj.duckdns.org>
 <20151022153559.GF26854@dhcp22.suse.cz>
 <20151022153703.GA3899@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022153703.GA3899@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Fri 23-10-15 00:37:03, Tejun Heo wrote:
> On Thu, Oct 22, 2015 at 05:35:59PM +0200, Michal Hocko wrote:
> > But that shouldn't happen because the allocation path does cond_resched
> > even when nothing is really reclaimable (e.g. wait_iff_congested from
> > __alloc_pages_slowpath).
> 
> cond_resched() isn't enough.  The work item should go !RUNNING, not
> just yielding.

I am confused. What makes rescuer to not run? Nothing seems to be
hogging CPUs, we are just out of workers which are loopin in the
allocator but that is preemptible context.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
