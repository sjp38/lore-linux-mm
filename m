Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16F1B6B02F4
	for <linux-mm@kvack.org>; Sun,  2 Jul 2017 07:01:43 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s4so174724027pgr.3
        for <linux-mm@kvack.org>; Sun, 02 Jul 2017 04:01:43 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id x3si4266332pgq.126.2017.07.02.04.01.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 02 Jul 2017 04:01:41 -0700 (PDT)
In-Reply-To: <20170628013236.413-1-oohall@gmail.com>
From: Michael Ellerman <patch-notifications@ellerman.id.au>
Subject: Re: [v4,1/6] mm, x86: Add ARCH_HAS_ZONE_DEVICE to Kconfig
Message-Id: <3x0nQC2RLpz9sNx@ozlabs.org>
Date: Sun,  2 Jul 2017 21:01:39 +1000 (AEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>, linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org

On Wed, 2017-06-28 at 01:32:31 UTC, Oliver O'Halloran wrote:
> Currently ZONE_DEVICE depends on X86_64 and this will get unwieldly as
> new architectures (and platforms) get ZONE_DEVICE support. Move to an
> arch selected Kconfig option to save us the trouble.
> 
> Cc: linux-mm@kvack.org
> Acked-by: Ingo Molnar <mingo@kernel.org>
> Acked-by: Balbir Singh <bsingharora@gmail.com>
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>

Series applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/65f7d049788763969180c72ef98dab

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
