Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 627EF6B7259
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 23:09:39 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so8966986edt.23
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 20:09:39 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v27si4260218edm.111.2018.12.04.20.09.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 20:09:38 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB548ths042830
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 23:09:36 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p66tg9bwg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 23:09:36 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 5 Dec 2018 04:09:35 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V3 5/5] arch/powerpc/mm/hugetlb: NestMMU workaround for hugetlb mprotect RW upgrade
In-Reply-To: <3b87e008-eb08-f41c-ef70-1986360c5df9@c-s.fr>
References: <20181205030931.12037-1-aneesh.kumar@linux.ibm.com> <20181205030931.12037-6-aneesh.kumar@linux.ibm.com> <3b87e008-eb08-f41c-ef70-1986360c5df9@c-s.fr>
Date: Wed, 05 Dec 2018 09:39:27 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87o9a062dk.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe LEROY <christophe.leroy@c-s.fr>, npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Christophe LEROY <christophe.leroy@c-s.fr> writes:
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
>> index 8cf035e68378..39d33a3d0dc6 100644
>> --- a/arch/powerpc/mm/hugetlbpage.c
>> +++ b/arch/powerpc/mm/hugetlbpage.c
>> @@ -912,3 +912,32 @@ int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
>>   
>>   	return 1;
>>   }
>> +
>> +#ifdef CONFIG_PPC_BOOK3S_64
>
> Could this go in hugetlbpage-hash64.c instead to avoid the #ifdef sequence ?
>

yes. I will send updated patch as reply

-aneesh
