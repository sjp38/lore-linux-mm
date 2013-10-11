Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 864886B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 02:47:45 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so3868134pad.23
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 23:47:45 -0700 (PDT)
Message-ID: <52579EC3.9040708@cn.fujitsu.com>
Date: Fri, 11 Oct 2013 14:46:27 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
References: <524E2032.4020106@gmail.com> <524E2127.4090904@gmail.com> <5251F9AB.6000203@zytor.com> <525442A4.9060709@gmail.com> <20131009164449.GG22495@htj.dyndns.org> <CAE9FiQXhW2BacXUjQLK8TpcvhHAediuCntVR13sKGUuq_+=ymw@mail.gmail.com> <20131009192356.GB5592@mtj.dyndns.org> <CAE9FiQWpwp4bTEWEYw3-CW9xF5s_zJAayJrBC_buBC7-nd=7KA@mail.gmail.com> <525790E4.3060806@cn.fujitsu.com> <20131011063300.GA9429@gmail.com>
In-Reply-To: <20131011063300.GA9429@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello Ingo,

On 10/11/2013 02:33 PM, Ingo Molnar wrote:
> 
> * Zhang Yanfei <zhangyanfei@cn.fujitsu.com> wrote:
> 
>> Hello yinghai,
>>
>> I know your opinion but take code modification as an example seems like 
>> it doesn't stand. More code doesn't mean more complexity......
> 
> I think you forgot to reply to this point:
> 
>>> For long term to keep the code more maintainable, We really should go 
>>> though parse srat table early.
> 

Both ways (the approach of the this patchset and the approach of parsing
SRAT earlier) could let us realize the functionality that we want. So
as long as this point could convince tejun, I am ok with that.

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
