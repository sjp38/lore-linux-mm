Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 952BC828E1
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 08:42:31 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id x130so4525670ite.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:42:31 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00121.outbound.protection.outlook.com. [40.107.0.121])
        by mx.google.com with ESMTPS id r12si1427210otb.267.2016.08.02.05.42.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 05:42:30 -0700 (PDT)
Date: Tue, 2 Aug 2016 15:42:20 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] radix-tree: account nodes to memcg only if explicitly
 requested
Message-ID: <20160802124220.GC13263@esperanza>
References: <1470057188-7864-1-git-send-email-vdavydov@virtuozzo.com>
 <20160802115111.GG12403@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160802115111.GG12403@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 02, 2016 at 01:51:12PM +0200, Michal Hocko wrote:
> On Mon 01-08-16 16:13:08, Vladimir Davydov wrote:
> > Radix trees may be used not only for storing page cache pages, so
> > unconditionally accounting radix tree nodes to the current memory cgroup
> > is bad: if a radix tree node is used for storing data shared among
> > different cgroups we risk pinning dead memory cgroups forever. So let's
> > only account radix tree nodes if it was explicitly requested by passing
> > __GFP_ACCOUNT to INIT_RADIX_TREE. Currently, we only want to account
> > page cache entries, so mark mapping->page_tree so.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> OK, the patch makes sense to me. Such a false sharing would be really
> tedious to debug
> 
> Do we want to mark it for stable 4.6 to prevent from some pathological
> issues. The patch is simple enough.

Makes sense, expecially taking into account that kmemcg is enabled by
default now. I'll resend the patch for stable then.

> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
