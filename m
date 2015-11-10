Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 047D76B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 02:49:31 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so226941336pab.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 23:49:30 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id oq7si3445982pab.129.2015.11.09.23.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 23:49:30 -0800 (PST)
Date: Tue, 10 Nov 2015 10:49:14 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 0/5] memcg/kmem: switch to white list policy
Message-ID: <20151110074914.GQ31308@esperanza>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <20151109140832.GE8916@dhcp22.suse.cz>
 <20151109182840.GJ31308@esperanza>
 <20151109185401.GB28507@mtj.duckdns.org>
 <20151109192747.GN31308@esperanza>
 <20151109193253.GC28507@mtj.duckdns.org>
 <20151109201218.GP31308@esperanza>
 <20151109203053.GD28507@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151109203053.GD28507@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Nov 09, 2015 at 03:30:53PM -0500, Tejun Heo wrote:
...
> Hmm.... can't we simply merge among !SLAB_ACCOUNT and SLAB_ACCOUNT
> kmem_caches within themselves?  I don't think we'd be losing anything
> by restricting merge at that level.  For anything to be tagged
> SLAB_ACCOUNT, it has to have a potential to grow enormous after all.

OK, I'll prepare v2 which will introduce SLAB_ACCOUNT and add it to
SLAB_MERGE_SAME. Let's see what slab maintainers think of it.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
