Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00D9D6B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 09:08:25 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m188so57829111pgm.2
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 06:08:24 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id b4si1544783pfh.440.2017.06.28.06.08.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 28 Jun 2017 06:08:22 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v4 1/6] mm, x86: Add ARCH_HAS_ZONE_DEVICE to Kconfig
In-Reply-To: <20170628013236.413-1-oohall@gmail.com>
References: <20170628013236.413-1-oohall@gmail.com>
Date: Wed, 28 Jun 2017 23:08:17 +1000
Message-ID: <87r2y4b6pq.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>, linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.orgakpm@linux-foundation.org

Oliver O'Halloran <oohall@gmail.com> writes:

> Currently ZONE_DEVICE depends on X86_64 and this will get unwieldly as
> new architectures (and platforms) get ZONE_DEVICE support. Move to an
> arch selected Kconfig option to save us the trouble.
>
> Cc: linux-mm@kvack.org
> Acked-by: Ingo Molnar <mingo@kernel.org>
> Acked-by: Balbir Singh <bsingharora@gmail.com>
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
> ---
> Andew, the rest of the series should be going in via the ppc tree, but
> since there's nothing ppc specific about this patch do you want to
> take it via mm?

Except without this patch none of the rest of the series can be tested
on powerpc, because the code doesn't go live until ARCH_HAS_ZONE_DEVICE
is wired up for powerpc.

So it'd be better if the series stayed together, wherever it goes. I'll
pick it up unless Andrew objects.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
