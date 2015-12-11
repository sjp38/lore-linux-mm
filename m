Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 917EF6B0255
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:25:36 -0500 (EST)
Received: by lfed137 with SMTP id d137so34474495lfe.3
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:25:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d12si11210215lfb.152.2015.12.11.11.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 11:25:35 -0800 (PST)
Date: Fri, 11 Dec 2015 14:25:22 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/7] mm: memcontrol: replace mem_cgroup_lruvec_online
 with mem_cgroup_online
Message-ID: <20151211192522.GB3773@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <a024e9b23584aa7bd3a74b7c7a69abd9f920812c.1449742561.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a024e9b23584aa7bd3a74b7c7a69abd9f920812c.1449742561.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 10, 2015 at 02:39:16PM +0300, Vladimir Davydov wrote:
> mem_cgroup_lruvec_online() takes lruvec, but it only needs memcg. Since
> get_scan_count(), which is the only user of this function, now possesses
> pointer to memcg, let's pass memcg directly to mem_cgroup_online()
> instead of picking it out of lruvec and rename the function accordingly.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
