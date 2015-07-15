Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4CDF3280245
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:20:13 -0400 (EDT)
Received: by ykay190 with SMTP id y190so48026803yka.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 14:20:13 -0700 (PDT)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id r7si4005772yke.66.2015.07.15.14.20.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 14:20:12 -0700 (PDT)
Received: by ykeo3 with SMTP id o3so47906703yke.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 14:20:11 -0700 (PDT)
Date: Wed, 15 Jul 2015 17:20:08 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] mem-hotplug: Handle node hole when initializing
 numa_meminfo.
Message-ID: <20150715212008.GK15934@mtj.duckdns.org>
References: <1435720614-16480-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435720614-16480-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, dyoung@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yasu.isimatu@gmail.com, lcapitulino@redhat.com, qiuxishi@huawei.com, will.deacon@arm.com, tony.luck@intel.com, vladimir.murzin@arm.com, fabf@skynet.be, kuleshovmail@gmail.com, bhe@redhat.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 01, 2015 at 11:16:54AM +0800, Tang Chen wrote:
...
> -		/* and there's no empty block */
> -		if (bi->start >= bi->end)
> +		/* and there's no empty or non-exist block */
> +		if (bi->start >= bi->end ||
> +		    memblock_overlaps_region(&memblock.memory,
> +			bi->start, bi->end - bi->start) == -1)

Ugh.... can you please change memblock_overlaps_region() to return
bool instead?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
