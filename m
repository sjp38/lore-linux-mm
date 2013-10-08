Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0126B0037
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 11:29:22 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so8965843pbb.10
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 08:29:22 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so8816266pdi.19
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 08:29:19 -0700 (PDT)
Message-ID: <525424A8.80608@gmail.com>
Date: Tue, 08 Oct 2013 23:28:40 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part1 v6 0/6] x86, memblock: Allocate memory near kernel
 image before SRAT parsed
References: <524E2032.4020106@gmail.com> <20131008042302.GA14353@gmail.com>
In-Reply-To: <20131008042302.GA14353@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello Ingo,

On 10/08/2013 12:23 PM, Ingo Molnar wrote:
> 
> * Zhang Yanfei <zhangyanfei.yes@gmail.com> wrote:
> 
>> Hello, here is the v6 version. Any comments are welcome!
> 
> Ok, I think this is as good as this feature can get without hardware 
> support.
> 

Without hardware/firmware support, we cannot know which memory is
hotpluggable.

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
