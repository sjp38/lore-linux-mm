Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 34081280002
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 09:30:18 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id r10so1234530pdi.17
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 06:30:17 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id z6si6158449pdo.4.2014.11.06.06.30.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 06:30:16 -0800 (PST)
Date: Thu, 6 Nov 2014 17:30:09 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [mmotm:master 143/283] mm/slab.c:3260:4: error: implicit
 declaration of function 'slab_free'
Message-ID: <20141106143008.GE4839@esperanza>
References: <201411060959.OFpcU713%fengguang.wu@intel.com>
 <20141106090845.GA17744@dhcp22.suse.cz>
 <20141106092849.GC4839@esperanza>
 <20141106140514.GG7202@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20141106140514.GG7202@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Nov 06, 2014 at 03:05:15PM +0100, Michal Hocko wrote:
> > BTW what do you think about the whole patch set that introduced it -
> > https://lkml.org/lkml/2014/11/3/781 - w/o diving deeply into details,
> > just by looking at the general idea described in the cover letter?
> 
> The series is still stuck in my inbox and I plan to review your shrinker
> code first. I hope to get to it ASAP but not sooner than Monday as I
> will be off until Sunday.

OK, then I think we'd better drop it and concentrate on the shrinkers
first - I'll resend the shrinkers patch set on Monday then.

Andrew, could you please revert the following patches:

memcg-do-not-destroy-kmem-caches-on-css-offline
slab-charge-slab-pages-to-the-current-memory-cgroup
memcg-decouple-per-memcg-kmem-cache-from-the-owner-memcg
memcg-zap-memcg_unregister_cache
memcg-free-kmem-cache-id-on-css-offline
memcg-introduce-memcg_kmem_should_charge-helper
slab-recharge-slab-pages-to-the-allocating-memory-cgroup

memcg-zap-kmem_account_flags
memcg-turn-memcg_kmem_skip_account-into-a-bit-field
memcg-only-check-memcg_kmem_skip_account-in-__memcg_kmem_get_cache

[The last three patches are not the part of this patch set, but they
depend on it, so I will resend them later]

Terribly sorry for the noise.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
