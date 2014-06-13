Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id E0C8C6B0038
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 11:10:18 -0400 (EDT)
Received: by mail-yh0-f46.google.com with SMTP id c41so2205193yho.33
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:10:18 -0700 (PDT)
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com. [15.193.200.69])
        by mx.google.com with ESMTPS id w30si6225083yhi.22.2014.06.13.08.10.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 08:10:18 -0700 (PDT)
Message-ID: <1402671668.7963.16.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 RESEND 2/2] mem-hotplug: Introduce MMOP_OFFLINE to
 replace the hard coding -1.
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 13 Jun 2014 09:01:08 -0600
In-Reply-To: <1402032829-18455-1-git-send-email-tangchen@cn.fujitsu.com>
References: <20140606051535.GC4454@G08FNSTD100614.fnst.cn.fujitsu.com>
	 <1402032829-18455-1-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: hutao@cn.fujitsu.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, tj@kernel.org, hpa@zytor.com, mingo@elte.hu, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2014-06-06 at 13:33 +0800, Tang Chen wrote:
> In store_mem_state(), we have:
> ......
>  334         else if (!strncmp(buf, "offline", min_t(int, count, 7)))
>  335                 online_type = -1;
> ......
>  355         case -1:
>  356                 ret = device_offline(&mem->dev);
>  357                 break;
> ......
> 
> Here, "offline" is hard coded as -1.
> 
> This patch does the following renaming:
>  ONLINE_KEEP     ->  MMOP_ONLINE_KEEP
>  ONLINE_KERNEL   ->  MMOP_ONLINE_KERNEL
>  ONLINE_MOVABLE  ->  MMOP_ONLINE_MOVABLE
> 
> and introduce MMOP_OFFLINE = -1 to avoid hard coding.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
>  drivers/base/memory.c          | 18 +++++++++---------
>  include/linux/memory_hotplug.h |  9 +++++----
>  mm/memory_hotplug.c            |  9 ++++++---
>  3 files changed, 20 insertions(+), 16 deletions(-)

The patch does not apply cleanly to the current top of the tree.  Can
you rebase the patch?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
