Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f42.google.com (mail-lf0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id A65F56B0257
	for <linux-mm@kvack.org>; Sat, 14 Nov 2015 07:17:57 -0500 (EST)
Received: by lfs39 with SMTP id 39so65692135lfs.3
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 04:17:56 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id k185si9297683lfd.28.2015.11.14.04.17.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Nov 2015 04:17:55 -0800 (PST)
Date: Sat, 14 Nov 2015 15:17:37 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 01/14] mm: memcontrol: export root_mem_cgroup
Message-ID: <20151114121737.GG31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1447371693-25143-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 12, 2015 at 06:41:20PM -0500, Johannes Weiner wrote:
> A later patch will need this symbol in files other than memcontrol.c,
> so export it now and replace mem_cgroup_root_css at the same time.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
