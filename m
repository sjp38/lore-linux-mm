Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6589E6B0006
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:09:39 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t4-v6so9862310plo.9
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:09:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w12si1212664pgs.191.2018.04.10.09.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 09:09:38 -0700 (PDT)
Date: Tue, 10 Apr 2018 09:09:32 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 1/2] mm: introduce ARCH_HAS_PTE_SPECIAL
Message-ID: <20180410160932.GB3614@bombadil.infradead.org>
References: <1523373951-10981-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523373951-10981-2-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1523373951-10981-2-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>

On Tue, Apr 10, 2018 at 05:25:50PM +0200, Laurent Dufour wrote:
>  arch/powerpc/include/asm/pte-common.h                  | 3 ---
>  arch/riscv/Kconfig                                     | 1 +
>  arch/s390/Kconfig                                      | 1 +

You forgot to delete __HAVE_ARCH_PTE_SPECIAL from
arch/riscv/include/asm/pgtable-bits.h
