Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id A98136B00CF
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 12:56:49 -0500 (EST)
Received: by mail-lb0-f177.google.com with SMTP id z12so6263118lbi.8
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 09:56:48 -0800 (PST)
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com. [209.85.215.51])
        by mx.google.com with ESMTPS id ju18si20996769lab.8.2014.11.14.09.56.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 09:56:48 -0800 (PST)
Received: by mail-la0-f51.google.com with SMTP id q1so15529805lam.38
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 09:56:47 -0800 (PST)
Message-ID: <5466425D.1060100@cogentembedded.com>
Date: Fri, 14 Nov 2014 20:56:45 +0300
From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/11] x86, mpx: add MPX to disaabled features
References: <20141114151816.F56A3072@viggo.jf.intel.com> <20141114151823.B358EAD2@viggo.jf.intel.com>
In-Reply-To: <20141114151823.B358EAD2@viggo.jf.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, dave.hansen@linux.intel.com

Hello.

On 11/14/2014 06:18 PM, Dave Hansen wrote:

> From: Dave Hansen <dave.hansen@linux.intel.com>

> This allows us to use cpu_feature_enabled(X86_FEATURE_MPX) as
> both a runtime and compile-time check.

> When CONFIG_X86_INTEL_MPX is disabled,
> cpu_feature_enabled(X86_FEATURE_MPX) will evaluate at
> compile-time to 0. If CONFIG_X86_INTEL_MPX=y, then the cpuid
> flag will be checked at runtime.

> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
> ---

>   b/arch/x86/include/asm/disabled-features.h |    8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)

> diff -puN arch/x86/include/asm/disabled-features.h~mpx-v11-add-MPX-to-disaabled-features arch/x86/include/asm/disabled-features.h
> --- a/arch/x86/include/asm/disabled-features.h~mpx-v11-add-MPX-to-disaabled-features	2014-11-14 07:06:22.297610243 -0800
> +++ b/arch/x86/include/asm/disabled-features.h	2014-11-14 07:06:22.300610378 -0800
[...]
> @@ -34,6 +40,6 @@
>   #define DISABLED_MASK6	0
>   #define DISABLED_MASK7	0
>   #define DISABLED_MASK8	0
> -#define DISABLED_MASK9	0
> +#define DISABLED_MASK9	(DISABLE_MPX)

    These parens are not really needed. Sorry to be a PITA and not saying this 
before.

[...]

WBR, Sergei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
