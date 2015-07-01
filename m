Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 257136B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 08:54:10 -0400 (EDT)
Received: by oigx81 with SMTP id x81so30925554oig.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 05:54:10 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id e75si1673288oic.7.2015.07.01.05.54.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 05:54:08 -0700 (PDT)
Received: by obpn3 with SMTP id n3so27350937obp.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 05:54:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1435745853-27535-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <55924508.9080101@synopsys.com>
	<1435745853-27535-1-git-send-email-ldufour@linux.vnet.ibm.com>
Date: Wed, 1 Jul 2015 14:54:08 +0200
Message-ID: <CAMuHMdWe0eEYm11LdDvQiAUV=XFYSM-ef2JueZn+rDtTt2H_Pg@mail.gmail.com>
Subject: Re: [PATCH v2] mm: cleaning per architecture MM hook header files
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, uclinux-h8-devel@lists.sourceforge.jp, Andrew Morton <akpm@linux-foundation.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jul 1, 2015 at 12:17 PM, Laurent Dufour
<ldufour@linux.vnet.ibm.com> wrote:
> The commit 2ae416b142b6 ("mm: new mm hook framework") introduced an empty
> header file (mm-arch-hooks.h) for every architecture, even those which
> doesn't need to define mm hooks.
>
> As suggested by Geert Uytterhoeven, this could be cleaned through the use
> of a generic header file included via each per architecture
> asm/include/Kbuild file.
>
> The PowerPC architecture is not impacted here since this architecture has
> to defined the arch_remap MM hook.
>
> Changes in V2:
> --------------
>  - Vineet Gupta reported that the Kbuild files should be kept sorted.
>  - Add fix for the newly introduced H8/300 architecture.
>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Suggested-by: Geert Uytterhoeven <geert@linux-m68k.org>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Vineet Gupta <Vineet.Gupta1@synopsys.com>
> CC: linux-arch@vger.kernel.org
> CC: linux-mm@kvack.org
> CC: linux-kernel@vger.kernel.org

For m68k:
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
