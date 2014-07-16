Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3742A6B0069
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 14:37:37 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ho1so6616670wib.2
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 11:37:34 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id e4si4687842wij.16.2014.07.16.11.37.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 11:37:33 -0700 (PDT)
Date: Wed, 16 Jul 2014 14:37:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: memcg swap doesn't work in mmotm-2014-07-09-17-08?
Message-ID: <20140716183727.GB29639@cmpxchg.org>
References: <20140716181007.GA8524@nhori.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140716181007.GA8524@nhori.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jul 16, 2014 at 02:10:07PM -0400, Naoya Horiguchi wrote:
> Hi,
> 
> It seems that when a process in some memcg tries to allocate more than
> memcg.limit_in_bytes, oom happens instead of swaping out in
> mmotm-2014-07-09-17-08 (memcg.memsw.limit_in_bytes is large enough).
> It does work in v3.16-rc3, so I think latest patches changed something.
> I'm not familiar with memcg internally, so no idea about what caused it.
> Could you see the problem?

There are a lot of changes in memory and swap accounting, but I can
not reproduce what you are describing: I set up a cgroup with a 100MB
memory limit and an unlimited memory+swap, then start a task in there
that faults 200MB worth of anonymous pages.  The result is 100MB in
memory, 100MB in swap:

cache 0
rss 104267776
rss_huge 0
mapped_file 0
writeback 0
swap 105545728
pgpgin 26367
pgpgout 25950
pgfault 26695
pgmajfault 32
inactive_anon 52285440
active_anon 51982336
inactive_file 0
active_file 0
unevictable 0
hierarchical_memory_limit 104857600
hierarchical_memsw_limit 18446744073709551615

Filename                                Type            Size    Used    Priority
/swapfile                               file            8388604 109800  -1

Could you provide more detail on your configuration and test case?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
