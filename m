Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9940D6B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 13:51:16 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id gm9so1307994lab.27
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:51:15 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id ir2si3649362lac.127.2014.10.23.10.51.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 10:51:14 -0700 (PDT)
Received: by mail-lb0-f170.google.com with SMTP id u10so1285293lbd.15
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:51:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1414074828-4488-5-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
	<1414074828-4488-5-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Date: Thu, 23 Oct 2014 19:51:14 +0200
Message-ID: <CAMuHMdWA7WvbzV-Na2tuTkSWFykrKU3RXCPKqWkW2rpyqPzGWA@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: cma: Use %pa to print physical addresses
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux-sh list <linux-sh@vger.kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, Oct 23, 2014 at 4:33 PM, Laurent Pinchart
<laurent.pinchart+renesas@ideasonboard.com> wrote:
> Casting physical addresses to unsigned long and using %lu truncates the
> values on systems where physical addresses are larger than 32 bits. Use
> %pa and get rid of the cast instead.
>
> Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>

Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

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
