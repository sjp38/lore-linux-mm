Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id E33B36B0255
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 07:42:35 -0500 (EST)
Received: by mail-yk0-f173.google.com with SMTP id 1so22170684ykg.3
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:42:35 -0800 (PST)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id c1si1099993ywe.134.2016.03.04.04.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 04:42:35 -0800 (PST)
Received: by mail-yw0-x241.google.com with SMTP id s188so2854936ywe.2
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 04:42:35 -0800 (PST)
Date: Fri, 4 Mar 2016 07:42:33 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] mm: Convert printk(KERN_<LEVEL> to pr_<level>
Message-ID: <20160304124233.GC13868@htj.duckdns.org>
References: <cover.1457047399.git.joe@perches.com>
 <c12953a0177b3fd04945b042cb10495130c08bec.1457047399.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c12953a0177b3fd04945b042cb10495130c08bec.1457047399.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Thu, Mar 03, 2016 at 03:25:33PM -0800, Joe Perches wrote:
> Most of the mm subsystem uses pr_<level> so make it consistent.
> 
> Miscellanea:
> 
> o Realign arguments
> o Add missing newline to format
> o kmemleak-test.c has a "kmemleak: " prefix added to the
>   "Kmemleak testing" logging message via pr_fmt
> 
> Signed-off-by: Joe Perches <joe@perches.com>

For percpu,

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
