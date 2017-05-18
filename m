Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AACBB831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 04:47:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e7so21410267pfk.9
        for <linux-mm@kvack.org>; Thu, 18 May 2017 01:47:05 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id 28si4558525pfq.323.2017.05.18.01.47.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 May 2017 01:47:04 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v3 2/2] powerpc/mm/hugetlb: Add support for 1G huge pages
In-Reply-To: <852b601c-a044-0445-e97d-d17d76ec1154@linux.vnet.ibm.com>
References: <1494995292-4443-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1494995292-4443-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <87fug2loze.fsf@concordia.ellerman.id.au> <852b601c-a044-0445-e97d-d17d76ec1154@linux.vnet.ibm.com>
Date: Thu, 18 May 2017 18:47:01 +1000
Message-ID: <877f1elfga.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> On Thursday 18 May 2017 10:51 AM, Michael Ellerman wrote:
>> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
>> 
>>> POWER9 supports hugepages of size 2M and 1G in radix MMU mode. This patch
>>> enables the usage of 1G page size for hugetlbfs. This also update the helper
>>> such we can do 1G page allocation at runtime.
>>>
>>> We still don't enable 1G page size on DD1 version. This is to avoid doing
>>> workaround mentioned in commit: 6d3a0379ebdc8 (powerpc/mm: Add
>>> radix__tlb_flush_pte_p9_dd1()
>>>
>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>>> ---
>>>   arch/powerpc/include/asm/book3s/64/hugetlb.h | 10 ++++++++++
>>>   arch/powerpc/mm/hugetlbpage.c                |  7 +++++--
>>>   arch/powerpc/platforms/Kconfig.cputype       |  1 +
>>>   3 files changed, 16 insertions(+), 2 deletions(-)
>> 
>> I think this patch is OK, but it's very confusing because it doesn't
>> mention that it's only talking about *generic* gigantic page support.
>
> What you mean by generic gigantic page ? what is supported here is the 
> gigantic page with size 1G alone ?

What about 16G pages on pseries.

And all the other gigantic page sizes that Book3E supports?

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
