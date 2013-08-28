Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id CF3D36B0033
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 05:35:54 -0400 (EDT)
Message-ID: <521DC424.5000500@cn.fujitsu.com>
Date: Wed, 28 Aug 2013 17:34:28 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/11] x86, memblock: Allocate memory near kernel image
 before SRAT parsed.
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com> <20130828080311.GA608@hacker.(null)>
In-Reply-To: <20130828080311.GA608@hacker.(null)>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi Wanpeng

On 08/28/2013 04:03 PM, Wanpeng Li wrote:
> Hi Tang,
......
>> [About this patch-set]
>>
>> So this patch-set does the following:
>>
>> 1. Make memblock be able to allocate memory from low address to high address.
>
> I want to know if there is fragmentation degree difference here?
>

Before this patch-set, we mapped memory like this:

1. [0, ISA_END_ADDRESS),
2. [ISA_END_ADDRESS, round_down(max_addr, PMD_SIZE)), from top downwards,
3. [round_down(max_addr, PMD_SIZE), max_addr)


After this patch-set, when movablenode is enabled, it is like:

1. [round_up(_end, PMD_SIZE), max_addr), from _end upwards,
2. [ISA_END_ADDRESS, round_up(_end, PMD_SIZE)),
3. [0, ISA_END_ADDRESS)


All the boundaries are aligned with PMD_SIZE. I think it is the same.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
