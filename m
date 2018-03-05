Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4BBB6B0006
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 09:54:48 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id a9so8393472oia.1
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 06:54:48 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s91si3874798otb.271.2018.03.05.06.54.47
        for <linux-mm@kvack.org>;
        Mon, 05 Mar 2018 06:54:47 -0800 (PST)
Date: Mon, 5 Mar 2018 14:54:36 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 14/14] khwasan: default the instrumentation mode to
 inline
Message-ID: <20180305145435.tfaldb334lp4obhi@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <1943a345f4fb7e8e8f19b4ece2457bccd772f0dc.1520017438.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1943a345f4fb7e8e8f19b4ece2457bccd772f0dc.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 02, 2018 at 08:44:33PM +0100, Andrey Konovalov wrote:
> There are two reasons to use outline instrumentation:
> 1. Outline instrumentation reduces the size of the kernel text, and should
>    be used where this size matters.
> 2. Outline instrumentation is less invasive and can be used for debugging
>    for KASAN developers, when it's not clear whether some issue is caused
>    by KASAN or by something else.
> 
> For the rest cases inline instrumentation is preferrable, since it's
> faster.
> 
> This patch changes the default instrumentation mode to inline.
> ---
>  lib/Kconfig.kasan | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index ab34e7d7d3a7..8ea6ae26b4a3 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -70,7 +70,7 @@ config KASAN_EXTRA
>  choice
>  	prompt "Instrumentation type"
>  	depends on KASAN
> -	default KASAN_OUTLINE
> +	default KASAN_INLINE

Some compilers don't support KASAN_INLINE, but do support KASAN_OUTLINE.
IIRC that includes the latest clang release, but I could be wrong.

If that's the case, changing the default here does not seem ideal.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
