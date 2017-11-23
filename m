Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 414076B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 09:38:05 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id g104so10166090otg.8
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:38:05 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n79si8536271ota.204.2017.11.23.06.38.04
        for <linux-mm@kvack.org>;
        Thu, 23 Nov 2017 06:38:04 -0800 (PST)
Date: Thu, 23 Nov 2017 14:38:00 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2] kmemleak: add scheduling point to kmemleak_scan
Message-ID: <20171123143759.ja2qmsqbjxh4u36e@armageddon.cambridge.arm.com>
References: <1511439788-20099-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511439788-20099-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 23, 2017 at 08:23:08PM +0800, Yisheng Xie wrote:
> kmemleak_scan will scan struct page for each node and it can be really
> large and resulting in a soft lockup. We have seen a soft lockup when do
> scan while compile kernel:
> 
>  [  220.561051] watchdog: BUG: soft lockup - CPU#53 stuck for 22s! [bash:10287]
>  [...]
>  [  220.753837] Call Trace:
>  [  220.756296]  kmemleak_scan+0x21a/0x4c0
>  [  220.760034]  kmemleak_write+0x312/0x350
>  [  220.763866]  ? do_wp_page+0x147/0x4c0
>  [  220.767521]  full_proxy_write+0x5a/0xa0
>  [  220.771351]  __vfs_write+0x33/0x150
>  [  220.774833]  ? __inode_security_revalidate+0x4c/0x60
>  [  220.779782]  ? selinux_file_permission+0xda/0x130
>  [  220.784479]  ? _cond_resched+0x15/0x30
>  [  220.788221]  vfs_write+0xad/0x1a0
>  [  220.791529]  SyS_write+0x52/0xc0
>  [  220.794758]  do_syscall_64+0x61/0x1a0
>  [  220.798411]  entry_SYSCALL64_slow_path+0x25/0x25
> 
> Fix this by adding cond_resched every MAX_SCAN_SIZE.
> 
> Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
