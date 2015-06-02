Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 142CF6B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 03:06:08 -0400 (EDT)
Received: by obcnx10 with SMTP id nx10so115701744obc.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 00:06:07 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id kk7si6260852oeb.65.2015.06.02.00.06.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 00:06:07 -0700 (PDT)
Received: by oihb142 with SMTP id b142so119041504oih.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 00:06:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1433187393-22688-7-git-send-email-toshi.kani@hp.com>
References: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
	<1433187393-22688-7-git-send-email-toshi.kani@hp.com>
Date: Tue, 2 Jun 2015 09:06:06 +0200
Message-ID: <CAMuHMdUaasgirQcB=gR28Zi_4pj29cdKeVg=efOHNpvbcAck9A@mail.gmail.com>
Subject: Re: [PATCH v12 6/10] video/fbdev, asm/io.h: Remove ioremap_writethrough()
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, Andy Lutomirski <luto@amacapital.net>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, yigal@plexistor.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Elliott@hp.com, "Luis R. Rodriguez" <mcgrof@suse.com>, Christoph Hellwig <hch@lst.de>

On Mon, Jun 1, 2015 at 9:36 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> This patch removes the callers of ioremap_writethrough() by
> replacing them with ioremap_wt() in three drivers under
> drivers/video/fbdev.  It then removes ioremap_writethrough()
> defined in some architecture's asm/io.h, frv, m68k, microblaze,
> and tile.
>
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  arch/frv/include/asm/io.h        |    5 -----
>  arch/m68k/include/asm/io_mm.h    |    5 -----
>  arch/m68k/include/asm/io_no.h    |    4 ----
>  arch/microblaze/include/asm/io.h |    1 -
>  arch/tile/include/asm/io.h       |    1 -
>  drivers/video/fbdev/amifb.c      |    4 ++--
>  drivers/video/fbdev/atafb.c      |    3 +--
>  drivers/video/fbdev/hpfb.c       |    4 ++--

For the m68k and amifb/atafb/hpfb changes:
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
