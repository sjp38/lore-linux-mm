Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5236B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 05:21:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p42so3419147wrb.1
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 02:21:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p140si1775151wmb.175.2017.09.01.02.21.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 02:21:12 -0700 (PDT)
Date: Fri, 1 Sep 2017 11:21:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmstats: add counters for the page frag cache
Message-ID: <20170901092108.lb3jla2hpczjvrh5@dhcp22.suse.cz>
References: <1504222631-2635-1-git-send-email-kyeongdon.kim@lge.com>
 <50592560-af4d-302c-c0bc-1e854e35139d@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50592560-af4d-302c-c0bc-1e854e35139d@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Kyeongdon Kim <kyeongdon.kim@lge.com>, akpm@linux-foundation.org, sfr@canb.auug.org.au, ying.huang@intel.com, vbabka@suse.cz, hannes@cmpxchg.org, xieyisheng1@huawei.com, luto@kernel.org, shli@fb.com, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com, kemi.wang@intel.com, rientjes@google.com, bigeasy@linutronix.de, iamjoonsoo.kim@lge.com, bongkyu.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 01-09-17 12:12:36, Konstantin Khlebnikov wrote:
> IMHO that's too much counters.
> Per-node NR_FRAGMENT_PAGES should be enough for guessing what's going on.
> Perf probes provides enough features for furhter debugging.

I would tend to agree. Adding a counter based on a single debugging
instance sounds like an overkill to me. Counters should be pretty cheep
but this is way too specialized API to export to the userspace.

We have other interfaces to debug memory leaks like page_owner.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
