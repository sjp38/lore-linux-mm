Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id DB4AA6B0261
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 06:09:29 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l126so33414226wml.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 03:09:29 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kx4si9047401wjb.92.2015.12.16.03.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 03:09:28 -0800 (PST)
Date: Wed, 16 Dec 2015 06:09:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151216110912.GA29816@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz>
 <20151214194258.GH28521@esperanza>
 <566F8781.80108@jp.fujitsu.com>
 <20151215145011.GA20355@cmpxchg.org>
 <5670D806.60408@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5670D806.60408@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 16, 2015 at 12:18:30PM +0900, Kamezawa Hiroyuki wrote:
> Hmm, my requests are
>  - set the same capabilities as mlock() to set swap.limit=0

Setting swap.max is already privileged operation.

>  - swap-full notification via vmpressure or something mechanism.

Why?

>  - OOM-Killer's available memory calculation may be corrupted, please check.

Vladimir updated mem_cgroup_get_limit().

>  - force swap-in at reducing swap.limit

Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
