Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5DAE36B0038
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 12:00:16 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q108so1886864qgd.33
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 09:00:15 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id s10si1714717qcf.24.2014.09.21.09.00.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 21 Sep 2014 09:00:15 -0700 (PDT)
Received: by mail-qg0-f48.google.com with SMTP id z107so1861061qgd.21
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 09:00:15 -0700 (PDT)
Date: Sun, 21 Sep 2014 12:00:12 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -mm 00/14] Per memcg slab shrinkers
Message-ID: <20140921160012.GA996@mtj.dyndns.org>
References: <cover.1411301245.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1411301245.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

Hello,

On Sun, Sep 21, 2014 at 07:14:32PM +0400, Vladimir Davydov wrote:
...
> list. This is really important, because this allows us to release
> memcg_cache_id used for indexing in per-memcg arrays. If we don't do
> this, the arrays will grow uncontrollably, which is really bad. Note, in
> comparison to user memory reparenting, which Johannes is going to get

I don't know the code well and haven't read the patches and could
easilya be completely off the mark, but, if the size of slab array is
the only issue, wouldn't it be easier to separate that part out?  The
indexing is only necessary for allocating new items, right?  Can't
that part be shutdown and the index freed on offline and the rest stay
till release?  Things like reparenting tends to add fair amount of
complexity and hot path overheads which aren't necessary otherwise.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
