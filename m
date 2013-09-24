Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 833556B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 11:25:27 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so5133856pab.15
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 08:25:27 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so5169903pab.27
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 08:25:24 -0700 (PDT)
Message-ID: <5241AEC0.6040505@gmail.com>
Date: Tue, 24 Sep 2013 23:24:48 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] mem-hotplug: Introduce movablenode boot option
References: <524162DA.30004@cn.fujitsu.com> <5241655E.1000007@cn.fujitsu.com> <20130924124121.GG2366@htj.dyndns.org> <5241944B.4050103@gmail.com>
In-Reply-To: <5241944B.4050103@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

Hello tejun,

On 09/24/2013 09:31 PM, Zhang Yanfei wrote:
>> This came up during earlier review but never was addressed.  Is
>> > "movablenode" the right name?  Shouldn't it be something which
>> > explicitly shows that it's to prepare for memory hotplug?  Also, maybe
>> > the above param should generate warning if CONFIG_MOVABLE_NODE isn't
>> > enabled?
> hmmm...as for the option name, if this option is set, it means, the kernel
> could support the functionality that a whole node is the so called
> movable node, which only has ZONE MOVABLE zone in it. So we choose
> to name the parameter "movablenode".
> 
> As for the warning, will add it.

I am now preparing the v5 version. Only in this patch we haven't come to an
agreement. So as for the boot option name, after my explanation, do you still
have the objection? Or you could suggest a good name for us, that'll be
very thankful:)

Thanks.

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
