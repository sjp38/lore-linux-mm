Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 84F5C6B0034
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 20:38:59 -0400 (EDT)
Message-ID: <520439C9.3080601@cn.fujitsu.com>
Date: Fri, 09 Aug 2013 08:37:29 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH part2 0/4] acpi: Trivial fix and improving for memory
 hotplug.
References: <1375938239-18769-1-git-send-email-tangchen@cn.fujitsu.com> <1851799.n4moZnvj4u@vostro.rjw.lan>
In-Reply-To: <1851799.n4moZnvj4u@vostro.rjw.lan>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: robert.moore@intel.com, lv.zheng@intel.com, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 08/08/2013 10:09 PM, Rafael J. Wysocki wrote:
> On Thursday, August 08, 2013 01:03:55 PM Tang Chen wrote:
>> This patch-set does some trivial fix and improving in ACPI code
>> for memory hotplug.
>>
>> Patch 1,3,4 have been acked.
>>
>> Tang Chen (4):
>>    acpi: Print Hot-Pluggable Field in SRAT.
>>    earlycpio.c: Fix the confusing comment of find_cpio_data().
>>    acpi: Remove "continue" in macro INVALID_TABLE().
>>    acpi: Introduce acpi_verify_initrd() to check if a table is invalid.
>>
>>   arch/x86/mm/srat.c |   11 ++++--
>>   drivers/acpi/osl.c |   84 +++++++++++++++++++++++++++++++++++++++------------
>>   lib/earlycpio.c    |   27 ++++++++--------
>>   3 files changed, 85 insertions(+), 37 deletions(-)
>
> It looks like this part doesn't depend on the other parts, is that correct?

No, it doesn't. And this patch-set can be merged first.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
