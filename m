Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A62F6B53EE
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:23:32 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id s3so1416735otb.0
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:23:32 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o21si1305883ote.13.2018.11.29.10.23.31
        for <linux-mm@kvack.org>;
        Thu, 29 Nov 2018 10:23:31 -0800 (PST)
Date: Thu, 29 Nov 2018 18:23:24 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v8 2/8] uaccess: add untagged_addr definition for other
 arches
Message-ID: <20181129182323.GI22027@arrakis.emea.arm.com>
References: <cover.1541687720.git.andreyknvl@google.com>
 <c9028422854fb5bfb79d798397b30d4701207062.1541687720.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c9028422854fb5bfb79d798397b30d4701207062.1541687720.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Evgeniy Stepanov <eugenis@google.com>

On Thu, Nov 08, 2018 at 03:36:09PM +0100, Andrey Konovalov wrote:
> diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> index efe79c1cdd47..c045b4eff95e 100644
> --- a/include/linux/uaccess.h
> +++ b/include/linux/uaccess.h
> @@ -13,6 +13,10 @@
>  
>  #include <asm/uaccess.h>
>  
> +#ifndef untagged_addr
> +#define untagged_addr(addr) addr
> +#endif

Nitpick: add braces around (addr). Otherwise:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
