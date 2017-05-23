Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC39D6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 10:53:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c10so167407688pfg.10
        for <linux-mm@kvack.org>; Tue, 23 May 2017 07:53:14 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b5si21629608plk.75.2017.05.23.07.53.13
        for <linux-mm@kvack.org>;
        Tue, 23 May 2017 07:53:13 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v3.1 4/6] mm/hugetlb: Allow architectures to override huge_pte_clear()
References: <20170522133604.11392-5-punit.agrawal@arm.com>
	<20170522162555.4313-1-punit.agrawal@arm.com>
	<CAK8P3a0WppXFJ5==nymNHeqrKvixpLQ1AetFRGVv9Y3q8kT9Ew@mail.gmail.com>
Date: Tue, 23 May 2017 15:53:10 +0100
In-Reply-To: <CAK8P3a0WppXFJ5==nymNHeqrKvixpLQ1AetFRGVv9Y3q8kT9Ew@mail.gmail.com>
	(Arnd Bergmann's message of "Mon, 22 May 2017 22:34:45 +0200")
Message-ID: <87efvfhbft.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, n-horiguchi@ah.jp.nec.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, mike.kravetz@oracle.com, steve.capper@arm.com, Mark Rutland <mark.rutland@arm.com>, linux-arch <linux-arch@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

Arnd Bergmann <arnd@arndb.de> writes:

> On Mon, May 22, 2017 at 6:25 PM, Punit Agrawal <punit.agrawal@arm.com> wrote:
>> When unmapping a hugepage range, huge_pte_clear() is used to clear the
>> page table entries that are marked as not present. huge_pte_clear()
>> internally just ends up calling pte_clear() which does not correctly
>> deal with hugepages consisting of contiguous page table entries.
>>
>> Add a size argument to address this issue and allow architectures to
>> override huge_pte_clear() by wrapping it in a #ifndef block.
>>
>> Update s390 implementation with the size parameter as well.
>>
>> Note that the change only affects huge_pte_clear() - the other generic
>> hugetlb functions don't need any change.
>>
>> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> Cc: Mike Kravetz <mike.kravetz@oracle.com>
>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Thanks, Arnd. I've applied the tag locally.

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
