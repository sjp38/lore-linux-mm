Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 03D146B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 20:05:40 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id vb8so4252509obc.32
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 17:05:40 -0700 (PDT)
Date: Tue, 24 Sep 2013 09:06:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 1/3] mm/zswap: bugfix: memory leak when re-swapon
Message-ID: <20130924000603.GF17725@bbox>
References: <000301ceb836$7b4a1340$71de39c0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000301ceb836$7b4a1340$71de39c0$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, d.j.shin@samsung.com, heesub.shin@samsung.com, kyungmin.park@samsung.com, hau.chen@samsung.com, bifeng.tong@samsung.com, rui.xie@samsung.com

On Mon, Sep 23, 2013 at 04:21:49PM +0800, Weijie Yang wrote:
> zswap_tree is not freed when swapoff, and it got re-kmalloc in swapon,
> so memory-leak occurs.
> 
> Modify: free memory of zswap_tree in zswap_frontswap_invalidate_area().
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> Reviewed-by: Bob Liu <bob.liu@oracle.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: stable@vger.kernel.org
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
