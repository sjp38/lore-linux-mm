Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id C8E636B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 14:42:36 -0400 (EDT)
Received: by igdg1 with SMTP id g1so772402igd.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:42:36 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id j1si76679igx.94.2015.10.22.11.42.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 11:42:36 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so93732629pad.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:42:35 -0700 (PDT)
Date: Fri, 23 Oct 2015 03:42:26 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151022184226.GA19289@mtj.duckdns.org>
References: <20151021145505.GE8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022150623.GE26854@dhcp22.suse.cz>
 <20151022151528.GG30579@mtj.duckdns.org>
 <20151022153559.GF26854@dhcp22.suse.cz>
 <20151022153703.GA3899@mtj.duckdns.org>
 <20151022154922.GG26854@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022154922.GG26854@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Thu, Oct 22, 2015 at 05:49:22PM +0200, Michal Hocko wrote:
> I am confused. What makes rescuer to not run? Nothing seems to be
> hogging CPUs, we are just out of workers which are loopin in the
> allocator but that is preemptible context.

It's concurrency management.  Workqueue thinks that the pool is making
positive forward progress and doesn't schedule anything else for
execution while that work item is burning cpu cycles.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
