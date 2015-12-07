Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id A42166B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 06:22:56 -0500 (EST)
Received: by wmvv187 with SMTP id v187so161411656wmv.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 03:22:56 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.74])
        by mx.google.com with ESMTPS id ci1si4054738wjc.27.2015.12.07.03.22.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 03:22:54 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v5 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
Date: Mon, 07 Dec 2015 12:13:55 +0100
Message-ID: <1720878.JdEcLd8bhL@wuerfel>
In-Reply-To: <56655EC8.6030905@nvidia.com>
References: <1449000658-11475-1-git-send-email-dcashman@android.com> <1449000658-11475-4-git-send-email-dcashman@android.com> <56655EC8.6030905@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jon Hunter <jonathanh@nvidia.com>
Cc: Daniel Cashman <dcashman@android.com>, linux-kernel@vger.kernel.org, dcashman@google.com, linux-doc@vger.kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, hpa@zytor.com, mingo@kernel.org, aarcange@redhat.com, linux@arm.linux.org.uk, corbet@lwn.net, xypron.glpk@gmx.de, x86@kernel.org, hecmargi@upv.es, mgorman@suse.de, rientjes@google.com, bp@suse.de, nnk@google.com, dzickus@redhat.com, keescook@chromium.org, jpoimboe@redhat.com, tglx@linutronix.de, n-horiguchi@ah.jp.nec.com, linux-arm-kernel@lists.infradead.org, salyzyn@android.com, ebiederm@xmission.com, jeffv@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com

On Monday 07 December 2015 10:26:16 Jon Hunter wrote:
> 
> diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
> index af461b935137..e59a75a308bc 100644
> --- a/arch/arm64/mm/mmap.c
> +++ b/arch/arm64/mm/mmap.c
> @@ -51,7 +51,7 @@ unsigned long arch_mmap_rnd(void)
>  {
>         unsigned long rnd;
>  
> -ifdef CONFIG_COMPAT
> +#ifdef CONFIG_COMPAT
>         if (test_thread_flag(TIF_32BIT))
>                 rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_compat_bits);
>         else
> 
> Cheers
> 

Ideally we'd remove the #ifdef around the mmap_rnd_compat_bits declaration
and change this code to use

	if (IS_ENABLED(CONFIG_COMPAT) && test_thread_flag(TIF_32BIT))

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
