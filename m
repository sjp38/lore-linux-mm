Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6F77D6B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 04:57:19 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so1106093pdj.27
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 01:57:19 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id x8si3732942pde.76.2014.10.24.01.57.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 24 Oct 2014 01:57:18 -0700 (PDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDX00E9LY7FCX70@mailout1.samsung.com> for linux-mm@kvack.org;
 Fri, 24 Oct 2014 17:57:15 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
 <1413986796-19732-1-git-send-email-pintu.k@samsung.com>
 <1413986796-19732-2-git-send-email-pintu.k@samsung.com>
 <54484993.1090803@lge.com>
In-reply-to: <54484993.1090803@lge.com>
Subject: RE: [PATCH v2 2/2] fs: proc: Include cma info in proc/meminfo
Date: Fri, 24 Oct 2014 14:27:09 +0530
Message-id: <018a01cfef68$88d0b450$9a721cf0$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=ks_c_5601-1987
Content-transfer-encoding: quoted-printable
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Gioh Kim' <gioh.kim@lge.com>, akpm@linux-foundation.org, riel@redhat.com, aquini@redhat.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lcapitulino@redhat.com, kirill.shutemov@linux.intel.com, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, mina86@mina86.com, lauraa@codeaurora.org, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: pintu_agarwal@yahoo.com, cpgs@samsung.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com

Hi,

----- Original Message -----
> From: Gioh Kim <gioh.kim@lge.com>
> To: Pintu Kumar <pintu.k@samsung.com>; akpm@linux-foundation.org;
riel@redhat.com; aquini@redhat.com; paul.gortmaker@windriver.com;
jmarchan@redhat.com; lcapitulino@redhat.com;
kirill.shutemov@linux.intel.com; m.szyprowski@samsung.com;
aneesh.kumar@linux.vnet.ibm.com; iamjoonsoo.kim@lge.com; =
mina86@mina86.com;
lauraa@codeaurora.org; mgorman@suse.de; rientjes@google.com; =
hannes@cmpxchg.
org; vbabka@suse.cz; sasha.levin@oracle.com; =
linux-kernel@vger.kernel.org;
linux-mm@kvack.org
> Cc: pintu_agarwal@yahoo.com; cpgs@samsung.com; vishnu.ps@samsung.com;
rohit.kr@samsung.com; ed.savinay@samsung.com
> Sent: Thursday, 23 October 2014 5:49 AM
> Subject: Re: [PATCH v2 2/2] fs: proc: Include cma info in proc/meminfo
>=20
>=20
>=20
> 2014-10-22 =BF=C0=C8=C4 11:06, Pintu Kumar =BE=B4 =B1=DB:
>> This patch include CMA info (CMATotal, CMAFree) in /proc/meminfo.
>> Currently, in a CMA enabled system, if somebody wants to know the
>> total CMA size declared, there is no way to tell, other than the =
dmesg
>> or /var/log/messages logs.
>> With this patch we are showing the CMA info as part of meminfo, so =
that
>> it can be determined at any point of time.
>> This will be populated only when CMA is enabled.
>>=20
>> Below is the sample output from a ARM based device with RAM:512MB and =

> CMA:16MB.
>>=20
>> MemTotal:        471172 kB
>> MemFree:          111712 kB
>> MemAvailable:    271172 kB
>> .
>> .
>> .
>> CmaTotal:          16384 kB
>> CmaFree:            6144 kB
>>=20
>> This patch also fix below checkpatch errors that were found during =
these=20
> changes.
>=20
> Why don't you split patch for it?
> I think there's a rule not to mix separate patchs.
>=20

Last time when we submitted separate patches for checkpatch errors, it =
was
suggested to=20
Include these kinds of fixes along with some meaningful patches =
together.
So, we included it in same patch.

>>=20
>> ERROR: space required after that ',' (ctx:ExV)
>> 199: FILE: fs/proc/meminfo.c:199:
>> +      ,atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT -=20
> 10)
>>           ^
>>=20
>> ERROR: space required after that ',' (ctx:ExV)
>> 202: FILE: fs/proc/meminfo.c:202:
>> +      ,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
>>           ^
>>=20
>> ERROR: space required after that ',' (ctx:ExV)
>> 206: FILE: fs/proc/meminfo.c:206:
>> +      ,K(totalcma_pages)
>>           ^
>>=20
>> total: 3 errors, 0 warnings, 2 checks, 236 lines checked
>>=20
>> Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
>> Signed-off-by: Vishnu Pratap Singh <vishnu.ps@samsung.com>
>> ---
>>   fs/proc/meminfo.c |  15 +++++++++++++--
>>   1 file changed, 13 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
>> index aa1eee0..d3ebf2e 100644
>> --- a/fs/proc/meminfo.c
>> +++ b/fs/proc/meminfo.c
>> @@ -12,6 +12,9 @@
>>   #include <linux/vmstat.h>
>>   #include <linux/atomic.h>
>>   #include <linux/vmalloc.h>
>> +#ifdef CONFIG_CMA
>> +#include <linux/cma.h>
>> +#endif
>>   #include <asm/page.h>
>>   #include <asm/pgtable.h>
>>   #include "internal.h"
>> @@ -138,6 +141,10 @@ static int meminfo_proc_show(struct seq_file *m,
void=20
> *v)
>>   #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>>           "AnonHugePages:  %8lu kB\n"
>>   #endif
>> +#ifdef CONFIG_CMA
>> +        "CmaTotal:      %8lu kB\n"
>> +        "CmaFree:        %8lu kB\n"
>> +#endif
>>           ,
>>           K(i.totalram),
>>           K(i.freeram),
>> @@ -187,12 +194,16 @@ static int meminfo_proc_show(struct seq_file =
*m,
void=20
> *v)
>>           vmi.used >> 10,
>>           vmi.largest_chunk >> 10
>>   #ifdef CONFIG_MEMORY_FAILURE
>> -        ,atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT -=20
> 10)
>> +        , atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT -=20
> 10)
>>   #endif
>>   #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> -        ,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
>> +        , K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
>>             HPAGE_PMD_NR)
>>   #endif
>> +#ifdef CONFIG_CMA
>> +        , K(totalcma_pages)
>> +        , K(global_page_state(NR_FREE_CMA_PAGES))
>> +#endif
>>           );
>=20
> Just for sure, are zoneinfo and pagetypeinfo not suitable?
>=20

I think zoneinfo shows only current free cma pages.
Same is the case with vmstat.
# cat /proc/zoneinfo | grep cma
    nr_free_cma  2560
# cat /proc/vmstat | grep cma
nr_free_cma 2560

> I don't know HOTPLUG feature so I'm just asking for sure.
> Does HOTPLUG not need printing message like this?
>=20

Sorry, I am also not sure what hotplug feature you are referring to.

> Thanks a lot.
>=20
>=20
>>  =20
>>       hugetlb_report_meminfo(m);
>>=20
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org">=20
> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
