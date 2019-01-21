Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 650D7C282DB
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 08:39:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DFE620861
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 08:39:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DFE620861
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1B238E003C; Mon, 21 Jan 2019 03:39:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCAC08E0025; Mon, 21 Jan 2019 03:39:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE0968E003C; Mon, 21 Jan 2019 03:39:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8518E0025
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:39:57 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id e81so9976993vsd.23
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:39:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=wXXf60K6qLBfkEtUwQVayQ/Z09obuhMcmgJu/ku/5b4=;
        b=a0ERCGDwGQF307NRMgJeYFzFbXAPrQeYMr2WGxgWtQz4Wc1VJ6LQRnSFFExsnwdvKx
         uHTTFAc1fmFijSgeJ88p7HyU5ofRjOJMHrvmPvQNtmVu00TfoB9mXFq1LF2ZJunelbXH
         Ve4UDHKQciqgS4NiVaCRZfwvUfMNxzUAwkpUkGxPoFVMs2iDR60qViVq9hYLKVy6/i7j
         Hdvur1efJ9ogaSqsBHX9nQQVRBLHRlfeebjBsSzATb9HmTaDDpMa9yRpY1KLEchd1afj
         fBCvApxIR6/FBdp4+0DboI9M7CcYWngU0mjTX4/JP8wiiCBYaMfWur6c3hqcx8LKRk6x
         G1Gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Gm-Message-State: AJcUukdPBiIURxd0YXcrYlG1OzdPmp/FUAy+1tbZo3Ey5y1cDfKeFjuT
	1FnCOxS7/gkRopTXEP1HwNPDDgpkvHKWrdWgHToi8kvBrhn+mhvl5xyZSb76l1QKNDur+K9rJHz
	a3tME3wtU0Z9VlOX9SPKT/p3sLvo2A5lyO6eqC2+tHKt37weH7b379LfzL993186upLhTzSo0jZ
	Rsgt7GllyLd16pqUrl9n1awkuPFFXElaxdTxUuVAYmzdh574leEpOECmKj60x/aEHQrVm7X8LeF
	YkRhlW0pEsblCzBpgz7txL+iQnPNJlg3I0G6M7dPeapM5KcdPqHi+uBXrr84+9MPJDw8aL0QIwm
	di++aZdwtgpmXvzkvWHS6sto4rFjhr3T5pXX6b5+EH1c+7kWXPpMRoyEy3l3mXnAkgzuOsCSEA=
	=
X-Received: by 2002:a67:2d0b:: with SMTP id t11mr11518797vst.211.1548059996322;
        Mon, 21 Jan 2019 00:39:56 -0800 (PST)
X-Received: by 2002:a67:2d0b:: with SMTP id t11mr11518774vst.211.1548059994617;
        Mon, 21 Jan 2019 00:39:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548059994; cv=none;
        d=google.com; s=arc-20160816;
        b=odvKRtBhcjKFgzHqa8cv2ph0f26fAcrUIJrLjKbg2yTybH37nE8ggZ++tRNhyL0exw
         WUUGsEV1QxLMm/lcWSsiuWF8R9oX8yYyl/XIJlIeYdEsRecuVw47Bd+7AdF3l4KVaKMy
         DwGBbO+6YmY0QEjdEBOsNczqUBB4TDMkFx+j3X8HjQ5FYr8HiTZYrkU8RrMj3gxPowkS
         5zx+1kpmp9JNAz+loBW06bJL5x9BJmrmmkAu3S0ppyPDQulL6tx1kKvCGER6IFccAilA
         0ZWwPGSd5UN22fpf1UW7F8KKlsaNomyetu+wUzaTqi6LLpsa8dQ6s0lTrzo/DgrdHZhX
         Ns5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=wXXf60K6qLBfkEtUwQVayQ/Z09obuhMcmgJu/ku/5b4=;
        b=oCZSXtkNtn2rSc95O3z0z+ux7ZpsWGndyLgUCXizcXspeThpS9Zej+GBRFA+yCtjg6
         psEoZrHfBboOSGIkMKfHVs+cIOeYwXFwoJ8qICCDxaGGZrYyBvyYI7ccX2+QZsYIaByd
         Nv936JHbPLzC5ucFngOwEJAS2lilyCbjgOVFBm+aPV4OEreHqfWQ4Xx2Dh471zSCyRwa
         PpQ9OXLGySsa66jkXkN8gYVcW5b3bynS4IPPGTNzc+FfXndH8Em1Ob2lacB+focFMO2G
         0UI3cygEXWeThxjyQ3MdxgNXXQ3U0WjRB+CpnixMgQWd4mq91HMFbk5g7RsAwom7w1/y
         J4UA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor7650895vso.16.2019.01.21.00.39.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 00:39:54 -0800 (PST)
Received-SPF: pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Google-Smtp-Source: ALg8bN4mENvayOoHhcexwPKwPZpADxxCwDT+fO8JZp3FckUsdVnfDoKV+J50chRwbd0g79AaM6GA2B3UmK9Hh4spsZI=
X-Received: by 2002:a67:3885:: with SMTP id n5mr10344294vsi.96.1548059992504;
 Mon, 21 Jan 2019 00:39:52 -0800 (PST)
MIME-Version: 1.0
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com> <1548057848-15136-20-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1548057848-15136-20-git-send-email-rppt@linux.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 21 Jan 2019 09:39:40 +0100
Message-ID:
 <CAMuHMdUhaTv0E3oMjMjoW0XReZgB=bm+8OGUvuDtLPBJzGQYjw@mail.gmail.com>
Subject: Re: [PATCH v2 19/21] treewide: add checks for the return value of memblock_alloc*()
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
	"the arch/x86 maintainers" <x86@kernel.org>, xen-devel@lists.xenproject.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121083940.N6s18vDZjf-dh1yTm51MDLXaGO2uubeV5oE0WmEPnQw@z>

On Mon, Jan 21, 2019 at 9:06 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
> Add check for the return value of memblock_alloc*() functions and call
> panic() in case of error.
> The panic message repeats the one used by panicing memblock allocators with
> adjustment of parameters to include only relevant ones.
>
> The replacement was mostly automated with semantic patches like the one
> below with manual massaging of format strings.
>
> @@
> expression ptr, size, align;
> @@
> ptr = memblock_alloc(size, align);
> + if (!ptr)
> +       panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
> size, align);
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

>  arch/m68k/atari/stram.c                   |  4 ++++
>  arch/m68k/mm/init.c                       |  3 +++
>  arch/m68k/mm/mcfmmu.c                     |  6 ++++++
>  arch/m68k/mm/motorola.c                   |  9 +++++++++
>  arch/m68k/mm/sun3mmu.c                    |  6 ++++++
>  arch/m68k/sun3/sun3dvma.c                 |  3 +++

For m68k:
Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

