Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id F243A6B0292
	for <linux-mm@kvack.org>; Mon, 22 May 2017 16:34:46 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t133so173437044oif.9
        for <linux-mm@kvack.org>; Mon, 22 May 2017 13:34:46 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id o4si8042001otb.154.2017.05.22.13.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 13:34:46 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id w138so24678747oiw.3
        for <linux-mm@kvack.org>; Mon, 22 May 2017 13:34:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170522162555.4313-1-punit.agrawal@arm.com>
References: <20170522133604.11392-5-punit.agrawal@arm.com> <20170522162555.4313-1-punit.agrawal@arm.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 22 May 2017 22:34:45 +0200
Message-ID: <CAK8P3a0WppXFJ5==nymNHeqrKvixpLQ1AetFRGVv9Y3q8kT9Ew@mail.gmail.com>
Subject: Re: [PATCH v3.1 4/6] mm/hugetlb: Allow architectures to override huge_pte_clear()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, n-horiguchi@ah.jp.nec.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, mike.kravetz@oracle.com, steve.capper@arm.com, Mark Rutland <mark.rutland@arm.com>, linux-arch <linux-arch@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Mon, May 22, 2017 at 6:25 PM, Punit Agrawal <punit.agrawal@arm.com> wrote:
> When unmapping a hugepage range, huge_pte_clear() is used to clear the
> page table entries that are marked as not present. huge_pte_clear()
> internally just ends up calling pte_clear() which does not correctly
> deal with hugepages consisting of contiguous page table entries.
>
> Add a size argument to address this issue and allow architectures to
> override huge_pte_clear() by wrapping it in a #ifndef block.
>
> Update s390 implementation with the size parameter as well.
>
> Note that the change only affects huge_pte_clear() - the other generic
> hugetlb functions don't need any change.
>
> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Arnd Bergmann <arnd@arndb.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
