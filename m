Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2C18E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:16:00 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v2so4001961plg.6
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:16:00 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x9si6326963pll.131.2019.01.16.07.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 07:15:58 -0800 (PST)
Received: from mail-qk1-f179.google.com (mail-qk1-f179.google.com [209.85.222.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C7BC8214C6
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 15:15:57 +0000 (UTC)
Received: by mail-qk1-f179.google.com with SMTP id a1so3940059qkc.5
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:15:57 -0800 (PST)
MIME-Version: 1.0
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com> <1547646261-32535-9-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-9-git-send-email-rppt@linux.ibm.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Wed, 16 Jan 2019 09:15:45 -0600
Message-ID: <CAL_Jsq+7=yiOYS0Nq7euXK4qghjAu9-mzruW0Jt1N146gK+DCQ@mail.gmail.com>
Subject: Re: [PATCH 08/21] memblock: drop __memblock_alloc_base()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, "moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, linux-um@lists.infradead.org, Linux USB List <linux-usb@vger.kernel.org>, linux-xtensa@linux-xtensa.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Openrisc <openrisc@lists.librecores.org>, sparclinux@vger.kernel.org, "moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, x86@kernel.org, xen-devel@lists.xenproject.org

On Wed, Jan 16, 2019 at 7:45 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> The __memblock_alloc_base() function tries to allocate a memory up to the
> limit specified by its max_addr parameter. Depending on the value of this
> parameter, the __memblock_alloc_base() can is replaced with the appropriate
> memblock_phys_alloc*() variant.
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/sh/kernel/machine_kexec.c |  3 ++-
>  arch/x86/kernel/e820.c         |  2 +-
>  arch/x86/mm/numa.c             | 12 ++++--------
>  drivers/of/of_reserved_mem.c   |  7 ++-----
>  include/linux/memblock.h       |  2 --
>  mm/memblock.c                  |  9 ++-------
>  6 files changed, 11 insertions(+), 24 deletions(-)

Acked-by: Rob Herring <robh@kernel.org>
