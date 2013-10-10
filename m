Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 24D3C6B004D
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 15:55:10 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so3271349pab.10
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:55:09 -0700 (PDT)
Date: Thu, 10 Oct 2013 12:55:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 3/3] mm/zswap: avoid unnecessary page scanning
Message-Id: <20131010125506.158c871becad30328abf6838@linux-foundation.org>
In-Reply-To: <000101ceb836$1a4c0ee0$4ee42ca0$%yang@samsung.com>
References: <000101ceb836$1a4c0ee0$4ee42ca0$%yang@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, minchan@kernel.org, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, d.j.shin@samsung.com, heesub.shin@samsung.com, kyungmin.park@samsung.com, hau.chen@samsung.com, bifeng.tong@samsung.com, rui.xie@samsung.com

On Mon, 23 Sep 2013 16:21:49 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:

> add SetPageReclaim before __swap_writepage so that page can be moved to the
> tail of the inactive list, which can avoid unnecessary page scanning as this
> page was reclaimed by swap subsystem before.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> Reviewed-by: Bob Liu <bob.liu@oracle.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: stable@vger.kernel.org
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

As a minor(?) performance tweak, I don't believe this is suitable for
-stable backporting, so I took that out.  If you believe this was a
mistake, please explain why.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
