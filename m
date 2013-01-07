Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 675F86B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 00:31:33 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CAB703EE0BC
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 14:31:30 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A66C245DE5E
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 14:31:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8564345DE56
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 14:31:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A0AA1DB8045
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 14:31:30 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 182731DB803F
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 14:31:30 +0900 (JST)
Message-ID: <50EA5D7D.7000703@jp.fujitsu.com>
Date: Mon, 07 Jan 2013 14:30:37 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 14/14] memory-hotplug: free node_data when a node is
 offlined
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-15-git-send-email-tangchen@cn.fujitsu.com> <50DA7533.6060407@jp.fujitsu.com> <50DC3C26.6060308@cn.fujitsu.com> <50DCE7C0.8070407@jp.fujitsu.com> <50DFD8F4.7040301@cn.fujitsu.com>
In-Reply-To: <50DFD8F4.7040301@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2012/12/30 15:02), Wen Congyang wrote:
> At 12/28/2012 08:28 AM, Kamezawa Hiroyuki Wrote:
>> (2012/12/27 21:16), Wen Congyang wrote:
>>> At 12/26/2012 11:55 AM, Kamezawa Hiroyuki Wrote:
>>>> (2012/12/24 21:09), Tang Chen wrote:
>>>>> From: Wen Congyang <wency@cn.fujitsu.com>
>>>>>
>>>>> We call hotadd_new_pgdat() to allocate memory to store node_data. So we
>>>>> should free it when removing a node.
>>>>>
>>>>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
>>>>
>>>> I'm sorry but is it safe to remove pgdat ? All zone cache and zonelists are
>>>> properly cleared/rebuilded in synchronous way ? and No threads are visinting
>>>> zone in vmscan.c ?
>>>
>>> We have rebuilt zonelists when a zone has no memory after offlining some pages.
>>>
>>
>> How do you guarantee that the address of pgdat/zone is not on stack of any kernel
>> threads or other kernel objects without reference counting or other syncing method ?
> 
> No way to guarentee this. But, the kernel should not use the address of pgdat/zone when
> it is offlined.
> 
> Hmm, what about this: reuse the memory when the node is onlined again?
> 

That's the only way which we can go now. Please don't free it.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
