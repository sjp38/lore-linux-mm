Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 5AEE26B0062
	for <linux-mm@kvack.org>; Sun, 30 Dec 2012 00:55:40 -0500 (EST)
Message-ID: <50DFD8F4.7040301@cn.fujitsu.com>
Date: Sun, 30 Dec 2012 14:02:28 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 14/14] memory-hotplug: free node_data when a node is
 offlined
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-15-git-send-email-tangchen@cn.fujitsu.com> <50DA7533.6060407@jp.fujitsu.com> <50DC3C26.6060308@cn.fujitsu.com> <50DCE7C0.8070407@jp.fujitsu.com>
In-Reply-To: <50DCE7C0.8070407@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

At 12/28/2012 08:28 AM, Kamezawa Hiroyuki Wrote:
> (2012/12/27 21:16), Wen Congyang wrote:
>> At 12/26/2012 11:55 AM, Kamezawa Hiroyuki Wrote:
>>> (2012/12/24 21:09), Tang Chen wrote:
>>>> From: Wen Congyang <wency@cn.fujitsu.com>
>>>>
>>>> We call hotadd_new_pgdat() to allocate memory to store node_data. So we
>>>> should free it when removing a node.
>>>>
>>>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
>>>
>>> I'm sorry but is it safe to remove pgdat ? All zone cache and zonelists are
>>> properly cleared/rebuilded in synchronous way ? and No threads are visinting
>>> zone in vmscan.c ?
>>
>> We have rebuilt zonelists when a zone has no memory after offlining some pages.
>>
> 
> How do you guarantee that the address of pgdat/zone is not on stack of any kernel
> threads or other kernel objects without reference counting or other syncing method ?

No way to guarentee this. But, the kernel should not use the address of pgdat/zone when
it is offlined.

Hmm, what about this: reuse the memory when the node is onlined again?

Thanks
Wen Congyang

> 
> 
> Thanks,
> -Kame
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
