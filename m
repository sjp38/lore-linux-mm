Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1186B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 09:18:47 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id yy13so99627447pab.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 06:18:47 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id l84si2203608pfb.158.2016.02.02.06.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 06:18:46 -0800 (PST)
Date: Tue, 2 Feb 2016 17:18:25 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2 1/5] mm: memcontrol: generalize locking for the
 page->mem_cgroup binding
Message-ID: <20160202141825.GB21016@esperanza>
References: <1454090047-1790-1-git-send-email-hannes@cmpxchg.org>
 <1454090047-1790-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1454090047-1790-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Jan 29, 2016 at 12:54:03PM -0500, Johannes Weiner wrote:
> So far the only sites that needed to exclude charge migration to
> stabilize page->mem_cgroup have been per-cgroup page statistics, hence
> the name mem_cgroup_begin_page_stat(). But per-cgroup thrash detection
> will add another site that needs to ensure page->mem_cgroup lifetime.
> 
> Rename these locking functions to the more generic lock_page_memcg()
> and unlock_page_memcg(). Since charge migration is a cgroup1 feature
> only, we might be able to delete it at some point, and these now easy
> to identify locking sites along with it.
> 
> Suggested-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
