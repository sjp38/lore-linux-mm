Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id ED9106B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 04:05:58 -0500 (EST)
Message-ID: <5108E245.9060501@cn.fujitsu.com>
Date: Wed, 30 Jan 2013 17:05:09 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH Bug fix] acpi, movablemem_map: node0 should always be
 unhotpluggable when using SRAT.
References: <1359532470-28874-1-git-send-email-tangchen@cn.fujitsu.com> <alpine.DEB.2.00.1301300049100.19679@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1301300049100.19679@chino.kir.corp.google.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/30/2013 04:50 PM, David Rientjes wrote:
> On Wed, 30 Jan 2013, Tang Chen wrote:
>
>> When using movablemem_map=acpi, always set node0 as unhotpluggable, otherwise
>> if all the memory is hotpluggable, the kernel will fail to boot.
>>
>> When using movablemem_map=nn[KMG]@ss[KMG], we don't stop users specifying
>> node0 as hotpluggable, and ignore all the info in SRAT, so that this option
>> can be used as a workaround of firmware bugs.
>>
>
> Could you elaborate on the failure you're seeing?
>
> I've booted the kernel many times without memory on a node 0.
>

Hi David,

The failure I'm trying to fix is that if all the memory is hotpluggable, 
and user
specified movablemem_map, my code will set all the memory as 
ZONE_MOVABLE, and kernel
will fail to allocate any memory, and it will fail to boot.

But I'm sorry if I didn't answer your question. :)

Are you saying your memory is not on node0, and your physical address
0x0 is not on node0 ? And your /sys fs don't have a node0 interface, it is
node1 or something else ?

If so, I think I'd better find another way to fix this problem because 
node0 may not be
the first node on the system.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
