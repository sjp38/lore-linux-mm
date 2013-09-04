Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5D3F76B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 21:01:52 -0400 (EDT)
Message-ID: <52268634.1050008@cn.fujitsu.com>
Date: Wed, 04 Sep 2013 09:00:36 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/11] memblock: Improve memblock to support allocation
 from lower address.
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>  <1377596268-31552-7-git-send-email-tangchen@cn.fujitsu.com> <1378254257.10300.921.camel@misato.fc.hp.com>
In-Reply-To: <1378254257.10300.921.camel@misato.fc.hp.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 09/04/2013 08:24 AM, Toshi Kani wrote:
......
>> +phys_addr_t __init_memblock
>> +__memblock_find_range(phys_addr_t start, phys_addr_t end,
>> +		      phys_addr_t size, phys_addr_t align, int nid)
>
> This func should be static as it must be an internal func.
>
......
>> +phys_addr_t __init_memblock
>> +__memblock_find_range_rev(phys_addr_t start, phys_addr_t end,
>> +			  phys_addr_t size, phys_addr_t align, int nid)
>
> Ditto.
......
>> +	if (memblock.current_order == MEMBLOCK_ORDER_DEFAULT)
>
> This needs to use MEMBLOCK_ORDER_HIGH_TO_LOW since the code should be
> independent from the value of MEMBLOCK_ORDER_DEFAULT.
>

OK, followed.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
