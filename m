Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DCDE46B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 08:51:09 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so166888494pfx.1
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 05:51:09 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z30si48079059plh.291.2016.12.13.05.51.08
        for <linux-mm@kvack.org>;
        Tue, 13 Dec 2016 05:51:08 -0800 (PST)
Date: Tue, 13 Dec 2016 13:50:16 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv5 00/11] CONFIG_DEBUG_VIRTUAL for arm64
Message-ID: <20161213135015.GC24607@leverpostej>
References: <1481068257-6367-1-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481068257-6367-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Juergen Gross <jgross@suse.com>, Eric Biederman <ebiederm@xmission.com>, kexec@lists.infradead.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@chromium.org>

On Tue, Dec 06, 2016 at 03:50:46PM -0800, Laura Abbott wrote:
> Hi,
> 
> This is v5 of the series to add CONFIG_DEBUG_VIRTUAL for arm64. This mostly
> contains minor fixups including adding a few extra headers around and splitting
> things out into a few more sub-patches.
> 
> With a few more acks I think this should be ready to go. More testing is
> always appreciated though.

I've given the whole series a go with kasan, kexec, and hibernate (using
test_resume with the disk target), and everything looks happy. So FWIW,
for the series:

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>

Hopefully this can be queued soon for v4.11!

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
