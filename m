Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id ED51C6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 16:04:31 -0400 (EDT)
Received: by wieq12 with SMTP id q12so36260353wie.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 13:04:31 -0700 (PDT)
Received: from asavdk4.altibox.net (asavdk4.altibox.net. [109.247.116.15])
        by mx.google.com with ESMTPS id fo8si18150897wib.39.2015.10.12.13.04.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 13:04:30 -0700 (PDT)
Date: Mon, 12 Oct 2015 22:04:23 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC] arm: add __initbss section attribute
Message-ID: <20151012200422.GA29175@ravnborg.org>
References: <1444622356-8263-1-git-send-email-yalin.wang2010@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444622356-8263-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: linux@arm.linux.org.uk, arnd@arndb.de, ard.biesheuvel@linaro.org, will.deacon@arm.com, nico@linaro.org, keescook@chromium.org, catalin.marinas@arm.com, victor.kamensky@linaro.org, msalter@redhat.com, vladimir.murzin@arm.com, ggdavisiv@gmail.com, paul.gortmaker@windriver.com, mingo@kernel.org, rusty@rustcorp.com.au, mcgrof@suse.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mhocko@suse.com, jack@suse.cz, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

> --- a/include/asm-generic/vmlinux.lds.h
> +++ b/include/asm-generic/vmlinux.lds.h
>  
> -#define BSS_SECTION(sbss_align, bss_align, stop_align)			\
> +#define BSS_SECTION(sbss_align, bss_align, initbss_align, stop_align)			\

A few comments:

1) - please align the backslash at the end of the
     line with the backslash above it.
2) - you need to fix all the remaining users of BSS_SECTION.
3) - do we really need the flexibility to specify an alignment (stop_align)?
        If not - drop the extra argument.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
