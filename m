Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id D87EE6B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 02:57:22 -0500 (EST)
Message-ID: <51135E33.4060508@cn.fujitsu.com>
Date: Thu, 07 Feb 2013 15:56:35 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 01/14] memory-hotplug: try to offline the memory twice
 to avoid dependence
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-2-git-send-email-tangchen@cn.fujitsu.com> <50D96543.6010903@parallels.com> <50DFD7F7.5090408@cn.fujitsu.com> <50ED8834.1090804@parallels.com> <5111C8EB.6090805@cn.fujitsu.com> <51121FB7.1070205@cn.fujitsu.com> <51122C1D.5020002@cn.fujitsu.com> <5112679A.7080600@parallels.com>
In-Reply-To: <5112679A.7080600@parallels.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Miao Xie <miaox@cn.fujitsu.com>

On 02/06/2013 10:24 PM, Glauber Costa wrote:
>>>> And one more question, a memory section is 128MB in Linux. If we reserve
>>>> part of the them for page_cgroup,
>>>> then anyone who wants to allocate a contiguous memory larger than 128MB,
>>>> it will fail, right ?
>>>> Is it OK ?
> No, it is not.
>
> Another take on this: Can't we free all the page_cgroup structure before
> we actually start removing the sections ? If we do this, we would be
> basically left with no problem at all, since when your code starts
> running we would no longer have any page_cgroup allocated.
>
> All you have to guarantee is that it happens after the memory block is
> already isolated and allocations no longer can reach it.
>
> What do you think ?

Hi Glauber,

I don't think so. We can offline some of the sections and leave the 
reset online.

For example, we store page_cgroups of memory9~11 in memory8. So when we 
offline memory8,
we free memory8's page_cgroup storing on other section, but we cannot 
free the page_cgroups
being stored in memory8 if memory9~11 are left online.

So we still need to offline memory9~11, and then offline memory8, right ?
I think it makes no difference.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
