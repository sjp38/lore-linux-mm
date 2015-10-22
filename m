Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id A8C9082F66
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:37:11 -0400 (EDT)
Received: by igdg1 with SMTP id g1so111738979igd.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:37:11 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id j87si11786313iod.148.2015.10.22.08.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 08:37:11 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so89803298pad.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:37:10 -0700 (PDT)
Date: Fri, 23 Oct 2015 00:37:03 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151022153703.GA3899@mtj.duckdns.org>
References: <20151021143337.GD8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org>
 <20151021145505.GE8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022150623.GE26854@dhcp22.suse.cz>
 <20151022151528.GG30579@mtj.duckdns.org>
 <20151022153559.GF26854@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022153559.GF26854@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Thu, Oct 22, 2015 at 05:35:59PM +0200, Michal Hocko wrote:
> But that shouldn't happen because the allocation path does cond_resched
> even when nothing is really reclaimable (e.g. wait_iff_congested from
> __alloc_pages_slowpath).

cond_resched() isn't enough.  The work item should go !RUNNING, not
just yielding.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
