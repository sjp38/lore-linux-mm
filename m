Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 5EE0A6B0032
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 03:34:22 -0400 (EDT)
Message-ID: <51AC47A2.6020108@cn.fujitsu.com>
Date: Mon, 03 Jun 2013 15:37:06 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 12/13] x86, numa, acpi, memory-hotplug: Make movablecore=acpi
 have higher priority.
References: <1369387762-17865-1-git-send-email-tangchen@cn.fujitsu.com> <1369387762-17865-13-git-send-email-tangchen@cn.fujitsu.com> <20130603025924.GB7441@hacker.(null)>
In-Reply-To: <20130603025924.GB7441@hacker.(null)>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/03/2013 10:59 AM, Wanpeng Li wrote:
> On Fri, May 24, 2013 at 05:29:21PM +0800, Tang Chen wrote:
>> Arrange hotpluggable memory as ZONE_MOVABLE will cause NUMA performance decreased
>> because the kernel cannot use movable memory.
>>
>> For users who don't use memory hotplug and who don't want to lose their NUMA
>> performance, they need a way to disable this functionality.
>>
>> So, if users specify "movablecore=acpi" in kernel commandline, the kernel will
>> use SRAT to arrange ZONE_MOVABLE, and it has higher priority then original
>> movablecore and kernelcore boot option.
>>
>> For those who don't want this, just specify nothing.
>>
>
> Reviewed-by: Wanpeng Li<liwanp@linux.vnet.ibm.com>

Thank you very much for reviewing these patches. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
