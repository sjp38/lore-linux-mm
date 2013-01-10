Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 656366B004D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 02:14:16 -0500 (EST)
Message-ID: <50EE6A48.7060307@parallels.com>
Date: Thu, 10 Jan 2013 11:14:16 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com> <20130109142314.1ce04a96.akpm@linux-foundation.org> <50EE24A4.8020601@cn.fujitsu.com>
In-Reply-To: <50EE24A4.8020601@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On 01/10/2013 06:17 AM, Tang Chen wrote:
>>> Note: if the memory provided by the memory device is used by the
>>> kernel, it
>>> can't be offlined. It is not a bug.
>>
>> Right.  But how often does this happen in testing?  In other words,
>> please provide an overall description of how well memory hot-remove is
>> presently operating.  Is it reliable?  What is the success rate in
>> real-world situations?
> 
> We test the hot-remove functionality mostly with movable_online used.
> And the memory used by kernel is not allowed to be removed.

Can you try doing this using cpusets configured to hardwall ?
It is my understanding that the object allocators will try hard not to
allocate anything outside the walls defined by cpuset. Which means that
if you have one process per node, and they are hardwalled, your kernel
memory will be spread evenly among the machine. With a big enough load,
they should eventually be present in all blocks.

Another question I have for you: Have you considering calling
shrink_slab to try to deplete the caches and therefore free at least
slab memory in the nodes that can't be offlined? Is it relevant?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
