Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9B138E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 14:32:50 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id x64so4471915ywc.6
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 11:32:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l70sor21206704ybf.200.2019.01.09.11.32.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 11:32:49 -0800 (PST)
Date: Wed, 9 Jan 2019 14:32:47 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC v3 PATCH 0/5] mm: memcontrol: do memory reclaim when
 offlining
Message-ID: <20190109193247.GA16319@cmpxchg.org>
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, shakeelb@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 10, 2019 at 03:14:40AM +0800, Yang Shi wrote:
> 
> We have some usecases which create and remove memcgs very frequently,
> and the tasks in the memcg may just access the files which are unlikely
> accessed by anyone else.  So, we prefer force_empty the memcg before
> rmdir'ing it to reclaim the page cache so that they don't get
> accumulated to incur unnecessary memory pressure.  Since the memory
> pressure may incur direct reclaim to harm some latency sensitive
> applications.

We have kswapd for exactly this purpose. Can you lay out more details
on why that is not good enough, especially in conjunction with tuning
the watermark_scale_factor etc.?

We've been pretty adamant that users shouldn't use drop_caches for
performance for example, and that the need to do this usually is
indicative of a problem or suboptimal tuning in the VM subsystem.

How is this different?
