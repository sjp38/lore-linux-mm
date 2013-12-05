Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8B16B0039
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 12:28:22 -0500 (EST)
Received: by mail-ve0-f182.google.com with SMTP id jy13so13939090veb.41
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 09:28:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v5si35123108ves.42.2013.12.05.09.28.20
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 09:28:21 -0800 (PST)
Message-ID: <52A0B786.608@redhat.com>
Date: Thu, 05 Dec 2013 12:27:34 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V2 3/5] mm: Move change_prot_numa outside CONFIG_ARCH_USES_NUMA_PROT_NONE
References: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>	 <1384766893-10189-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1386126782.16703.137.camel@pasglop>
In-Reply-To: <1386126782.16703.137.camel@pasglop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On 12/03/2013 10:13 PM, Benjamin Herrenschmidt wrote:
> On Mon, 2013-11-18 at 14:58 +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>
>> change_prot_numa should work even if _PAGE_NUMA != _PAGE_PROTNONE.
>> On archs like ppc64 that don't use _PAGE_PROTNONE and also have
>> a separate page table outside linux pagetable, we just need to
>> make sure that when calling change_prot_numa we flush the
>> hardware page table entry so that next page access  result in a numa
>> fault.
>
> That patch doesn't look right...

At first glance, indeed...

> You are essentially making change_prot_numa() do whatever it does (which
> I don't completely understand) *for all architectures* now, whether they
> have CONFIG_ARCH_USES_NUMA_PROT_NONE or not ... So because you want that
> behaviour on powerpc book3s64, you change everybody.

However, it appears that since the code was #ifdefed
like that, the called code was made generic enough,
that change_prot_numa should actually work for
everything.

In other words:

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
