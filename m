Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBAE82F65
	for <linux-mm@kvack.org>; Sun, 18 Oct 2015 22:25:37 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so13987760pad.1
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 19:25:37 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id td8si48951123pac.42.2015.10.18.19.25.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 18 Oct 2015 19:25:36 -0700 (PDT)
Message-ID: <5624548F.30500@huawei.com>
Date: Mon, 19 Oct 2015 10:25:19 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Introduce kernelcore=reliable option
References: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
In-Reply-To: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, akpm@linux-foundation.org, dave.hansen@intel.com, matt@codeblueprint.co.uk

On 2015/10/15 21:32, Taku Izumi wrote:

> Xeon E7 v3 based systems supports Address Range Mirroring
> and UEFI BIOS complied with UEFI spec 2.5 can notify which
> ranges are reliable (mirrored) via EFI memory map.
> Now Linux kernel utilize its information and allocates
> boot time memory from reliable region.
> 
> My requirement is:
>   - allocate kernel memory from reliable region
>   - allocate user memory from non-reliable region
> 
> In order to meet my requirement, ZONE_MOVABLE is useful.
> By arranging non-reliable range into ZONE_MOVABLE,
> reliable memory is only used for kernel allocations.
> 
> This patch extends existing "kernelcore" option and
> introduces kernelcore=reliable option. By specifying
> "reliable" instead of specifying the amount of memory,
> non-reliable region will be arranged into ZONE_MOVABLE.
> 
> Earlier discussion is at:
>  https://lkml.org/lkml/2015/10/9/24
> 

Hi Taku,

If user don't want to waste a lot of memory, and he only set
a few memory to mirrored memory, then the kernelcore is very
small, right? That means OS will have a very small normal zone
and a very large movable zone.

Kernel allocation could only use the unmovable zone. As the
normal zone is very small, the kernel allocation maybe OOM,
right?

Do you mean that we will reuse the movable zone in short-term
solution and create a new zone(mirrored zone) in future?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
