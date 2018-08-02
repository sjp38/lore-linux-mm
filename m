Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6158C6B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 16:47:26 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j15-v6so2146854pff.12
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 13:47:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z5-v6si2546997pgn.105.2018.08.02.13.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 13:47:24 -0700 (PDT)
Date: Thu, 2 Aug 2018 13:47:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Move check for SHRINKER_NUMA_AWARE to
 do_shrink_slab()
Message-Id: <20180802134723.ecdd540c7c9338f98ee1a2c6@linux-foundation.org>
In-Reply-To: <153320759911.18959.8842396230157677671.stgit@localhost.localdomain>
References: <153320759911.18959.8842396230157677671.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, willy@infradead.org, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 02 Aug 2018 14:00:52 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> In case of shrink_slab_memcg() we do not zero nid, when shrinker
> is not numa-aware. This is not a real problem, since currently
> all memcg-aware shrinkers are numa-aware too (we have two:
> super_block shrinker and workingset shrinker), but something may
> change in the future.

Fair enough.

> (Andrew, this may be merged to mm-iterate-only-over-charged-shrinkers-during-memcg-shrink_slab)

It got a bit messy so I got lazy and queued it as a separate patch.

btw, I have a note that https://lkml.org/lkml/2018/7/7/32 was caused by
this patch series.  Is that the case and do you know if this was
addressed?
