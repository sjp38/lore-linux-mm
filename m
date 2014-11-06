Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1CFF36B0092
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 04:29:05 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id bj1so924584pad.3
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 01:29:04 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id e6si5403635pat.89.2014.11.06.01.29.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 01:29:03 -0800 (PST)
Date: Thu, 6 Nov 2014 12:28:49 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [mmotm:master 143/283] mm/slab.c:3260:4: error: implicit
 declaration of function 'slab_free'
Message-ID: <20141106092849.GC4839@esperanza>
References: <201411060959.OFpcU713%fengguang.wu@intel.com>
 <20141106090845.GA17744@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20141106090845.GA17744@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Michal,

On Thu, Nov 06, 2014 at 10:08:45AM +0100, Michal Hocko wrote:
> I have encountered the same error as well. We need to move the forward
> declaration up outside of CONFIG_NUMA:

Yes, that's my fault, I'm sorry. Thank you for fixing this.

BTW what do you think about the whole patch set that introduced it -
https://lkml.org/lkml/2014/11/3/781 - w/o diving deeply into details,
just by looking at the general idea described in the cover letter?

Does it look like acceptable to you that a cgroup can get a cache with
some objects left from the previous user? Or do you think it's better to
give each cgroup its own cache as it used to be before and introduce
cache auto-destruction somehow (that would be tricky though, but
possible)? Or perhaps it'd be better to get rid of per-memcg caches
altogether and share the same kmem cache for all kmem allocations
keeping a pointer to the owner memcg in each kmem object?

I'd really appreciate if you or Johannes could share your thoughts on
it, because I'm afraid I can do something everybody will regret about in
the future...

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
