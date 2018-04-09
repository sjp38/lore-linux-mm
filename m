Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE3A6B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 16:08:39 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g61-v6so7658454plb.10
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 13:08:39 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g14sor255585pgv.232.2018.04.09.13.08.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Apr 2018 13:08:33 -0700 (PDT)
Date: Mon, 9 Apr 2018 13:08:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm: replace __HAVE_ARCH_PTE_SPECIAL
In-Reply-To: <20180409175757.GA12938@infradead.org>
Message-ID: <alpine.DEB.2.21.1804091307480.56406@chino.kir.corp.google.com>
References: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com> <1523282229-20731-3-git-send-email-ldufour@linux.vnet.ibm.com> <20180409175757.GA12938@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Mon, 9 Apr 2018, Christoph Hellwig wrote:

> > -#ifdef __HAVE_ARCH_PTE_SPECIAL
> > +#ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
> >  # define HAVE_PTE_SPECIAL 1
> >  #else
> >  # define HAVE_PTE_SPECIAL 0
> 
> I'd say kill this odd indirection and just use the
> CONFIG_ARCH_HAS_PTE_SPECIAL symbol directly.
> 
> 

Agree, and I think it would be easier to audit/review if patches 1 and 3 
were folded together to see the relationship between the newly added 
selects and what #define's it is replacing.  Otherwise, looks good!
