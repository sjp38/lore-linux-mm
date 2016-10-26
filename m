Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 04A7F6B027A
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:36:17 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hm5so6476621pac.4
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 11:36:16 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l2si4045706pga.245.2016.10.26.11.36.16
        for <linux-mm@kvack.org>;
        Wed, 26 Oct 2016 11:36:16 -0700 (PDT)
Date: Wed, 26 Oct 2016 19:36:14 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/2] arm64/numa: support HAVE_MEMORYLESS_NODES
Message-ID: <20161026183614.GJ15216@arm.com>
References: <1477364358-10620-1-git-send-email-thunder.leizhen@huawei.com>
 <1477364358-10620-3-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1477364358-10620-3-git-send-email-thunder.leizhen@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhen Lei <thunder.leizhen@huawei.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Tue, Oct 25, 2016 at 10:59:18AM +0800, Zhen Lei wrote:
> Some numa nodes may have no memory. For example:
> 1) a node has no memory bank plugged.
> 2) a node has no memory bank slots.
> 
> To ensure percpu variable areas and numa control blocks of the
> memoryless numa nodes to be allocated from the nearest available node to
> improve performance, defined node_distance_ready. And make its value to be
> true immediately after node distances have been initialized.
> 
> Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
> ---
>  arch/arm64/Kconfig            | 4 ++++
>  arch/arm64/include/asm/numa.h | 3 +++
>  arch/arm64/mm/numa.c          | 6 +++++-
>  3 files changed, 12 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 30398db..648dd13 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -609,6 +609,10 @@ config NEED_PER_CPU_EMBED_FIRST_CHUNK
>  	def_bool y
>  	depends on NUMA
> 
> +config HAVE_MEMORYLESS_NODES
> +	def_bool y
> +	depends on NUMA

Given that patch 1 and the associated node_distance_ready stuff is all
an unqualified performance optimisation, is there any merit in just
enabling HAVE_MEMORYLESS_NODES in Kconfig and then optimising things as
a separate series when you have numbers to back it up?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
