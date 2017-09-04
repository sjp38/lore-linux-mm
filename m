Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 821736B0313
	for <linux-mm@kvack.org>; Sun,  3 Sep 2017 21:36:49 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 4so15684594pgi.5
        for <linux-mm@kvack.org>; Sun, 03 Sep 2017 18:36:49 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id e8si4150366pfc.41.2017.09.03.18.36.47
        for <linux-mm@kvack.org>;
        Sun, 03 Sep 2017 18:36:48 -0700 (PDT)
Subject: Re: Re: [PATCH] mm/vmstats: add counters for the page frag cache
References: <1504222631-2635-1-git-send-email-kyeongdon.kim@lge.com>
 <20170901092108.lb3jla2hpczjvrh5@dhcp22.suse.cz>
From: Kyeongdon Kim <kyeongdon.kim@lge.com>
Message-ID: <bdd6088e-0318-a90a-1e22-e7d668c7aec4@lge.com>
Date: Mon, 4 Sep 2017 10:36:42 +0900
MIME-Version: 1.0
In-Reply-To: <20170901092108.lb3jla2hpczjvrh5@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: akpm@linux-foundation.org, sfr@canb.auug.org.au, ying.huang@intel.com, vbabka@suse.cz, hannes@cmpxchg.org, xieyisheng1@huawei.com, luto@kernel.org, shli@fb.com, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com, kemi.wang@intel.com, rientjes@google.com, bigeasy@linutronix.de, iamjoonsoo.kim@lge.com, bongkyu.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Thanks for your reply,

We already used other i/f like page_owner and kmemleak to resolve memory 
leakage issue.
But, page_owner can only for guess but cannot find intuitively memory 
usage regarding page_frag_cache.
And kmemleak cannot use (because of calling directly 
__alloc_pages_nodemask()).

Additionally, some embedded linux like Android or something..
is not able to always use kmemleak & page_owner because of runtime 
performance deterioration.
However, the root cause of this memory issue is from net device like 
wireless.
In short, should always use wireless on device but, cannot use those 
memory debug tools.

That's why those counters need..
and for much cheaper I can remove pgfrag_alloc_calls and pgfrag_free_calls.

Thanks,
Kyeongdon Kim

On 2017-09-01 i??i?? 6:21, Michal Hocko wrote:
> On Fri 01-09-17 12:12:36, Konstantin Khlebnikov wrote:
> > IMHO that's too much counters.
> > Per-node NR_FRAGMENT_PAGES should be enough for guessing what's 
> going on.
> > Perf probes provides enough features for furhter debugging.
>
> I would tend to agree. Adding a counter based on a single debugging
> instance sounds like an overkill to me. Counters should be pretty cheep
> but this is way too specialized API to export to the userspace.
>
> We have other interfaces to debug memory leaks like page_owner.
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
