Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f54.google.com (mail-lf0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCF06B0005
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 10:39:41 -0500 (EST)
Received: by mail-lf0-f54.google.com with SMTP id z124so70187015lfa.3
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 07:39:41 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id k8si11093502lbj.101.2015.12.18.07.39.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 07:39:39 -0800 (PST)
Date: Fri, 18 Dec 2015 18:39:24 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2 7/7] Documentation: cgroup: add
 memory.swap.{current,max} description
Message-ID: <20151218153924.GT28521@esperanza>
References: <cover.1450352791.git.vdavydov@virtuozzo.com>
 <dbb4bf6bc071997982855c8f7d403c22cea60ffb.1450352792.git.vdavydov@virtuozzo.com>
 <567374AB.3010101@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <567374AB.3010101@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Dec 18, 2015 at 11:51:23AM +0900, Kamezawa Hiroyuki wrote:
...
> Could you give here a hint how to calculate amount of swapcache,
> counted both in memory.current and swap.current ?

Currently it's impossible, but once memory.stat has settled in the
unified hierarchy, it might be worth adding a stat counter for such
pages (equivalent to SwapCached in the global /proc/meminfo).

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
