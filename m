Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA826B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:44:48 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id h32-v6so10326900pld.15
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:44:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bb5-v6sor1533109plb.98.2018.04.10.13.44.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 13:44:47 -0700 (PDT)
Date: Tue, 10 Apr 2018 13:44:46 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm: introduce ARCH_HAS_PTE_SPECIAL
In-Reply-To: <20180410160932.GB3614@bombadil.infradead.org>
From: Palmer Dabbelt <palmer@sifive.com>
Message-ID: <mhng-dc76549e-6083-49a7-af3f-2638193f6698@palmer-si-x1c4>
Mime-Version: 1.0 (MHng)
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: ldufour@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, jglisse@redhat.com, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, corbet@lwn.net, catalin.marinas@arm.com, Will Deacon <will.deacon@arm.com>, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, vgupta@synopsys.com, albert@sifive.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, rientjes@google.com

On Tue, 10 Apr 2018 09:09:32 PDT (-0700), willy@infradead.org wrote:
> On Tue, Apr 10, 2018 at 05:25:50PM +0200, Laurent Dufour wrote:
>>  arch/powerpc/include/asm/pte-common.h                  | 3 ---
>>  arch/riscv/Kconfig                                     | 1 +
>>  arch/s390/Kconfig                                      | 1 +
>
> You forgot to delete __HAVE_ARCH_PTE_SPECIAL from
> arch/riscv/include/asm/pgtable-bits.h

Thanks -- I was looking for that but couldn't find it and assumed I'd just 
misunderstood something.
