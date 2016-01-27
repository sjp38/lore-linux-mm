Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 28C3D6B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:53:03 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l66so17146958wml.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:53:03 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kj7si10135223wjb.87.2016.01.27.10.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 10:53:02 -0800 (PST)
Date: Wed, 27 Jan 2016 13:52:18 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmscan: do not clear SHRINKER_NUMA_AWARE if
 nr_node_ids == 1
Message-ID: <20160127185218.GB31360@cmpxchg.org>
References: <1453913242-26722-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453913242-26722-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 27, 2016 at 07:47:22PM +0300, Vladimir Davydov wrote:
> Currently, on shrinker registration we clear SHRINKER_NUMA_AWARE if
> there's the only NUMA node present. The comment states that this will
> allow us to save some small loop time later. It used to be true when
> this code was added (see commit 1d3d4437eae1b ("vmscan: per-node
> deferred work")), but since commit 6b4f7799c6a57 ("mm: vmscan: invoke
> slab shrinkers from shrink_zone()") it doesn't make any difference.
> Anyway, running on non-NUMA machine shouldn't make a shrinker NUMA
> unaware, so zap this hunk.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
