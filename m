Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id D3813900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 22:02:28 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so5411651igb.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 19:02:28 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id c89si3340529ioj.80.2015.06.04.19.02.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 19:02:28 -0700 (PDT)
Message-ID: <55710132.4070602@huawei.com>
Date: Fri, 5 Jun 2015 09:53:54 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 02/12] mm: introduce mirror_info
References: <55704A7E.5030507@huawei.com> <55704B55.1020403@huawei.com> <3908561D78D1C84285E8C5FCA982C28F32A8D57F@ORSMSX114.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32A8D57F@ORSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/5 0:57, Luck, Tony wrote:

> +#ifdef CONFIG_MEMORY_MIRROR
> +struct numa_mirror_info {
> +	int node;
> +	unsigned long start;
> +	unsigned long size;
> +};
> +
> +struct mirror_info {
> +	int count;
> +	struct numa_mirror_info info[MAX_NUMNODES];
> +};
> 
> Do we really need this?  My patch series leaves all the mirrored memory in
> the memblock allocator tagged with the MEMBLOCK_MIRROR flag.  Can't
> we use that information when freeing the boot memory into the runtime
> free lists?
> 

Hi Tony,

I used this code for testing before, so when your patchset added to mainline,
I'll rewrite it, use MEMBLOCK_MIRROR, not mirror_info. 

I find Andrew has added your patches to mm-tree, right?

Thanks,
Xishi Qiu

> If we can't ... then [MAX_NUMNODES] may not be enough.  We may have
> more than one mirrored range on each node. Current h/w allows two ranges
> per node.
> 
> -Tony
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
