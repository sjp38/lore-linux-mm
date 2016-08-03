Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 55ECF6B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 23:59:48 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so333583690pac.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 20:59:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ux1si6575059pac.84.2016.08.02.20.59.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 20:59:47 -0700 (PDT)
Date: Wed, 3 Aug 2016 05:51:39 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH stable 4.6+] radix-tree: account nodes to memcg only if
 explicitly requested
Message-ID: <20160803035139.GB31125@kroah.com>
References: <1470141934-4568-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470141934-4568-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 02, 2016 at 03:45:34PM +0300, Vladimir Davydov wrote:
> Radix trees may be used not only for storing page cache pages, so
> unconditionally accounting radix tree nodes to the current memory cgroup
> is bad: if a radix tree node is used for storing data shared among
> different cgroups we risk pinning dead memory cgroups forever. So let's
> only account radix tree nodes if it was explicitly requested by passing
> __GFP_ACCOUNT to INIT_RADIX_TREE. Currently, we only want to account
> page cache entries, so mark mapping->page_tree so.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: <stable@vger.kernel.org>  [4.6+]
> ---
>  fs/inode.c       |  2 +-
>  lib/radix-tree.c | 14 ++++++++++----
>  2 files changed, 11 insertions(+), 5 deletions(-)

Is this patch in Linus's tree already?

confused,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
