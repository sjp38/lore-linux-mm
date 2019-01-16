Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00AEC8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:17:36 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id b203so2791463vsd.20
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 06:17:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l12sor49060693vke.47.2019.01.16.06.17.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 06:17:35 -0800 (PST)
MIME-Version: 1.0
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com> <1547646261-32535-14-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-14-git-send-email-rppt@linux.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 16 Jan 2019 15:17:22 +0100
Message-ID: <CAMuHMdXt8fPgAGp3KPGM=qVT_QzU=FJS7f5XUbK2hGXYdE9Yeg@mail.gmail.com>
Subject: Re: [PATCH 13/21] arch: don't memset(0) memory returned by memblock_alloc()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS" <devicetree@vger.kernel.org>, kasan-dev@googlegroups.com, alpha <linux-alpha@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, linux-mips@vger.kernel.org, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, linux-um@lists.infradead.org, USB list <linux-usb@vger.kernel.org>, linux-xtensa@linux-xtensa.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Openrisc <openrisc@lists.librecores.org>, sparclinux <sparclinux@vger.kernel.org>, "moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, the arch/x86 maintainers <x86@kernel.org>, xen-devel@lists.xenproject.org, Greg Ungerer <gerg@linux-m68k.org>

On Wed, Jan 16, 2019 at 2:45 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> memblock_alloc() already clears the allocated memory, no point in doing it
> twice.
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

>  arch/m68k/mm/mcfmmu.c       | 1 -

For m68k part:
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

> --- a/arch/m68k/mm/mcfmmu.c
> +++ b/arch/m68k/mm/mcfmmu.c
> @@ -44,7 +44,6 @@ void __init paging_init(void)
>         int i;
>
>         empty_zero_page = (void *) memblock_alloc(PAGE_SIZE, PAGE_SIZE);
> -       memset((void *) empty_zero_page, 0, PAGE_SIZE);
>
>         pg_dir = swapper_pg_dir;
>         memset(swapper_pg_dir, 0, sizeof(swapper_pg_dir));

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
