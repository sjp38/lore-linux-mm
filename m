Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDD4B6B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 04:15:35 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n69so430122903ion.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 01:15:35 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50135.outbound.protection.outlook.com. [40.107.5.135])
        by mx.google.com with ESMTPS id 75si1558771oia.21.2016.08.03.01.15.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Aug 2016 01:15:34 -0700 (PDT)
Date: Wed, 3 Aug 2016 11:15:25 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH stable 4.6+] radix-tree: account nodes to memcg only if
 explicitly requested
Message-ID: <20160803081525.GF13263@esperanza>
References: <1470141934-4568-1-git-send-email-vdavydov@virtuozzo.com>
 <20160803035139.GB31125@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160803035139.GB31125@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 03, 2016 at 05:51:39AM +0200, Greg KH wrote:
> On Tue, Aug 02, 2016 at 03:45:34PM +0300, Vladimir Davydov wrote:
> > Radix trees may be used not only for storing page cache pages, so
> > unconditionally accounting radix tree nodes to the current memory cgroup
> > is bad: if a radix tree node is used for storing data shared among
> > different cgroups we risk pinning dead memory cgroups forever. So let's
> > only account radix tree nodes if it was explicitly requested by passing
> > __GFP_ACCOUNT to INIT_RADIX_TREE. Currently, we only want to account
> > page cache entries, so mark mapping->page_tree so.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > Cc: <stable@vger.kernel.org>  [4.6+]
> > ---
> >  fs/inode.c       |  2 +-
> >  lib/radix-tree.c | 14 ++++++++++----
> >  2 files changed, 11 insertions(+), 5 deletions(-)
> 
> Is this patch in Linus's tree already?

Not yet, it should only be added to 4.8, so I shouldn't have sent this
(didn't know how patches are submitted to stable). Please ignore.

> 
> confused,

Sorry for the noise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
