Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 838316B0062
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 21:47:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 55E603EE0BC
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 10:47:15 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 355A245DEC0
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 10:47:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BD9245DEBC
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 10:47:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 06F9C1DB8042
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 10:47:15 +0900 (JST)
Received: from g01jpexchkw06.g01.fujitsu.local (g01jpexchkw06.g01.fujitsu.local [10.0.194.45])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B34281DB803B
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 10:47:14 +0900 (JST)
Message-ID: <504D467D.2080201@jp.fujitsu.com>
Date: Mon, 10 Sep 2012 10:46:37 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v8 PATCH 00/20] memory-hotplug: hot-remove physical memory
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com> <20120831134956.fec0f681.akpm@linux-foundation.org>
In-Reply-To: <20120831134956.fec0f681.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com

Hi Wen,

2012/09/01 5:49, Andrew Morton wrote:
> On Tue, 28 Aug 2012 18:00:07 +0800
> wency@cn.fujitsu.com wrote:
>
>> This patch series aims to support physical memory hot-remove.
>
> Have you had much review and testing feedback yet?
>
>> The patches can free/remove the following things:
>>
>>    - acpi_memory_info                          : [RFC PATCH 4/19]
>>    - /sys/firmware/memmap/X/{end, start, type} : [RFC PATCH 8/19]
>>    - iomem_resource                            : [RFC PATCH 9/19]
>>    - mem_section and related sysfs files       : [RFC PATCH 10-11, 13-16/19]
>>    - page table of removed memory              : [RFC PATCH 12/19]
>>    - node and related sysfs files              : [RFC PATCH 18-19/19]
>>
>> If you find lack of function for physical memory hot-remove, please let me
>> know.
>

> I doubt if many people have hardware which permits physical memory
> removal?  How would you suggest that people with regular hardware can
> test these chagnes?

How do you test the patch? As Andrew says, for hot-removing memory,
we need a particular hardware. I think so too. So many people may want
to know how to test the patch.
If we apply following patch to kvm guest, can we hot-remove memory on
kvm guest?

http://lists.gnu.org/archive/html/qemu-devel/2012-07/msg01389.html

Thanks,
Yasuaki Ishimatsu

>
>> Known problems:
>> 1. memory can't be offlined when CONFIG_MEMCG is selected.
>
> That's quite a problem!  Do you have a description of why this is the
> case, and a plan for fixing it?
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
