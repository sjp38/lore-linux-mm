Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC486B026B
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 05:02:33 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v65-v6so4599447qka.23
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 02:02:33 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50090.outbound.protection.outlook.com. [40.107.5.90])
        by mx.google.com with ESMTPS id p79-v6si1419658qkl.154.2018.08.03.02.02.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Aug 2018 02:02:32 -0700 (PDT)
Subject: Re: [PATCH] mm: Move check for SHRINKER_NUMA_AWARE to
 do_shrink_slab()
References: <153320759911.18959.8842396230157677671.stgit@localhost.localdomain>
 <20180802134723.ecdd540c7c9338f98ee1a2c6@linux-foundation.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <47c34fad-5d11-53b0-4386-61be890163c5@virtuozzo.com>
Date: Fri, 3 Aug 2018 12:02:26 +0300
MIME-Version: 1.0
In-Reply-To: <20180802134723.ecdd540c7c9338f98ee1a2c6@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>
Cc: vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, willy@infradead.org, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org

On 02.08.2018 23:47, Andrew Morton wrote:
> On Thu, 02 Aug 2018 14:00:52 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> 
>> In case of shrink_slab_memcg() we do not zero nid, when shrinker
>> is not numa-aware. This is not a real problem, since currently
>> all memcg-aware shrinkers are numa-aware too (we have two:
>> super_block shrinker and workingset shrinker), but something may
>> change in the future.
> 
> Fair enough.
> 
>> (Andrew, this may be merged to mm-iterate-only-over-charged-shrinkers-during-memcg-shrink_slab)
> 
> It got a bit messy so I got lazy and queued it as a separate patch.
> 
> btw, I have a note that https://lkml.org/lkml/2018/7/7/32 was caused by
> this patch series.  Is that the case and do you know if this was
> addressed?

It's not related to the patchset. Bisect leads to:

commit c6aeb9d4c351 (HEAD, refs/bisect/bad)
Author: David Howells <dhowells@redhat.com>
Date:   Sun Jun 24 00:20:10 2018 +0100

kernfs, sysfs, cgroup, intel_rdt: Support fs_context

CC David.

David, please see reproducer at https://lkml.org/lkml/2018/7/7/32

Kirill
