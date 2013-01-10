Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 6FF806B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 21:26:44 -0500 (EST)
Message-ID: <50EE26B4.40204@cn.fujitsu.com>
Date: Thu, 10 Jan 2013 10:25:56 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 05/15] memory-hotplug: introduce new function arch_remove_memory()
 for removing page table depends on architecture
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com> <1357723959-5416-6-git-send-email-tangchen@cn.fujitsu.com> <20130109145031.210505d0.akpm@linux-foundation.org>
In-Reply-To: <20130109145031.210505d0.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Hi Andrew,

On 01/10/2013 06:50 AM, Andrew Morton wrote:
> On Wed, 9 Jan 2013 17:32:29 +0800
> Tang Chen<tangchen@cn.fujitsu.com>  wrote:
>
>> For removing memory, we need to remove page table. But it depends
>> on architecture. So the patch introduce arch_remove_memory() for
>> removing page table. Now it only calls __remove_pages().
>>
>> Note: __remove_pages() for some archtecuture is not implemented
>>        (I don't know how to implement it for s390).
>
> Can this break the build for s390?

No, I don't think so. The arch_remove_memory() in s390 will only
return -EBUSY.

Thanks. :)

>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
