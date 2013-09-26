Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF776B0036
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 10:45:24 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so1400938pab.31
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:45:23 -0700 (PDT)
Received: by mail-ye0-f169.google.com with SMTP id r13so419047yen.14
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:45:21 -0700 (PDT)
Date: Thu, 26 Sep 2013 10:45:16 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 2/6] memblock: Introduce bottom-up allocation mode
Message-ID: <20130926144516.GD3482@htj.dyndns.org>
References: <5241D897.1090905@gmail.com>
 <5241D9A4.4080305@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5241D9A4.4080305@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Hello,

On Wed, Sep 25, 2013 at 02:27:48AM +0800, Zhang Yanfei wrote:
> +#ifdef CONFIG_MOVABLE_NODE
> +static inline void memblock_set_bottom_up(bool enable)
> +{
> +	memblock.bottom_up = enable;
> +}
> +
> +static inline bool memblock_bottom_up(void)
> +{
> +	return memblock.bottom_up;
> +}

Can you please explain what this is for here?

> +		/*
> +		 * we always limit bottom-up allocation above the kernel,
> +		 * but top-down allocation doesn't have the limit, so
> +		 * retrying top-down allocation may succeed when bottom-up
> +		 * allocation failed.
> +		 *
> +		 * bottom-up allocation is expected to be fail very rarely,
> +		 * so we use WARN_ONCE() here to see the stack trace if
> +		 * fail happens.
> +		 */
> +		WARN_ONCE(1, "memblock: Failed to allocate memory in bottom up "
> +			"direction. Now try top down direction.\n");
> +	}

You and I would know what was going on and what the consequence of the
failure may be but the above warning message is kinda useless to a
user / admin, right?  It doesn't really say anything meaningful.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
