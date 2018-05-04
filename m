Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 00BA16B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 04:25:48 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t24-v6so15290239qtn.7
        for <linux-mm@kvack.org>; Fri, 04 May 2018 01:25:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 56-v6si2528451qvg.222.2018.05.04.01.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 01:25:46 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w448MQgb134963
	for <linux-mm@kvack.org>; Fri, 4 May 2018 04:25:45 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hrjbc4awb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 04 May 2018 04:25:45 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 4 May 2018 09:25:43 +0100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 9/9] powerpc/hugetlb: Enable hugetlb migration for ppc64
In-Reply-To: <69b4fae5-d413-4866-7ce4-3873d3c6590f@c-s.fr>
References: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1494926612-23928-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <69b4fae5-d413-4866-7ce4-3873d3c6590f@c-s.fr>
Date: Fri, 04 May 2018 13:55:31 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Message-Id: <871serrfno.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe LEROY <christophe.leroy@c-s.fr>, mpe@ellerman.id.au
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Christophe LEROY <christophe.leroy@c-s.fr> writes:

> Le 16/05/2017 =C3=A0 11:23, Aneesh Kumar K.V a =C3=A9crit=C2=A0:
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>   arch/powerpc/platforms/Kconfig.cputype | 5 +++++
>>   1 file changed, 5 insertions(+)
>>=20
>> diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platf=
orms/Kconfig.cputype
>> index 80175000042d..8acc4f27d101 100644
>> --- a/arch/powerpc/platforms/Kconfig.cputype
>> +++ b/arch/powerpc/platforms/Kconfig.cputype
>> @@ -351,6 +351,11 @@ config PPC_RADIX_MMU
>>   	  is only implemented by IBM Power9 CPUs, if you don't have one of th=
em
>>   	  you can probably disable this.
>>=20=20=20
>> +config ARCH_ENABLE_HUGEPAGE_MIGRATION
>> +	def_bool y
>> +	depends on PPC_BOOK3S_64 && HUGETLB_PAGE && MIGRATION
>> +
>> +
>
> Is there a reason why you redefine ARCH_ENABLE_HUGEPAGE_MIGRATION=20
> instead of doing a 'select' as it is already defined in mm/Kconfig ?
>

That got copied from x86 Kconfig i guess.

-aneesh
