Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 231356B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 13:58:04 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t1-v6so7443121plb.5
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 10:58:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k191si521205pgd.449.2018.04.09.10.58.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 10:58:03 -0700 (PDT)
Date: Mon, 9 Apr 2018 10:57:57 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/3] mm: replace __HAVE_ARCH_PTE_SPECIAL
Message-ID: <20180409175757.GA12938@infradead.org>
References: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523282229-20731-3-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1523282229-20731-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

> -#ifdef __HAVE_ARCH_PTE_SPECIAL
> +#ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
>  # define HAVE_PTE_SPECIAL 1
>  #else
>  # define HAVE_PTE_SPECIAL 0

I'd say kill this odd indirection and just use the
CONFIG_ARCH_HAS_PTE_SPECIAL symbol directly.
