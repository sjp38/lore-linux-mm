Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5346B0463
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:58:13 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c4so149011165pfb.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:58:13 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m8si9176124pfi.25.2016.11.18.09.58.12
        for <linux-mm@kvack.org>;
        Fri, 18 Nov 2016 09:58:12 -0800 (PST)
Date: Fri, 18 Nov 2016 17:57:30 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv3 0/6] CONFIG_DEBUG_VIRTUAL for arm64
Message-ID: <20161118175730.GF1197@leverpostej>
References: <1479431816-5028-1-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479431816-5028-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Thu, Nov 17, 2016 at 05:16:50PM -0800, Laura Abbott wrote:
> Hi,

Hi,

Thanks again for putting this together.

> This is v3 of the series to add CONFIG_DEBUG_VIRTUAL for arm64.
> The biggest change from v2 is the conversion of more __pa sites
> to __pa_symbol for stricter checks.

Patches 1-4 look good to me, and I've given them a spin in a few
configurations on arm64. For those:

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>

Patches 5 and 6 look like they're mostly there, but there are still a
few issues which I've commented on. Hopefully those aren't too painful
to sort out; it would be great to have this available.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
