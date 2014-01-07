Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f180.google.com (mail-gg0-f180.google.com [209.85.161.180])
	by kanga.kvack.org (Postfix) with ESMTP id A4CAF6B0070
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 12:27:02 -0500 (EST)
Received: by mail-gg0-f180.google.com with SMTP id e5so77908ggh.39
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 09:27:02 -0800 (PST)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id x47si1089942yhx.210.2014.01.07.09.27.01
        for <linux-mm@kvack.org>;
        Tue, 07 Jan 2014 09:27:01 -0800 (PST)
Date: Tue, 7 Jan 2014 17:26:32 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 0/5] generic early_ioremap support
Message-ID: <20140107172632.GC6234@arm.com>
References: <1389062120-31896-1-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389062120-31896-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "patches@linaro.org" <patches@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <linux@arm.linux.org.uk>, Will Deacon <Will.Deacon@arm.com>

On Tue, Jan 07, 2014 at 02:35:15AM +0000, Mark Salter wrote:
> This patch series takes the common bits from the x86 early ioremap
> implementation and creates a generic implementation which may be used
> by other architectures. The early ioremap interfaces are intended for
> situations where boot code needs to make temporary virtual mappings
> before the normal ioremap interfaces are available. Typically, this
> means before paging_init() has run.
> 
> These patches are layered on top of generic fixmap patches which
> were discussed here (and are in the akpm tree):
> 
>   http://lkml.org/lkml/2013/11/25/474
> 
> This is version 2 of the patch series. These patches (and underlying
> fixmap patches) may be found at:
> 
>   git://github.com/mosalter/linux.git (early-ioremap-v2 branch)

The patches look fine to me. I haven't acked the arm64 patches as I'll
eventually merge/sign them off once the first patch in the series goes
in.

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
