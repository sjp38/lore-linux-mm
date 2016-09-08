Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4279F82F66
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 07:01:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x24so106820907pfa.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 04:01:22 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g71si27003076pfg.13.2016.09.08.04.01.21
        for <linux-mm@kvack.org>;
        Thu, 08 Sep 2016 04:01:21 -0700 (PDT)
Date: Thu, 8 Sep 2016 12:01:19 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v8 00/16] fix some type infos and bugs for arm64/of numa
Message-ID: <20160908110119.GG1493@arm.com>
References: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhen Lei <thunder.leizhen@huawei.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, devicetree <devicetree@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Thu, Sep 01, 2016 at 02:54:51PM +0800, Zhen Lei wrote:
> v7 -> v8:
> Updated patches according to Will Deacon's review comments, thanks.
> 
> The changed patches is: 3, 5, 8, 9, 10, 11, 12, 13, 15
> Patch 3 requires an ack from Rob Herring.
> Patch 10 requires an ack from linux-mm.
> 
> Hi, Will:
> Something should still be clarified:
> Patch 5, I modified it according to my last reply. BTW, The last sentence
>          "srat_disabled() ? -EINVAL : 0" of arm64_acpi_numa_init should be moved
>          into acpi_numa_init, I think.
>          
> Patch 9, I still leave the code in arch/arm64.
>          1) the implementation of setup_per_cpu_areas on all platforms are different.
>          2) Although my implementation referred to PowerPC, but still something different.
> 
> Patch 15, I modified the description again. Can you take a look at it? If this patch is
> 	  dropped, the patch 14 should also be dropped.
> 
> Patch 16, How many times the function node_distance to be called rely on the APP(need many tasks
>           to be scheduled), I have not prepared yet, so I give up this patch as your advise. 

Ok, I'm trying to pick the pieces out of this patch series and it's not
especially easy. As far as I can tell:

  Patch 3 needs an ack from the device-tree folks

  Patch 10 needs an ack from the memblock folks

  Patch 11 depends on patch 10

  Patches 14,15,16 can wait for the time being (I still don't see their
  value).

So, I could pick up patches 1-2, 4-9 and 12-13 but it's not clear whether
that makes any sense. The whole series seems to be a mix of trivial printk
cleanups, a bunch of core OF stuff, some new features and then some
questionable changes at the end.

Please throw me a clue,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
