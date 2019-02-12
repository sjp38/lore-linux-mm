Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99127C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 20:34:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36AC721B68
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 20:34:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="08pkvsLL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36AC721B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAB798E0003; Tue, 12 Feb 2019 15:34:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C59E48E0001; Tue, 12 Feb 2019 15:34:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B49A08E0003; Tue, 12 Feb 2019 15:34:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77EBB8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 15:34:30 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id i11so28942pgb.8
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:34:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=alEBznvGMT0os8XtyC5Lyg/C71RyrgZq/tVkGY4Nvvc=;
        b=TB6fYyxZgyv/KA//VGR2XtVkpxAPdbK6RQQMdIVV9n1UWh4Cc2G/ByXi78RsQbnq/f
         b4wtX+blAXME3BnWlsHfi3ebqehRxVE7a1x5MoJwjE8o93GCqOUid/7PRwxyhsohv65b
         joOAyn88o+ytftPaHDrEps0ZZ1asPhG82hCANXd7l3FI6VdnFH9Dk/t4nl0xKrkW3nre
         zboNXFNA2rU/PmCd8cR6YTLSI3AVPEL/xygeuMnJFvZUn72viV+4tcAcMA7j0wlrtfEd
         fMqkU/O2kPW7cAUhmcylCXWMaqUs+hpa0j3rj4Gzw+rVlW7nNtD22psnAwU0L7UDtFzc
         3Uew==
X-Gm-Message-State: AHQUAuabaCxfMSSVYNBjGow92JlbLQO3sqrUOSkvqnBReMXYztdvMCUh
	UTbry01drKDV3p65W1hfKhRohzf8EuI2upLWiiJ/HxtH4eL8wI5AM7tP1Qru4I/2aW8XXuUO/I5
	7Z0J8n3y4KBgketRsOmaRKMGMGbeqJKkW4U4DeqL54giVsU9u4Hqx5E3opaJBspWO9Q==
X-Received: by 2002:a17:902:6909:: with SMTP id j9mr5711444plk.196.1550003670143;
        Tue, 12 Feb 2019 12:34:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZXH5NQfMGHqasAeZDayVerolwJ/8RQeh/KtCrJuD3fRlRoFgzOvZYIL2UMr1HcI8Thc3HA
X-Received: by 2002:a17:902:6909:: with SMTP id j9mr5711394plk.196.1550003669446;
        Tue, 12 Feb 2019 12:34:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550003669; cv=none;
        d=google.com; s=arc-20160816;
        b=igC14WTBHg8RDSS6+HiErdzZN//qrmMIA+ZzV+2LjLgMR2Ki8FdnIpFKpv/Wicvz27
         QGzljSnXLCIVrsUY0dbtyVPlxDaHv5vfjMZJunwGWukPyQPPQG2f98EvyrLA6PJPs9a8
         shDZHbqLetZwLGNILoO/ImKnwD94F0PNA6MDn6qDyPg9grw/KHVNC300DYlg3MB/214f
         WYR9h/qHNvBXuf1/0zPIPrSdxHJDfka22FN91E9zikOqyK6LFS0AzYpL3MsRW1aNRgEr
         8HMHJGjiA/Fu9oXBL2bvKdicdXlLr4PJOdIqqskoTCxzbfo2Pu27iFCN6gZT2FUXhUqY
         ACdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:organization:from:references:cc:to:subject
         :dkim-signature;
        bh=alEBznvGMT0os8XtyC5Lyg/C71RyrgZq/tVkGY4Nvvc=;
        b=DOVinf4/BIDG623JWJ9IiTNq4k0btJVjTfvmaR+zo1Kr6mu+DGY5nPM71sErz0EK0f
         iai7SKrqOjX9o0M5tZQgp851WCL8Tn4AQl8z58v2nMJYp8nnWUBXGhQRuYFjmZK7tOyO
         y+Ubj2jW7OjALEZNNIT+9RWlG2scIJdAJh5Mh0LvHL256TIRYVOGOnHB8dMPRIYoYYgK
         TRaDIfo3K2jgv/2+NOIXP/OnsfYqTaXdZlkEQQYVvZRRA/3kVzRrDRuhZBVzqeSy+/1d
         DsvEYvqk8IpWh2gOrTj+MpcGRcLdoHNIOdyrShZNMNPqAA0/OjINzlL00CtIqBpZUhug
         s+/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=08pkvsLL;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d38si14142498pla.207.2019.02.12.12.34.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 12:34:29 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=08pkvsLL;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1CKXeQg151654;
	Tue, 12 Feb 2019 20:34:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type; s=corp-2018-07-02;
 bh=alEBznvGMT0os8XtyC5Lyg/C71RyrgZq/tVkGY4Nvvc=;
 b=08pkvsLL8yu9g3BdPIfIurrc64y1Ln77iM1QXqaIjjvZcTQjYHnhWxMJMTLYMQ0lj1GS
 W2DZO9ib5t4zAgcU7qjHV/bLJ3vg+qt928F6COlvWq2j7MupJSLtW4gpXkxJgtkKjzbP
 NG4BnyZpV+LV2nFLbeBsHgPycTPKeqKmRU5UoVCWu6N/BNZo8wOF0EODerzSwwLFE5gE
 +rJ06R0Mx0DW9UElAzckFhg5FLSRhWeJk1w3Po38cHc4dfgkZM2JmgpPKGAfFK3pz/SS
 EuBjICWKcq1xDG0/bsNQU/6q96iciP3JYs6HXnZTlaxu0Yxg0JNMj20IoL6+8mO6fSSD aA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2qhreke9t9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 20:34:22 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1CKYLO8020346
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 20:34:21 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1CKYI7Q015599;
	Tue, 12 Feb 2019 20:34:19 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 12 Feb 2019 12:34:18 -0800
Subject: Re: [RFC PATCH v7 05/16] arm64/mm: Add support for XPFO
To: Laura Abbott <labbott@redhat.com>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Tycho Andersen <tycho@docker.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <89f03091af87f5ab27bd6cafb032236d5bd81d65.1547153058.git.khalid.aziz@oracle.com>
 <20190123142410.GC19289@Konrads-MacBook-Pro.local>
 <4dfba458-1bf6-25ff-df4c-b96a1221cd95@oracle.com>
 <7497bd44-1fda-e073-ba7f-18a76577b64a@redhat.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <76668db0-e87a-5294-1d71-2ab42a48425c@oracle.com>
Date: Tue, 12 Feb 2019 13:34:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <7497bd44-1fda-e073-ba7f-18a76577b64a@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------9CCCB4AA5B3B70FD078792E2"
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9165 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902120143
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------9CCCB4AA5B3B70FD078792E2
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 2/12/19 1:01 PM, Laura Abbott wrote:
> On 2/12/19 7:52 AM, Khalid Aziz wrote:
>> On 1/23/19 7:24 AM, Konrad Rzeszutek Wilk wrote:
>>> On Thu, Jan 10, 2019 at 02:09:37PM -0700, Khalid Aziz wrote:
>>>> From: Juerg Haefliger <juerg.haefliger@canonical.com>
>>>>
>>>> Enable support for eXclusive Page Frame Ownership (XPFO) for arm64 a=
nd
>>>> provide a hook for updating a single kernel page table entry (which =
is
>>>> required by the generic XPFO code).
>>>>
>>>> v6: use flush_tlb_kernel_range() instead of __flush_tlb_one()
>>>>
>>>> CC: linux-arm-kernel@lists.infradead.org
>>>> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
>>>> Signed-off-by: Tycho Andersen <tycho@docker.com>
>>>> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
>>>> ---
>>>> =C2=A0 arch/arm64/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 1 +
>>>> =C2=A0 arch/arm64/mm/Makefile |=C2=A0 2 ++
>>>> =C2=A0 arch/arm64/mm/xpfo.c=C2=A0=C2=A0 | 58
>>>> ++++++++++++++++++++++++++++++++++++++++++
>>>> =C2=A0 3 files changed, 61 insertions(+)
>>>> =C2=A0 create mode 100644 arch/arm64/mm/xpfo.c
>>>>
>>>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>>>> index ea2ab0330e3a..f0a9c0007d23 100644
>>>> --- a/arch/arm64/Kconfig
>>>> +++ b/arch/arm64/Kconfig
>>>> @@ -171,6 +171,7 @@ config ARM64
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 select SWIOTLB
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 select SYSCTL_EXCEPTION_TRACE
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 select THREAD_INFO_IN_TASK
>>>> +=C2=A0=C2=A0=C2=A0 select ARCH_SUPPORTS_XPFO
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 help
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ARM 64-bit (AArch64) Linu=
x support.
>>>> =C2=A0 diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
>>>> index 849c1df3d214..cca3808d9776 100644
>>>> --- a/arch/arm64/mm/Makefile
>>>> +++ b/arch/arm64/mm/Makefile
>>>> @@ -12,3 +12,5 @@ KASAN_SANITIZE_physaddr.o=C2=A0=C2=A0=C2=A0 +=3D n=

>>>> =C2=A0 =C2=A0 obj-$(CONFIG_KASAN)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 +=3D kasan_init.o
>>>> =C2=A0 KASAN_SANITIZE_kasan_init.o=C2=A0=C2=A0=C2=A0 :=3D n
>>>> +
>>>> +obj-$(CONFIG_XPFO)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 +=3D x=
pfo.o
>>>> diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
>>>> new file mode 100644
>>>> index 000000000000..678e2be848eb
>>>> --- /dev/null
>>>> +++ b/arch/arm64/mm/xpfo.c
>>>> @@ -0,0 +1,58 @@
>>>> +/*
>>>> + * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
>>>> + * Copyright (C) 2016 Brown University. All rights reserved.
>>>> + *
>>>> + * Authors:
>>>> + *=C2=A0=C2=A0 Juerg Haefliger <juerg.haefliger@hpe.com>
>>>> + *=C2=A0=C2=A0 Vasileios P. Kemerlis <vpk@cs.brown.edu>
>>>> + *
>>>> + * This program is free software; you can redistribute it and/or
>>>> modify it
>>>> + * under the terms of the GNU General Public License version 2 as
>>>> published by
>>>> + * the Free Software Foundation.
>>>> + */
>>>> +
>>>> +#include <linux/mm.h>
>>>> +#include <linux/module.h>
>>>> +
>>>> +#include <asm/tlbflush.h>
>>>> +
>>>> +/*
>>>> + * Lookup the page table entry for a virtual address and return a
>>>> pointer to
>>>> + * the entry. Based on x86 tree.
>>>> + */
>>>> +static pte_t *lookup_address(unsigned long addr)
>>>> +{
>>>> +=C2=A0=C2=A0=C2=A0 pgd_t *pgd;
>>>> +=C2=A0=C2=A0=C2=A0 pud_t *pud;
>>>> +=C2=A0=C2=A0=C2=A0 pmd_t *pmd;
>>>> +
>>>> +=C2=A0=C2=A0=C2=A0 pgd =3D pgd_offset_k(addr);
>>>> +=C2=A0=C2=A0=C2=A0 if (pgd_none(*pgd))
>>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return NULL;
>>>> +
>>>> +=C2=A0=C2=A0=C2=A0 pud =3D pud_offset(pgd, addr);
>>>> +=C2=A0=C2=A0=C2=A0 if (pud_none(*pud))
>>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return NULL;
>>>> +
>>>> +=C2=A0=C2=A0=C2=A0 pmd =3D pmd_offset(pud, addr);
>>>> +=C2=A0=C2=A0=C2=A0 if (pmd_none(*pmd))
>>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return NULL;
>>>> +
>>>> +=C2=A0=C2=A0=C2=A0 return pte_offset_kernel(pmd, addr);
>>>> +}
>>>> +
>>>> +/* Update a single kernel page table entry */
>>>> +inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)=

>>>> +{
>>>> +=C2=A0=C2=A0=C2=A0 pte_t *pte =3D lookup_address((unsigned long)kad=
dr);
>>>> +
>>>> +=C2=A0=C2=A0=C2=A0 set_pte(pte, pfn_pte(page_to_pfn(page), prot));
>>>
>>> Thought on the other hand.. what if the page is PMD? Do you really wa=
nt
>>> to do this?
>>>
>>> What if 'pte' is NULL?
>>>> +}
>>>> +
>>>> +inline void xpfo_flush_kernel_tlb(struct page *page, int order)
>>>> +{
>>>> +=C2=A0=C2=A0=C2=A0 unsigned long kaddr =3D (unsigned long)page_addr=
ess(page);
>>>> +=C2=A0=C2=A0=C2=A0 unsigned long size =3D PAGE_SIZE;
>>>> +
>>>> +=C2=A0=C2=A0=C2=A0 flush_tlb_kernel_range(kaddr, kaddr + (1 << orde=
r) * size);
>>>
>>> Ditto here. You are assuming it is PTE, but it may be PMD or such.
>>> Or worts - the lookup_address could be NULL.
>>>
>>>> +}
>>>> --=C2=A0
>>>> 2.17.1
>>>>
>>
>> Hi Konrad,
>>
>> This makes sense. x86 version of set_kpte() checks pte for NULL and al=
so
>> checks if the page is PMD. Now what you said about adding level to
>> lookup_address() for arm makes more sense.
>>
>> Can someone with knowledge of arm64 mmu make recommendations here?
>>
>> Thanks,
>> Khalid
>>
>=20
> arm64 can't split larger pages and requires everything must be
> mapped as pages (see [RFC PATCH v7 08/16] arm64/mm: disable
> section/contiguous mappings if XPFO is enabled) . Any
> situation where we would get something other than a pte
> would be a bug.

Thanks, Laura! That helps a lot. I would think checking for NULL pte in
set_kpte() would still make sense since lookup_address() can return
NULL. Something like:

--- arch/arm64/mm/xpfo.c	2019-01-30 13:36:39.857185612 -0700
+++ arch/arm64/mm/xpfo.c.new	2019-02-12 13:26:47.471633031 -0700
@@ -46,6 +46,11 @@
 {
 	pte_t *pte =3D lookup_address((unsigned long)kaddr);

+	if (unlikely(!pte)) {
+		WARN(1, "xpfo: invalid address %p\n", kaddr);
+		return;
+	}
+
 	set_pte(pte, pfn_pte(page_to_pfn(page), prot));
 }

--
Khalid

--------------9CCCB4AA5B3B70FD078792E2
Content-Type: application/pgp-keys;
 name="pEpkey.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="pEpkey.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----

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
+Wrj8Rwom6h21PXZRKnlkis7ibQfE+TxqOI7vg=3D=3D
=3DnPqY
-----END PGP PUBLIC KEY BLOCK-----

--------------9CCCB4AA5B3B70FD078792E2--

