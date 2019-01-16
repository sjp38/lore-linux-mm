Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Wed, 16 Jan 2019 09:21:47 -0800 (PST)
Message-Id: <20190116.092147.2222967221278304230.davem@davemloft.net>
Subject: Re: [PATCH 15/21] sparc: add checks for the return value of
 memblock_alloc*()
From: David Miller <davem@davemloft.net>
In-Reply-To: <1547646261-32535-16-git-send-email-rppt@linux.ibm.com>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
        <1547646261-32535-16-git-send-email-rppt@linux.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: rppt@linux.ibm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, catalin.marinas@arm.com, hch@lst.de, dennis@kernel.org, geert@linux-m68k.org, green.hu@gmail.com, gregkh@linuxfoundation.org, gxt@pku.edu.cn, guoren@kernel.org, heiko.carstens@de.ibm.com, msalter@redhat.com, mattst88@gmail.com, jcmvbkbc@gmail.com, mpe@ellerman.id.au, monstr@monstr.eu, paul.burton@mips.com, pmladek@suse.com, dalias@libc.org, richard@nod.at, robh+dt@kernel.org, linux@armlinux.org.uk, shorne@gmail.com, tony.luck@intel.com, vgupta@synopsys.com, ysato@users.sourceforge.jp, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org
List-ID: <linux-mm.kvack.org>

From: Mike Rapoport <rppt@linux.ibm.com>
Date: Wed, 16 Jan 2019 15:44:15 +0200

> Add panic() calls if memblock_alloc*() returns NULL.
> 
> Most of the changes are simply addition of
> 
>         if(!ptr)
>                 panic();
> 
> statements after the calls to memblock_alloc*() variants.
> 
> Exceptions are pcpu_populate_pte() and kernel_map_range() that were
> slightly refactored to accommodate the change.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>
