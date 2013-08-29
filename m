Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id DCCF76B0036
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 21:54:53 -0400 (EDT)
Message-ID: <521EA99B.3010303@cn.fujitsu.com>
Date: Thu, 29 Aug 2013 09:53:31 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/11] x86, memblock: Allocate memory near kernel image
 before SRAT parsed.
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com> <20130828151909.GE9295@htj.dyndns.org> <521EA44E.1020205@cn.fujitsu.com> <20130829013657.GA22599@hacker.(null)>
In-Reply-To: <20130829013657.GA22599@hacker.(null)>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Tejun Heo <tj@kernel.org>, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi Wanpeng,

On 08/29/2013 09:36 AM, Wanpeng Li wrote:
......
>> Hi tj,
>>
>> Sorry for the trouble. Please refer to the following branch:
>>
>> https://github.com/imtangchen/linux.git  movablenode-boot-option
>>
>
> Could you post your testcase? So I can test it on x86 and powerpc machines.
>

Sure. Some simple testcases:

1. Boot the kernel without movablenode boot option, check if the memory 
mapping
    is initialized as before, high to low.
2. Boot the kernel with movablenode boot option, check if the memory 
mapping
    is initialized as before, low to high.
3. With movablenode, check if the memory allocation is from high to low 
after
    SRAT is parsed.
4. Check if we can do acpi_initrd_override normally with and without 
movablenode.
    And the memory allocation is from low to high, near the end of 
kernel image.
5. with movablenode, check if crashkernel boot option works normally.
    (This may consume a lot of memory, but should work normally.)
6. With movablenode, check if relocate_initrd() works normally.
    (This may consume a lot of memory, but should work normally.)
7. With movablenode, check if kexec could locate the kernel to higher 
memory.
    (This may consume hotplug memory if higher memory is hotpluggable, 
but should work normally.)


Please do the above tests with and without the following config options:

1. CONFIG_MOVABLE_NODE
2. CONFIG_ACPI_INITRD_OVERRIDE


Thanks for the testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
