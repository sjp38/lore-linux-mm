Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E1B4D6B00AA
	for <linux-mm@kvack.org>; Sun, 15 Feb 2015 04:48:12 -0500 (EST)
Received: by pdev10 with SMTP id v10so28757817pde.7
        for <linux-mm@kvack.org>; Sun, 15 Feb 2015 01:48:12 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id os8si3276061pbb.209.2015.02.15.01.48.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Feb 2015 01:48:11 -0800 (PST)
Date: Sun, 15 Feb 2015 12:47:50 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
Message-ID: <20150215094750.GF28367@esperanza>
References: <cover.1422461573.git.vdavydov@parallels.com>
 <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
 <54E018A3.9000604@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <54E018A3.9000604@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Sat, Feb 14, 2015 at 10:55:15PM -0500, Sasha Levin wrote:
> It seems that this patch causes shrink to corrupt memory:

Yes, it does :-(

The fix can be found here: https://lkml.org/lkml/2015/2/11/347

It must have already been merged to the -mm tree:

On Thu, Feb 12, 2015 at 02:14:54PM -0800, akpm@linux-foundation.org wrote:
> 
> The patch titled
>      Subject: slub: kmem_cache_shrink: fix crash due to uninitialized discard list
> has been removed from the -mm tree.  Its filename was
>      slub-never-fail-to-shrink-cache-init-discard-list-after-freeing-slabs.patch
> 
> This patch was dropped because it was folded into slub-never-fail-to-shrink-cache.patch

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
