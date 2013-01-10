Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 95AE36B005A
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 02:32:45 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D18F73EE0BC
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 16:32:43 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B696445DE59
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 16:32:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B55745DE55
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 16:32:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BBA0E08006
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 16:32:43 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 39A4FE08002
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 16:32:43 +0900 (JST)
Message-ID: <50EE6E50.3040609@jp.fujitsu.com>
Date: Thu, 10 Jan 2013 16:31:28 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com> <20130109142314.1ce04a96.akpm@linux-foundation.org> <50EE24A4.8020601@cn.fujitsu.com> <50EE6A48.7060307@parallels.com>
In-Reply-To: <50EE6A48.7060307@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2013/01/10 16:14), Glauber Costa wrote:
> On 01/10/2013 06:17 AM, Tang Chen wrote:
>>>> Note: if the memory provided by the memory device is used by the
>>>> kernel, it
>>>> can't be offlined. It is not a bug.
>>>
>>> Right.  But how often does this happen in testing?  In other words,
>>> please provide an overall description of how well memory hot-remove is
>>> presently operating.  Is it reliable?  What is the success rate in
>>> real-world situations?
>>
>> We test the hot-remove functionality mostly with movable_online used.
>> And the memory used by kernel is not allowed to be removed.
>
> Can you try doing this using cpusets configured to hardwall ?
> It is my understanding that the object allocators will try hard not to
> allocate anything outside the walls defined by cpuset. Which means that
> if you have one process per node, and they are hardwalled, your kernel
> memory will be spread evenly among the machine. With a big enough load,
> they should eventually be present in all blocks.
>

I'm sorry I couldn't catch your point.
Do you want to confirm whether cpuset can work enough instead of ZONE_MOVABLE ?
Or Do you want to confirm whether ZONE_MOVABLE will not work if it's used with cpuset ?


> Another question I have for you: Have you considering calling
> shrink_slab to try to deplete the caches and therefore free at least
> slab memory in the nodes that can't be offlined? Is it relevant?
>

At this stage, we don't consider to call shrink_slab(). We require
nearly 100% success at offlining memory for removing DIMM.
It's my understanding.

IMHO, I don't think shrink_slab() can kill all objects in a node even
if they are some caches. We need more study for doing that.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
