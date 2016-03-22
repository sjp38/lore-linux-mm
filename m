Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF686B007E
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 22:21:13 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id nk17so85397558igb.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 19:21:13 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m5si12589679igr.50.2016.03.21.19.21.11
        for <linux-mm@kvack.org>;
        Mon, 21 Mar 2016 19:21:12 -0700 (PDT)
Date: Tue, 22 Mar 2016 11:19:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 14/18] mm/balloon: use general movable page feature
 into balloon
Message-ID: <20160322021927.GA30070@bbox>
References: <1458541867-27380-15-git-send-email-minchan@kernel.org>
 <201603211608.zNLWtmQ0%fengguang.wu@intel.com>
MIME-Version: 1.0
In-Reply-To: <201603211608.zNLWtmQ0%fengguang.wu@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Gioh Kim <gurugio@hanmail.net>

On Mon, Mar 21, 2016 at 04:29:55PM +0800, kbuild test robot wrote:
> Hi Minchan,
> 
> [auto build test ERROR on next-20160318]
> [cannot apply to v4.5-rc7 v4.5-rc6 v4.5-rc5 v4.5]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Minchan-Kim/Support-non-lru-page-migration/20160321-143339
> config: x86_64-randconfig-x000-201612 (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    drivers/virtio/virtio_balloon.c: In function 'virtballoon_probe':
> >> drivers/virtio/virtio_balloon.c:578:15: error: 'balloon_mnt' undeclared (first use in this function)
>      kern_unmount(balloon_mnt);
>                   ^
>    drivers/virtio/virtio_balloon.c:578:15: note: each undeclared identifier is reported only once for each function it appears in
> >> drivers/virtio/virtio_balloon.c:579:1: warning: label 'out_free_vb' defined but not used [-Wunused-label]
>     out_free_vb:
>     ^
> 
> vim +/balloon_mnt +578 drivers/virtio/virtio_balloon.c
> 
>    572	
>    573	out_oom_notify:
>    574		vdev->config->del_vqs(vdev);
>    575	out_unmount:
>    576		if (vb->vb_dev_info.inode)
>    577			iput(vb->vb_dev_info.inode);
>  > 578		kern_unmount(balloon_mnt);
>  > 579	out_free_vb:
>    580		kfree(vb);
>    581	out:
>    582		return err;
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation


Thanks, kbuild.
Fixed.
