Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 36D6C6B0033
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 21:03:31 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so3859825pbb.6
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 18:03:30 -0700 (PDT)
Date: Tue, 24 Sep 2013 10:03:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 3/3] mm/zswap: avoid unnecessary page scanning
Message-ID: <20130924010354.GH17725@bbox>
References: <000101ceb836$1a4c0ee0$4ee42ca0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000101ceb836$1a4c0ee0$4ee42ca0$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, d.j.shin@samsung.com, heesub.shin@samsung.com, kyungmin.park@samsung.com, hau.chen@samsung.com, bifeng.tong@samsung.com, rui.xie@samsung.com

On Mon, Sep 23, 2013 at 04:21:49PM +0800, Weijie Yang wrote:
> add SetPageReclaim before __swap_writepage so that page can be moved to the
> tail of the inactive list, which can avoid unnecessary page scanning as this
> page was reclaimed by swap subsystem before.
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
