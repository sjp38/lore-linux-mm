Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0B21E6B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:34:51 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id x125so5897940pfb.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 06:34:51 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fk10si9840201pab.137.2016.01.27.06.34.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 06:34:50 -0800 (PST)
Date: Wed, 27 Jan 2016 17:34:41 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/5] mm: workingset: separate shadow unpacking and
 refault calculation
Message-ID: <20160127143440.GC9623@esperanza>
References: <1453842006-29265-1-git-send-email-hannes@cmpxchg.org>
 <1453842006-29265-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1453842006-29265-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 26, 2016 at 04:00:04PM -0500, Johannes Weiner wrote:
> Per-cgroup thrash detection will need to derive a live memcg from the
> eviction cookie, and doing that inside unpack_shadow() will get nasty
> with the reference handling spread over two functions.
> 
> In preparation, make unpack_shadow() clearly about extracting static
> data, and let workingset_refault() do all the higher-level handling.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
