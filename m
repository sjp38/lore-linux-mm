Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB85D6B027A
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 19:08:02 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id rt15so14169210pab.5
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 16:08:02 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p73si5619507pfl.79.2016.11.02.16.08.01
        for <linux-mm@kvack.org>;
        Wed, 02 Nov 2016 16:08:02 -0700 (PDT)
Date: Wed, 2 Nov 2016 23:07:59 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv2 0/6] CONFIG_DEBUG_VIRTUAL for arm64
Message-ID: <20161102230758.GC19591@remoulade>
References: <20161102210054.16621-1-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161102210054.16621-1-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

Hi Laura,

FWIW, for patches 1-4:

Reviewed-by: Mark Rutland <mark.rutland@arm.com>

I still need to figure out the __pa() stuff in the last two patches.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
