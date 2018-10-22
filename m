Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60AE16B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 04:33:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k9-v6so6412148edb.16
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 01:33:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x49-v6si2904157eda.325.2018.10.22.01.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 01:33:24 -0700 (PDT)
Date: Mon, 22 Oct 2018 10:33:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory management issue in 4.18.15
Message-ID: <20181022083322.GE32333@dhcp22.suse.cz>
References: <CADa=ObrwYaoNFn0x06mvv5W1F9oVccT5qjGM8qFBGNPoNuMUNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADa=ObrwYaoNFn0x06mvv5W1F9oVccT5qjGM8qFBGNPoNuMUNw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Spock <dairinin@gmail.com>
Cc: linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <alexander.levin@microsoft.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org

Cc som more people.

I am wondering why 172b06c32b94 ("mm: slowly shrink slabs with a
relatively small number of objects") has been backported to the stable
tree when not marked that way. Put that aside it seems likely that the
upstream kernel will have the same issue I suspect. Roman, could you
have a look please?

On Sat 20-10-18 14:41:40, Spock wrote:
> Hello,
> 
> I have a workload, which creates lots of cache pages. Before 4.18.15,
> the behavior was very stable: pagecache is constantly growing until it
> consumes all the free memory, and then kswapd is balancing it around
> low watermark. After 4.18.15, once in a while khugepaged is waking up
> and reclaims almost all the pages from pagecache, so there is always
> around 2G of 8G unused. THP is enabled only for madvise case and are
> not used.
> 
> The exact change that leads to current behavior is
> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?h=linux-4.18.y&id=62aad93f09c1952ede86405894df1b22012fd5ab

-- 
Michal Hocko
SUSE Labs
