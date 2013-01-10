Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 05DAE6B0071
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 21:19:28 -0500 (EST)
Message-ID: <50EE2500.2040903@cn.fujitsu.com>
Date: Thu, 10 Jan 2013 10:18:40 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com> <20130109153324.bbd019b3.akpm@linux-foundation.org>
In-Reply-To: <20130109153324.bbd019b3.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Hi Andrew,

On 01/10/2013 07:33 AM, Andrew Morton wrote:
> On Wed, 9 Jan 2013 17:32:24 +0800
> Tang Chen<tangchen@cn.fujitsu.com>  wrote:
>
>> This patch-set aims to implement physical memory hot-removing.
>
> As you were on th patch delivery path, all of these patches should have
> your Signed-off-by:.  But some were missing it.  I fixed this in my
> copy of the patches.

Thank you very much for the help. Next time I'll add it myself.

>
>
> I suspect this patchset adds a significant amount of code which will
> not be used if CONFIG_MEMORY_HOTPLUG=n.  "[PATCH v6 06/15]
> memory-hotplug: implement register_page_bootmem_info_section of
> sparse-vmemmap", for example.  This is not a good thing, so please go
> through the patchset (in fact, go through all the memhotplug code) and
> let's see if we can reduce the bloat for CONFIG_MEMORY_HOTPLUG=n
> kernels.
>
> This needn't be done immediately - it would be OK by me if you were to
> defer this exercise until all the new memhotplug code is largely in
> place.  But please, let's do it.

OK, I'll do have a check on it when the page_cgroup problem is solved.

Thanks. :)

>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
