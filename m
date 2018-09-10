Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF7AA8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:27:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 57-v6so7305072edt.15
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 07:27:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p15-v6si698525edk.239.2018.09.10.07.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 07:27:51 -0700 (PDT)
Date: Mon, 10 Sep 2018 16:27:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Use BUG_ON directly instead of a if condition
 followed by BUG
Message-ID: <20180910142748.GK10951@dhcp22.suse.cz>
References: <1536588197-22115-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536588197-22115-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, dan.j.williams@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 10-09-18 22:03:17, zhong jiang wrote:
> The if condition can be removed if we use BUG_ON directly.
> The issule is detected with the help of Coccinelle.

typo here

Is this really worth changing? If anything I would really love to see
the BUG_ON going away rather than make a cosmetic changes to it.

> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/memory_hotplug.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 38d94b7..280b26c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1888,8 +1888,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
>  	 */
>  	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
>  				check_memblock_offlined_cb);
> -	if (ret)
> -		BUG();
> +	BUG(ret);
>  
>  	/* remove memmap entry */
>  	firmware_map_remove(start, start + size, "System RAM");
> -- 
> 1.7.12.4
> 

-- 
Michal Hocko
SUSE Labs
