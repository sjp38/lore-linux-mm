Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 972F26B005D
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 21:56:02 -0400 (EDT)
Message-ID: <504D4A08.7090602@cn.fujitsu.com>
Date: Mon, 10 Sep 2012 10:01:44 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v8 PATCH 00/20] memory-hotplug: hot-remove physical memory
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com> <20120831134956.fec0f681.akpm@linux-foundation.org> <504D467D.2080201@jp.fujitsu.com>
In-Reply-To: <504D467D.2080201@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com

At 09/10/2012 09:46 AM, Yasuaki Ishimatsu Wrote:
> Hi Wen,
> 
> 2012/09/01 5:49, Andrew Morton wrote:
>> On Tue, 28 Aug 2012 18:00:07 +0800
>> wency@cn.fujitsu.com wrote:
>>
>>> This patch series aims to support physical memory hot-remove.
>>
>> Have you had much review and testing feedback yet?
>>
>>> The patches can free/remove the following things:
>>>
>>>    - acpi_memory_info                          : [RFC PATCH 4/19]
>>>    - /sys/firmware/memmap/X/{end, start, type} : [RFC PATCH 8/19]
>>>    - iomem_resource                            : [RFC PATCH 9/19]
>>>    - mem_section and related sysfs files       : [RFC PATCH 10-11,
>>> 13-16/19]
>>>    - page table of removed memory              : [RFC PATCH 12/19]
>>>    - node and related sysfs files              : [RFC PATCH 18-19/19]
>>>
>>> If you find lack of function for physical memory hot-remove, please
>>> let me
>>> know.
>>
> 
>> I doubt if many people have hardware which permits physical memory
>> removal?  How would you suggest that people with regular hardware can
>> test these chagnes?
> 
> How do you test the patch? As Andrew says, for hot-removing memory,
> we need a particular hardware. I think so too. So many people may want
> to know how to test the patch.
> If we apply following patch to kvm guest, can we hot-remove memory on
> kvm guest?
> 
> http://lists.gnu.org/archive/html/qemu-devel/2012-07/msg01389.html

Yes, if we apply this patchset, we can test hot-remove memory on kvm guest.
But that patchset doesn't implement _PS3, so there is some restriction.

Thanks
Wen Congyang

> 
> Thanks,
> Yasuaki Ishimatsu
> 
>>
>>> Known problems:
>>> 1. memory can't be offlined when CONFIG_MEMCG is selected.
>>
>> That's quite a problem!  Do you have a description of why this is the
>> case, and a plan for fixing it?
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
