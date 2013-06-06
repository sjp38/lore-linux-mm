Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 15E906B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 05:39:37 -0400 (EDT)
Message-ID: <51B05983.5060009@cn.fujitsu.com>
Date: Thu, 06 Jun 2013 17:42:27 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 07/13] x86, numa, mem-hotplug: Mark nodes which the
 kernel resides in.
References: <1369387762-17865-1-git-send-email-tangchen@cn.fujitsu.com> <1369387762-17865-8-git-send-email-tangchen@cn.fujitsu.com> <20130531162401.GA31139@dhcp-192-168-178-175.profitbricks.localdomain> <51AC4759.6090101@cn.fujitsu.com> <20130603131823.GA4729@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20130603131823.GA4729@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Vasilis,

On 06/03/2013 09:18 PM, Vasilis Liaskovitis wrote:
......
>>
>> In such an early time, I think we can only get nid from
>> numa_meminfo. So as I
>> said above, I'd like to fix this problem by making memblock has correct nid.
>>
>> And I read the patch below. I think if we get nid from numa_meminfo,
>> than we
>> don't need to call memblock_get_region_node().
>>
>
> ok. If we update the memblock nid fields from numa_meminfo,
> memblock_get_region_node will always return the correct node id.
>

I have fixed this problem in this way. And I'll send the new patches 
next week.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
