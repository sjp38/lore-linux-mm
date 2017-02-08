Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 16E7F6B0038
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 18:42:23 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f5so210234431pgi.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 15:42:23 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id i1si8382151pfb.292.2017.02.08.15.42.21
        for <linux-mm@kvack.org>;
        Wed, 08 Feb 2017 15:42:22 -0800 (PST)
Date: Thu, 9 Feb 2017 08:42:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm balloon: umount balloon_mnt when remove vb device
Message-ID: <20170208234215.GB16728@bbox>
References: <1486531318-35189-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
In-Reply-To: <1486531318-35189-1-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, aquini@redhat.com, koct9i@gmail.com, gi-oh.kim@profitbricks.com, vbabka@suse.cz, mhocko@kernel.org, mst@redhat.com, jasowang@redhat.com, guohanjun@huawei.com, qiuxishi@huawei.com, liubo95@huawei.com

On Wed, Feb 08, 2017 at 01:21:58PM +0800, Yisheng Xie wrote:
> With CONFIG_BALLOON_COMPACTION=y, it will mount balloon_mnt for
> balloon page migration when probe a virtio_balloon device, however
> do not unmount it when remove the device, fix it.
> 
> Fixes: b1123ea6d3b3 ("mm: balloon: use general non-lru movable page feature")
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>

Thanks for the fixing!

Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
