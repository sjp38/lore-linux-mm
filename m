Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 814E7828E1
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 08:46:47 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so93935784lfe.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:46:47 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id c6si2478602wjq.184.2016.08.02.05.46.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 05:46:46 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id x83so30536810wma.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:46:46 -0700 (PDT)
Date: Tue, 2 Aug 2016 14:46:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] radix-tree: account nodes to memcg only if explicitly
 requested
Message-ID: <20160802124644.GL12403@dhcp22.suse.cz>
References: <1470057188-7864-1-git-send-email-vdavydov@virtuozzo.com>
 <20160802115111.GG12403@dhcp22.suse.cz>
 <20160802124220.GC13263@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160802124220.GC13263@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 02-08-16 15:42:20, Vladimir Davydov wrote:
> On Tue, Aug 02, 2016 at 01:51:12PM +0200, Michal Hocko wrote:
> > On Mon 01-08-16 16:13:08, Vladimir Davydov wrote:
> > > Radix trees may be used not only for storing page cache pages, so
> > > unconditionally accounting radix tree nodes to the current memory cgroup
> > > is bad: if a radix tree node is used for storing data shared among
> > > different cgroups we risk pinning dead memory cgroups forever. So let's
> > > only account radix tree nodes if it was explicitly requested by passing
> > > __GFP_ACCOUNT to INIT_RADIX_TREE. Currently, we only want to account
> > > page cache entries, so mark mapping->page_tree so.
> > > 
> > > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> > 
> > OK, the patch makes sense to me. Such a false sharing would be really
> > tedious to debug
> > 
> > Do we want to mark it for stable 4.6 to prevent from some pathological
> > issues. The patch is simple enough.
> 
> Makes sense, expecially taking into account that kmemcg is enabled by
> default now.
>
> I'll resend the patch for stable then.

Maybe Andrew just want's to mark it for stable with
Fixes: 58e698af4c63 ("radix-tree: account radix_tree_node to memory cgroup")
 Cc: stable # 4.6

> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks!
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
