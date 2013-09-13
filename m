Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id B72436B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 23:34:12 -0400 (EDT)
Message-ID: <52328839.9010309@cn.fujitsu.com>
Date: Fri, 13 Sep 2013 11:36:25 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v2 3/9] x86, dma: Support allocate memory from
 bottom upwards in dma_contiguous_reserve().
References: <1378979537-21196-1-git-send-email-tangchen@cn.fujitsu.com>  <1378979537-21196-4-git-send-email-tangchen@cn.fujitsu.com> <1379013759.13477.12.camel@misato.fc.hp.com>
In-Reply-To: <1379013759.13477.12.camel@misato.fc.hp.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: tj@kernel.org, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi Toshi,

On 09/13/2013 03:22 AM, Toshi Kani wrote:
......
>> +		if (memblock_direction_bottom_up()) {
>> +			addr = memblock_alloc_bottom_up(
>> +						MEMBLOCK_ALLOC_ACCESSIBLE,
>> +						limit, size, alignment);
>> +			if (addr)
>> +				goto success;
>> +		}
>
> I am afraid that this version went to a wrong direction.  Allocating
> from the bottom up needs to be an internal logic within the memblock
> allocator.  It should not require the callers to be aware of the
> direction and make a special request.
>

I think my v1 patch-set was trying to do so. Was it too complicated ?

So just move this logic to memblock_find_in_range_node(), is this OK ?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
