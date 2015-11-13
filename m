Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8A86B0264
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 10:59:36 -0500 (EST)
Received: by pasz6 with SMTP id z6so107271439pas.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 07:59:36 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id j11si28193916pbq.57.2015.11.13.07.59.35
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 07:59:35 -0800 (PST)
Date: Fri, 13 Nov 2015 10:59:30 -0500 (EST)
Message-Id: <20151113.105930.1605973371773225963.davem@davemloft.net>
Subject: Re: [PATCH 01/14] mm: memcontrol: export root_mem_cgroup
From: David Miller <davem@davemloft.net>
In-Reply-To: <1447371693-25143-2-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
	<1447371693-25143-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, mhocko@suse.cz, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu, 12 Nov 2015 18:41:20 -0500

> A later patch will need this symbol in files other than memcontrol.c,
> so export it now and replace mem_cgroup_root_css at the same time.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
