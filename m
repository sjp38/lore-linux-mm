Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 862766B0661
	for <linux-mm@kvack.org>; Fri, 11 May 2018 03:17:22 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t3-v6so3686604qto.14
        for <linux-mm@kvack.org>; Fri, 11 May 2018 00:17:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z16-v6si478653qtg.153.2018.05.11.00.17.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 May 2018 00:17:21 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4B7F6NJ061915
	for <linux-mm@kvack.org>; Fri, 11 May 2018 03:17:20 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hw4xnv20x-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 11 May 2018 03:17:19 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 11 May 2018 08:17:17 +0100
Date: Fri, 11 May 2018 10:17:05 +0300
In-Reply-To: <91e95111-eb0c-205b-722b-18016da93c04@infradead.org>
References: <20180510172842.2619e058@canb.auug.org.au> <e55fad49-6c19-7c43-ef37-eb148bd3d55d@infradead.org> <20180510134825.372f4a7ec17ce3e945640ac2@linux-foundation.org> <91e95111-eb0c-205b-722b-18016da93c04@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: linux-next: Tree for May 10 (mm/ksm.c)
From: Mike Rapoprt <rppt@linux.vnet.ibm.com>
Message-Id: <5574BF43-F2BB-4A19-BCCE-37F402DCED06@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Linux-Next Mailing List <linux-next@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>



On May 11, 2018 1:03:04 AM GMT+03:00, Randy Dunlap <rdunlap@infradead=2Eor=
g> wrote:
>On 05/10/2018 01:48 PM, Andrew Morton wrote:
>> On Thu, 10 May 2018 09:37:51 -0700 Randy Dunlap
><rdunlap@infradead=2Eorg> wrote:
>>=20
>>> On 05/10/2018 12:28 AM, Stephen Rothwell wrote:
>>>> Hi all,
>>>>
>>>> Changes since 20180509:
>>>>
>>>
>>> on i386:
>>>
>>> =2E=2E/mm/ksm=2Ec: In function 'try_to_merge_one_page':
>>> =2E=2E/mm/ksm=2Ec:1244:4: error: implicit declaration of function
>'set_page_stable_node' [-Werror=3Dimplicit-function-declaration]
>>>     set_page_stable_node(page, NULL);

Oops, missed that, sorry=2E

>> Thanks=2E
>>=20
>> From: Andrew Morton <akpm@linux-foundation=2Eorg>
>> Subject: mm-ksm-move-page_stable_node-from-ksmh-to-ksmc-fix
>>=20
>> fix SYSFS=3Dn build
>>=20
>> Cc: Andrea Arcangeli <aarcange@redhat=2Ecom>
>> Cc: Mike Rapoport <rppt@linux=2Evnet=2Eibm=2Ecom>
>> Cc: Randy Dunlap <rdunlap@infradead=2Eorg>
>
>Acked-by: Randy Dunlap <rdunlap@infradead=2Eorg>
>Reported-by: Randy Dunlap <rdunlap@infradead=2Eorg>
>Tested-by: Randy Dunlap <rdunlap@infradead=2Eorg>

Acked-by: Mike Rapoport <rppt@linux=2Evnet=2Eibm=2Ecom>

>> Cc: Stephen Rothwell <sfr@canb=2Eauug=2Eorg=2Eau>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation=2Eorg>
>> ---
>>=20
>>  mm/ksm=2Ec |    9 ++++-----
>>  1 file changed, 4 insertions(+), 5 deletions(-)
>>=20
>> diff -puN
>include/linux/ksm=2Eh~mm-ksm-move-page_stable_node-from-ksmh-to-ksmc-fix
>include/linux/ksm=2Eh
>> diff -puN mm/ksm=2Ec~mm-ksm-move-page_stable_node-from-ksmh-to-ksmc-fix
>mm/ksm=2Ec
>> --- a/mm/ksm=2Ec~mm-ksm-move-page_stable_node-from-ksmh-to-ksmc-fix
>> +++ a/mm/ksm=2Ec
>> @@ -823,11 +823,6 @@ static int unmerge_ksm_pages(struct vm_a
>>  	return err;
>>  }
>> =20
>> -#ifdef CONFIG_SYSFS
>> -/*
>> - * Only called through the sysfs control interface:
>> - */
>> -
>>  static inline struct stable_node *page_stable_node(struct page
>*page)
>>  {
>>  	return PageKsm(page) ? page_rmapping(page) : NULL;
>> @@ -839,6 +834,10 @@ static inline void set_page_stable_node(
>>  	page->mapping =3D (void *)((unsigned long)stable_node |
>PAGE_MAPPING_KSM);
>>  }
>> =20
>> +#ifdef CONFIG_SYSFS
>> +/*
>> + * Only called through the sysfs control interface:
>> + */
>>  static int remove_stable_node(struct stable_node *stable_node)
>>  {
>>  	struct page *page;
>> _
