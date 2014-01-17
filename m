Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 614536B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 19:16:33 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id b6so1191250yha.36
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 16:16:33 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id q66si12443298yhm.4.2014.01.16.16.16.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jan 2014 16:16:32 -0800 (PST)
Message-ID: <52D87617.8090804@zytor.com>
Date: Thu, 16 Jan 2014 16:15:19 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND part2 v2 1/8] x86: get pg_data_t's memory from
 other node
References: <529D3FC0.6000403@cn.fujitsu.com> <529D4048.9070000@cn.fujitsu.com> <20140116171112.GB24740@suse.de>
In-Reply-To: <20140116171112.GB24740@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

On 01/16/2014 09:11 AM, Mel Gorman wrote:
> This implies that it is possible to ahve a configuration with a big ratio
> difference between Normal:Movable memory.

In fact, one would expect that would be the norm.

> In such configurations there
> would be a risk that the system will reclaim heavily or go OOM because
> the kernrel cannot allocate memory due to a relatively small Normal
> zone. What protects against that? Is the user ever warned if the ratio
> between Normal:Movable very high? The movable_node boot parameter still
> turns the feature on and off, there appears to be no way of controlling
> the ratio of memory other than booting with the minimum amount of memory
> and manually hot-adding the sections to set the appropriate ratio.

This is really the fundamental problem with this particular approach to
hotswap memory.

	-hpa



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
