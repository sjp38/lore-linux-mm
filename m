Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 454026B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 03:14:31 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so3744270pdj.6
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 00:14:30 -0700 (PDT)
Date: Fri, 11 Oct 2013 16:14:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 3/3] mm/zswap: avoid unnecessary page scanning
Message-ID: <20131011071430.GD6847@bbox>
References: <000101ceb836$1a4c0ee0$4ee42ca0$%yang@samsung.com>
 <20131010125506.158c871becad30328abf6838@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131010125506.158c871becad30328abf6838@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, d.j.shin@samsung.com, heesub.shin@samsung.com, kyungmin.park@samsung.com, hau.chen@samsung.com, bifeng.tong@samsung.com, rui.xie@samsung.com

On Thu, Oct 10, 2013 at 12:55:06PM -0700, Andrew Morton wrote:
> On Mon, 23 Sep 2013 16:21:49 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:
> 
> > add SetPageReclaim before __swap_writepage so that page can be moved to the
> > tail of the inactive list, which can avoid unnecessary page scanning as this
> > page was reclaimed by swap subsystem before.
> > 
> > Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> > Reviewed-by: Bob Liu <bob.liu@oracle.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: stable@vger.kernel.org
> > Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 
> As a minor(?) performance tweak, I don't believe this is suitable for
> -stable backporting, so I took that out.  If you believe this was a
> mistake, please explain why.
> 

Yes. It's never stable stuff.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
