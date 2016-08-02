Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6B16B025E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 13:25:31 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so98810265lfe.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 10:25:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n76si4174167wmd.127.2016.08.02.10.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 10:25:29 -0700 (PDT)
Date: Tue, 2 Aug 2016 13:22:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 2/3] mm: memcontrol: fix memcg id ref counter on swap
 charge move
Message-ID: <20160802172250.GB6637@cmpxchg.org>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
 <b4cfbfd1533d709bb936a409276913c0934d20ba.1470149524.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b4cfbfd1533d709bb936a409276913c0934d20ba.1470149524.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 02, 2016 at 06:00:49PM +0300, Vladimir Davydov wrote:
> Since commit 73f576c04b941 swap entries do not pin memcg->css.refcnt
> directly. Instead, they pin memcg->id.ref. So we should adjust the
> reference counters accordingly when moving swap charges between cgroups.
> 
> Fixes: 73f576c04b941 ("mm: memcontrol: fix cgroup creation failure after many small jobs")
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: <stable@vger.kernel.org>	[3.19+]

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
