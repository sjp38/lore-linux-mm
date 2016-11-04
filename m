Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D9B82280260
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 23:16:09 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j198so81605323oih.5
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 20:16:09 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id n186si9015016ith.80.2016.11.03.20.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 20:16:08 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [mm PATCH v2 18/26] arch/powerpc: Add option to skip DMA sync as a part of mapping
In-Reply-To: <20161102111513.79519.65315.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com> <20161102111513.79519.65315.stgit@ahduyck-blue-test.jf.intel.com>
Date: Fri, 04 Nov 2016 14:16:01 +1100
Message-ID: <87twbolytq.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Alexander Duyck <alexander.h.duyck@intel.com> writes:

> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> via a sync_for_cpu or sync_for_device call.
>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: linuxppc-dev@lists.ozlabs.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  arch/powerpc/kernel/dma.c |    9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)

LGTM.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
