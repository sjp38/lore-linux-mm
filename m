Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 849ED6B0032
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 23:43:13 -0400 (EDT)
Message-ID: <52031377.6050508@cn.fujitsu.com>
Date: Thu, 08 Aug 2013 11:41:43 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/25] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com> <1786839.lAdBpJ22ie@vostro.rjw.lan> <94F2FBAB4432B54E8AACC7DFDE6C92E36FEAC85B@ORSMSX103.amr.corp.intel.com>
In-Reply-To: <94F2FBAB4432B54E8AACC7DFDE6C92E36FEAC85B@ORSMSX103.amr.corp.intel.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Moore, Robert" <robert.moore@intel.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, "Zheng, Lv" <lv.zheng@intel.com>, "lenb@kernel.org" <lenb@kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "tj@kernel.org" <tj@kernel.org>, "trenn@suse.de" <trenn@suse.de>, "yinghai@kernel.org" <yinghai@kernel.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, "mgorman@suse.de" <mgorman@suse.de>, "minchan@kernel.org" <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "Box, David E" <david.e.box@intel.com>, "zhangyanfei@cn.fujitsu.com" <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>

Hi Bob, Rafael,

I have resent all 5 ACPICA side patches separately.
Some other patches are not in ACPICA side, but they may still
need you guys to help to review.

I'll send them later.

Thanks.:)

On 08/08/2013 11:01 AM, Moore, Robert wrote:
>
>
......
>>
>> This looks a bit more manageable than before, but please do one more
>> thing:
>> Please split all of the ACPICA changes out into separate patches and put
>> those patched in front of everything else.
>>
>> The reason is we may need to merge them through upstream ACPICA as the
>> first step (if they are accepted by the ACPICA maintainers).
>>
>
>
> Yes, we (ACPICA) would like to see them all together in one place so that we can review.
> Thanks,
> Bob
>
>
>
>
>> Thanks,
>> Rafael
>>
>>
>> --
>> I speak only for myself.
>> Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
