Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EF8236B0005
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 04:29:38 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id o185so10966975pfb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 01:29:38 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id os9si8106271pab.169.2016.02.03.01.29.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 01:29:38 -0800 (PST)
Date: Wed, 3 Feb 2016 12:29:26 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/3] mm: remove unnecessary uses of lock_page_memcg()
Message-ID: <20160203092926.GG21016@esperanza>
References: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org>
 <1454109573-29235-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1454109573-29235-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Jan 29, 2016 at 06:19:33PM -0500, Johannes Weiner wrote:
> There are several users that nest lock_page_memcg() inside lock_page()
> to prevent page->mem_cgroup from changing. But the page lock prevents
> pages from moving between cgroups, so that is unnecessary overhead.
> 
> Remove lock_page_memcg() in contexts with locked contexts and fix the
> debug code in the page stat functions to be okay with the page lock.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
