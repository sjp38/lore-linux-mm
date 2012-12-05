Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 22A216B006C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 21:08:35 -0500 (EST)
Message-ID: <50BEAC66.8020500@cn.fujitsu.com>
Date: Wed, 05 Dec 2012 10:07:34 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch v4 08/12] memory-hotplug: remove memmap of sparse-vmemmap
References: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com> <1354010422-19648-9-git-send-email-wency@cn.fujitsu.com> <50B5DC00.20103@huawei.com> <50B80FB1.6040906@cn.fujitsu.com> <50BC0D2D.8040008@huawei.com> <50BDBEB7.3070807@cn.fujitsu.com> <50BDEA82.4050809@huawei.com>
In-Reply-To: <50BDEA82.4050809@huawei.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Hi Wu,

On 12/04/2012 08:20 PM, Jianguo Wu wrote:
(snip)
>>
>> Seems that we have different ways to handle pages allocated by bootmem
>> or by regular allocator. Is the checking way in [PATCH 09/12] available
>> here ?
>>
>> +    /* bootmem page has reserved flag */
>> +    if (PageReserved(page)) {
>> ......
>> +    }
>>
>> If so, I think we can just merge these two functions.
>
> Hmm, direct mapping table isn't allocated by bootmem allocator such as memblock, can't be free by put_page_bootmem().
> But I will try to merge these two functions.
>

Oh, I didn't notice this, thanks. :)

(snip)

>>> +
>>> +    __split_large_page(kpte, address, pbase);
>>
>> Is this patch going to replace [PATCH 08/12] ?
>>
>
> I wish to replace [PATCH 08/12], but need Congyang and Yasuaki to confirm first:)
>
>> If so, __split_large_page() was added and exported in [PATCH 09/12],
>> then we should move it here, right ?
>
> yes.
>
> and what do you think about moving vmemmap_pud[pmd/pte]_remove() to arch/x86/mm/init_64.c,
> to be consistent with vmemmap_populate() ?

It is a good idea since pud/pmd/pte related code could be platform
dependent. And I'm also trying to move vmemmap_free() to
arch/x86/mm/init_64.c too. I want to have a common interface just
like vmemmap_populate(). :)

>
> I will rework [PATCH 08/12] and [PATCH 09/12] soon.

I am rebasing the whole patch set now. And I think I chould finish part
of your work too. A new patch-set is coming soon, and your rework is
also welcome. :)

Thanks. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
