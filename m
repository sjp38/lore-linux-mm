Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 7132D6B005D
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 19:29:52 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0FB663EE0C7
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:29:51 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E584445DE5C
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:29:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CBA5845DE59
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:29:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BDA761DB8046
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:29:50 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 706FF1DB8054
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:29:50 +0900 (JST)
Message-ID: <50DCE7C0.8070407@jp.fujitsu.com>
Date: Fri, 28 Dec 2012 09:28:48 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 14/14] memory-hotplug: free node_data when a node is
 offlined
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-15-git-send-email-tangchen@cn.fujitsu.com> <50DA7533.6060407@jp.fujitsu.com> <50DC3C26.6060308@cn.fujitsu.com>
In-Reply-To: <50DC3C26.6060308@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2012/12/27 21:16), Wen Congyang wrote:
> At 12/26/2012 11:55 AM, Kamezawa Hiroyuki Wrote:
>> (2012/12/24 21:09), Tang Chen wrote:
>>> From: Wen Congyang <wency@cn.fujitsu.com>
>>>
>>> We call hotadd_new_pgdat() to allocate memory to store node_data. So we
>>> should free it when removing a node.
>>>
>>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
>>
>> I'm sorry but is it safe to remove pgdat ? All zone cache and zonelists are
>> properly cleared/rebuilded in synchronous way ? and No threads are visinting
>> zone in vmscan.c ?
> 
> We have rebuilt zonelists when a zone has no memory after offlining some pages.
> 

How do you guarantee that the address of pgdat/zone is not on stack of any kernel
threads or other kernel objects without reference counting or other syncing method ?


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
