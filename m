Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 074516B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 12:53:22 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id f11so27642qae.5
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 09:53:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ej3si30960692qab.82.2013.12.05.09.53.21
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 09:53:22 -0800 (PST)
Message-ID: <52A0BD6E.4090401@redhat.com>
Date: Thu, 05 Dec 2013 12:52:46 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V2 3/5] mm: Move change_prot_numa outside CONFIG_ARCH_USES_NUMA_PROT_NONE
References: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>	 <1384766893-10189-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>	 <1386126782.16703.137.camel@pasglop> <87a9gfri3u.fsf@linux.vnet.ibm.com> <1386220835.21910.21.camel@pasglop>
In-Reply-To: <1386220835.21910.21.camel@pasglop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On 12/05/2013 12:20 AM, Benjamin Herrenschmidt wrote:
> On Thu, 2013-12-05 at 10:48 +0530, Aneesh Kumar K.V wrote:
>>
>> Ok, I can move the changes below #ifdef CONFIG_NUMA_BALANCING ? We call
>> change_prot_numa from task_numa_work and queue_pages_range(). The later
>> may be an issue. So doing the below will help ?
>>
>> -#ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
>> +#ifdef CONFIG_NUMA_BALANCING
>
> I will defer to Mel and Rik (should we also CC Andrea ?)

It looks like manual numa binding can also use lazy
page migration, but I am not sure if that can happen
without CONFIG_NUMA_BALANCING, or if mbind always uses
MPOL_MF_STRICT...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
