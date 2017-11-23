Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 933426B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 10:31:43 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id c41so10198301otc.18
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:31:43 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u15si8527775ote.40.2017.11.23.07.31.42
        for <linux-mm@kvack.org>;
        Thu, 23 Nov 2017 07:31:42 -0800 (PST)
Date: Thu, 23 Nov 2017 15:31:34 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Message-ID: <20171123153133.mwyuxthy2ysktx7c@lakrids.cambridge.arm.com>
References: <87po8ir1kg.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C006371B@dggemm510-mbs.china.huawei.com>
 <87375eqobb.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063816@dggemm510-mbs.china.huawei.com>
 <20171117073556.GB28855@cbox>
 <B8AC3E80E903784988AB3003E3E97330C00638D4@dggemm510-mbs.china.huawei.com>
 <20171118134841.3f6c9183@why.wild-wind.fr.eu.org>
 <B8AC3E80E903784988AB3003E3E97330C0068F12@dggemm510-mbx.china.huawei.com>
 <20171121122938.sydii3i36jbzi7x4@lakrids.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0069032@dggemm510-mbx.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330C0069032@dggemm510-mbx.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "mhocko@suse.com" <mhocko@suse.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "glider@google.com" <glider@google.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, Christoffer Dall <cdall@linaro.org>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, Dailei <dylix.dailei@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "labbott@redhat.com" <labbott@redhat.com>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, Zengweilin <zengweilin@huawei.com>, "opendmb@gmail.com" <opendmb@gmail.com>, Heshaoliang <heshaoliang@huawei.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "dvyukov@google.com" <dvyukov@google.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jiazhenghua <jiazhenghua@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "thgarnie@google.com" <thgarnie@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Wed, Nov 22, 2017 at 12:56:44PM +0000, Liuwenliang (Abbott Liu) wrote:
> +static inline u64 get_ttbr0(void)
> +{
> + if (IS_ENABLED(CONFIG_ARM_LPAE))
> +         return read_sysreg(TTBR0_64);
> + else
> +         return (u64)read_sysreg(TTBR0_32);
> +}

> +static inline u64 get_ttbr1(void)
> +{
> + if (IS_ENABLED(CONFIG_ARM_LPAE))
> +         return read_sysreg(TTBR1_64);
> + else
> +         return (u64)read_sysreg(TTBR1_32);
> +}

In addition to the whitespace damage that need to be fixed, there's no
need for the u64 casts here. The compiler will implicitly cast to the
return type, and as u32 and u64 are both arithmetic types, we don't need
an explicit cast here.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
