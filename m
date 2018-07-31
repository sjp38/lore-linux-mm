Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 784AD6B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 16:06:53 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id b185-v6so15044443qkg.19
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 13:06:53 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d44-v6si4905093qta.140.2018.07.31.13.06.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 13:06:52 -0700 (PDT)
Date: Tue, 31 Jul 2018 16:06:40 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v5 00/11] hugetlb: Factorize hugetlb architecture
 primitives
Message-ID: <20180731160640.11306628@doriath>
In-Reply-To: <20180731060155.16915-1-alex@ghiti.fr>
References: <20180731060155.16915-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: linux-mm@kvack.org, mike.kravetz@oracle.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

On Tue, 31 Jul 2018 06:01:44 +0000
Alexandre Ghiti <alex@ghiti.fr> wrote:

> [CC linux-mm for inclusion in -mm tree] 
> 
> In order to reduce copy/paste of functions across architectures and then
> make riscv hugetlb port (and future ports) simpler and smaller, this
> patchset intends to factorize the numerous hugetlb primitives that are
> defined across all the architectures.

[...]

>  15 files changed, 139 insertions(+), 382 deletions(-)

I imagine you're mostly interested in non-x86 review at this point, but
as this series is looking amazing:

Reviewed-by: Luiz Capitulino <lcapitulino@redhat.com>
