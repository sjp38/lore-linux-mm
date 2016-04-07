Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id AB6426B007E
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 10:21:55 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id 184so56883817pff.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 07:21:55 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m27si379011pfj.88.2016.04.07.07.21.54
        for <linux-mm@kvack.org>;
        Thu, 07 Apr 2016 07:21:54 -0700 (PDT)
Date: Thu, 7 Apr 2016 15:21:48 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
Message-ID: <20160407142148.GI5657@arm.com>
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: catalin.marinas@arm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, akpm@linux-foundation.org, robin.murphy@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, rientjes@google.com, linux-mm@kvack.org, puck.chen@foxmail.com, oliver.fu@hisilicon.com, linuxarm@huawei.com, dan.zhao@hisilicon.com, suzhuangluan@hisilicon.com, yudongbin@hislicon.com, albert.lubing@hisilicon.com, xuyiping@hisilicon.com, saberlily.xia@hisilicon.com

On Tue, Apr 05, 2016 at 04:22:51PM +0800, Chen Feng wrote:
> We can reduce the memory allocated at mem-map
> by flatmem.
> 
> currently, the default memory-model in arm64 is
> sparse memory. The mem-map array is not freed in
> this scene. If the physical address is too long,
> it will reserved too much memory for the mem-map
> array.

Can you elaborate a bit more on this, please? We use the vmemmap, so any
spaces between memory banks only burns up virtual space. What exactly is
the problem you're seeing that makes you want to use flatmem (which is
probably unsuitable for the majority of arm64 machines).

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
