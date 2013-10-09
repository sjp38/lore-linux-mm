Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E97586B0037
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 19:30:33 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so1787823pab.31
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 16:30:33 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1780752pad.30
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 16:30:30 -0700 (PDT)
Message-ID: <5255E701.9050100@gmail.com>
Date: Thu, 10 Oct 2013 07:30:09 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
References: <524E2032.4020106@gmail.com> <524E2127.4090904@gmail.com> <5251F9AB.6000203@zytor.com> <525442A4.9060709@gmail.com> <20131009164449.GG22495@htj.dyndns.org> <52558EEF.4050009@gmail.com> <20131009192040.GA5592@mtj.dyndns.org> <5255C87F.8070701@gmail.com> <5255C91B.7030608@zytor.com>
In-Reply-To: <5255C91B.7030608@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On 10/10/2013 05:22 AM, H. Peter Anvin wrote:
> On 10/09/2013 02:19 PM, Zhang Yanfei wrote:
>>>
>>> Yeah, I was referring to the 16MB limit, which apparently ceased to
>>> exist.
>>
>> Hmmmm...If we are talking 16MB limit hear, I don't think it a problem, either.
>> Currently, default loading & running address of kernel is 16MB, so the
>> kernel itself is above 16MB, memory allocated in bottom-up mode is obviously
>> above the 16MB. Just seeing from a RHEL6.3 server:
>>
>>   01000000-01507ff4 : Kernel code
>>   01507ff5-01c07b2f : Kernel data
>>   01d4e000-02012023 : Kernel bss
>>
>> IOW, even if kernel is loaded and running at 1MB, it self will occupy about
>> 16MB from the above.
>>
> 
> For various DMA devices you can find almost every possible power of 2
> being a limitation.  The most common limits are 24, 32, and 40 bits, but
> you also see odd ones like 30 bits in the field.  Really.
> 

Thanks for this.

I was always curious about what the limit is when we said DMA limit before.

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
