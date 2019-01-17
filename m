Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC538E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 02:06:19 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s71so6656269pfi.22
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 23:06:19 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l23si768483pgh.533.2019.01.16.23.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 23:06:18 -0800 (PST)
Date: Thu, 17 Jan 2019 15:06:03 +0800
From: Guo Ren <guoren@kernel.org>
Subject: Re: [PATCH 19/21] treewide: add checks for the return value of
 memblock_alloc*()
Message-ID: <20190117070602.GA31839@guoren-Inspiron-7460>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
 <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org

On Wed, Jan 16, 2019 at 03:44:19PM +0200, Mike Rapoport wrote:
>  arch/csky/mm/highmem.c                    |  5 +++++
...
> diff --git a/arch/csky/mm/highmem.c b/arch/csky/mm/highmem.c
> index 53b1bfa..3317b774 100644
> --- a/arch/csky/mm/highmem.c
> +++ b/arch/csky/mm/highmem.c
> @@ -141,6 +141,11 @@ static void __init fixrange_init(unsigned long start, unsigned long end,
>  			for (; (k < PTRS_PER_PMD) && (vaddr != end); pmd++, k++) {
>  				if (pmd_none(*pmd)) {
>  					pte = (pte_t *) memblock_alloc_low(PAGE_SIZE, PAGE_SIZE);
> +					if (!pte)
> +						panic("%s: Failed to allocate %lu bytes align=%lx\n",
> +						      __func__, PAGE_SIZE,
> +						      PAGE_SIZE);
> +
>  					set_pmd(pmd, __pmd(__pa(pte)));
>  					BUG_ON(pte != pte_offset_kernel(pmd, 0));
>  				}

Looks good for me and panic is ok.

Reviewed-by: Guo Ren <ren_guo@c-sky.com>
