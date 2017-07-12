Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A8C956B037C
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 04:00:07 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n2so1388256oig.12
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 01:00:07 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id x193si1305403oif.157.2017.07.12.01.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 01:00:07 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id n2so2029091oig.3
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 01:00:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMuHMdVDgLpK8r2D4rwmCXEYwdgf7=Tqspq=VgPHmuqcrY5bVA@mail.gmail.com>
References: <1499842660-10665-1-git-send-email-geert@linux-m68k.org>
 <CAK8P3a3J8uyTW2_iDpOi2Y5ONf7z3TR0zk3igp2uBrL8xsQd8Q@mail.gmail.com> <CAMuHMdVDgLpK8r2D4rwmCXEYwdgf7=Tqspq=VgPHmuqcrY5bVA@mail.gmail.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 12 Jul 2017 10:00:06 +0200
Message-ID: <CAK8P3a3A_cJp-K_LVEgcZPUi2_GyQJ5cP3hAtJi=ML=T3D0PSw@mail.gmail.com>
Subject: Re: [PATCH] mm: Mark create_huge_pmd() inline to prevent build failure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jul 12, 2017 at 9:37 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:

> You did mention seeing it with mips-gcc-4.1 in the thread "[RFC] minimum gcc
> version for kernel: raise to gcc-4.3 or 4.6?", but didn't provide any further
> details. Finally I started seeing it myself for m68k ;-)

Ah right, I misremembered that then.

     Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
