Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F24F2C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 14:17:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7203205C9
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 14:17:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7203205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AD558E0006; Wed, 16 Jan 2019 09:17:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45C4C8E0002; Wed, 16 Jan 2019 09:17:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3269C8E0006; Wed, 16 Jan 2019 09:17:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00AEC8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:17:36 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id b203so2791463vsd.20
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 06:17:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=vUoQNGZurxEieeNNkZzDAFHiiSFH7qL1lJ5rxrPcqZQ=;
        b=JcbNJ5vf3hVkEWSEWq3OtVcsnmZMKGd6yYiH9PozFbBeJLXuRyFwPi+eacsnyoCF1k
         nRCjjTuznqXbo7Zhly0maeI7obEU8w4NmQ9WWJbF5xdJF5AqX4G11hMLcndEipYbnaZs
         i3uI/thwqqMb2gSjzIC5RgVTxEXHTEoHoU5Vur4e/K6orAxpH61NXcjMEGVvHvABCQoS
         rmw4y5DW8SNpjImoGjXSKxOJ7Z+cVi+yh9VPdZ4uWCNeJOrSkkTzABKa5hmC6RljNQdm
         lEk1NKoNJjgFEYrA+/pjKL7N1BlX1ArSmI4BiV5kpuNgd/xiJAPH1GZdG1ApILa2oPhV
         8O7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Gm-Message-State: AJcUukdeux2s/apr8iQYWk6bLLqdD4S59psLPEtkl1h+QtJvYjVQwdLT
	HKbXNSLBipk8RgdMXJFgCtf1oWbuYu3mCrm7LzDMlcaEcSFGDoO5V8oFI/a3ay4ccpNfy8VCDIV
	OdRSGhxFsk27b4y1z1CMNZsDoG6nfzwE8/Iv3KKthugi5zrgHt+uKgWGGRbIvtjrZ+E8EflPa3a
	Iafs2QGrIvHb30Ac1lOx5e7fjESJ5vV4wUS68XLZM86bd12Wjh8qPyZrDV0c7RrgwgnkRCPeCTf
	Iyb6dh+TQJOvLHLbqrohXzpevPH5X/vU0HH7b9iMTiVro6dIDyoTamkILyr/rqYVotfleCQLTVZ
	uN5aJpIzbgv7grFNQF2kC7CSmRSw+tS4aZqTmBrApAdaleHuEawtuVh860jmMg3ZyW3QgdUQ3A=
	=
X-Received: by 2002:a1f:4158:: with SMTP id o85mr3640495vka.42.1547648256644;
        Wed, 16 Jan 2019 06:17:36 -0800 (PST)
X-Received: by 2002:a1f:4158:: with SMTP id o85mr3640461vka.42.1547648255678;
        Wed, 16 Jan 2019 06:17:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547648255; cv=none;
        d=google.com; s=arc-20160816;
        b=FWsxYAFaTec8JH8g5eyz+vwXNOWMNKNdEibKgokked69/4dHIOcxKpMzkSV7kIwf2Q
         me/BjLjMCWcFmVBSS3BQ9Nvqy07+AYz968zcljgc6g7yee2JnU1k+A35pMt/p67CfkXs
         wfDPL/FG2nARpx1fg1/K4+4EMRlUfoHVPLBPIrIjKi+XLVdZuDa+MNxc/IWsLTRkRNRK
         QOFNkhdPQ+pEk9ophmrfRBjY1Y2nZzGO9ysJGbcWdS9PinzB33dvY13sKlneO87R5odY
         xzILA8Q8cIJxAFV8AK2kCehWxnjtw9NR3SjVnZ8aeGK3hLn/679jfTpD6cG1hQt4Fcdj
         kpjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=vUoQNGZurxEieeNNkZzDAFHiiSFH7qL1lJ5rxrPcqZQ=;
        b=UjjRKFfhNR0ErkUQCtxhWltB8EB7Ka7PlLcA52nw5eVB13oFeifUjVxe5QqUVPWenV
         1Pl8Rxhb/n82lZxoTzlsEkNWp3EUEgTOLoYll8DCzgBPbMhFEkCPzPlFYpkjZ/dfg1RW
         vt69Dwa7Gcm1arMbcaxjIrbP2l6sXEm1tDZfYfMYruDuIn0q1CnydLjLbi3ojKy8YyL9
         IpfYR25jkU6FYcPqE9rgRIfLwDWu6w4luv+Fiqc0YH6txWHDyturI1Pg9ITw/DmzRUKJ
         1m+Ahy5muoXbSL6r/1xe0kyrARGSQ22Ej7B7qs/wRVn3yvwU9sZ1jh1SdmgG7dYEBYGN
         C1gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l12sor49060693vke.47.2019.01.16.06.17.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 06:17:35 -0800 (PST)
Received-SPF: pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Google-Smtp-Source: ALg8bN5i1YrhP7vEzWfAblym8WHD9rDPmIjtAsXIX2+EXB6htxAQHG2ya7Av+N0ySlQVktSH89EOjOgISmgR9ezPUnY=
X-Received: by 2002:a1f:91cb:: with SMTP id t194mr3570847vkd.74.1547648254958;
 Wed, 16 Jan 2019 06:17:34 -0800 (PST)
MIME-Version: 1.0
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com> <1547646261-32535-14-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-14-git-send-email-rppt@linux.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 16 Jan 2019 15:17:22 +0100
Message-ID:
 <CAMuHMdXt8fPgAGp3KPGM=qVT_QzU=FJS7f5XUbK2hGXYdE9Yeg@mail.gmail.com>
Subject: Re: [PATCH 13/21] arch: don't memset(0) memory returned by memblock_alloc()
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, 
	"David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, 
	Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, 
	Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, 
	Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, 
	Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, 
	Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, 
	Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, 
	Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, 
	"open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS" <devicetree@vger.kernel.org>, kasan-dev@googlegroups.com, 
	alpha <linux-alpha@vger.kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, 
	"linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, 
	linux-mips@vger.kernel.org, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh list <linux-sh@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, 
	linux-um@lists.infradead.org, USB list <linux-usb@vger.kernel.org>, 
	linux-xtensa@linux-xtensa.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	Openrisc <openrisc@lists.librecores.org>, sparclinux <sparclinux@vger.kernel.org>, 
	"moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, 
	"the arch/x86 maintainers" <x86@kernel.org>, xen-devel@lists.xenproject.org, 
	Greg Ungerer <gerg@linux-m68k.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116141722.4e_AZpyAHFbXuh1wFMtssttJtNtr2Va9Aojb3DBtv7E@z>

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

