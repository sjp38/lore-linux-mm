Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id F2C906B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 09:13:45 -0400 (EDT)
Message-ID: <520CCF0A.9050206@cn.fujitsu.com>
Date: Thu, 15 Aug 2013 20:52:26 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <5208FBBC.2080304@zytor.com> <20130812152343.GK15892@htj.dyndns.org> <52090D7F.6060600@gmail.com> <20130812164650.GN15892@htj.dyndns.org> <5209CEC1.8070908@cn.fujitsu.com> <520A02DE.1010908@cn.fujitsu.com> <CAE9FiQV2-OOvHZtPYSYNZz+DfhvL0e+h2HjMSW3DyqeXXvdJkA@mail.gmail.com> <520C947B.40407@cn.fujitsu.com> <20130815121900.GA14606@htj.dyndns.org> <520CCD41.5000508@cn.fujitsu.com> <20130815124925.GB14606@htj.dyndns.org>
In-Reply-To: <20130815124925.GB14606@htj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Yinghai Lu <yinghai@kernel.org>, Tang Chen <imtangchen@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "Luck, Tony (tony.luck@intel.com)" <tony.luck@intel.com>

On 08/15/2013 08:49 PM, Tejun Heo wrote:
> Hello,
>
> On Thu, Aug 15, 2013 at 08:44:49PM +0800, Tang Chen wrote:
>> I wanted to ask for some comment to the above solution. When I was
>> coding, I found that change the behavior of pagetable initialization
>> could be ugly. We should start from the middle of the memory, where
>> the kernel image is, but not the end of memory.
>>
>> I'm not asking for any detail comment, just seeing from the description,
>> is it acceptable ?
>
> Hmmm... I can't really tell without knowing how ugly it gets and why.
> Do you mind posting a draft patch so that we can have better context?

Sure. I'll try my best to post a draft patch tomorrow.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
