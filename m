From: David Rientjes via Linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Subject: (unknown)
Date: Thu, 28 Jan 2016 09:18:23 +1100 (AEDT)
Message-ID: <mailman.764.1453933035.12304.linuxppc-dev@lists.ozlabs.org>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
 <1453889401-43496-3-git-send-email-borntraeger@de.ibm.com>
Reply-To: David Rientjes <rientjes@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5110007734251253522=="
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1453889401-43496-3-git-send-email-borntraeger@de.ibm.com>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, davej@codemonkey.org.uk, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net
List-Id: linux-mm.kvack.org

--===============5110007734251253522==
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: <rientjes@google.com>
X-Original-To: linuxppc-dev@lists.ozlabs.org
Delivered-To: linuxppc-dev@lists.ozlabs.org
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [IPv6:2607:f8b0:400e:c03::229])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by lists.ozlabs.org (Postfix) with ESMTPS id 750C01A0054
	for <linuxppc-dev@lists.ozlabs.org>; Thu, 28 Jan 2016 09:17:09 +1100 (AEDT)
Authentication-Results: lists.ozlabs.org;
	dkim=pass (2048-bit key; unprotected) header.d=google.com header.i=@google.com header.b=YODSUiph;
	dkim-atps=neutral
Received: by mail-pa0-x229.google.com with SMTP id ho8so11398453pac.2
        for <linuxppc-dev@lists.ozlabs.org>; Wed, 27 Jan 2016 14:17:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20120113;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version:content-type;
        bh=qxdvgRmlozWtPD+pOIiOACbyRDuYpFbXvq5AK5Z/z2Q=;
        b=YODSUiphfawq2HeOMI/Xoeb3UzSvwDvaYy03SNdVYACYAH+uwmNzh7kRjxZVGPOtyL
         Tx16EaPaePrTIwQTEL47NSGHKPOayihbo9pdjYX6U5m1xS3Dg7KWdxVp8wwxH3DhCskR
         UVXn+BCHgyx5wmlL5Nee9bSHbi/PIDT89/9JbJp9ZjB7Wj3ZDVmCUHKvK2Yug6AsauJc
         GAZ9mpf/aB/q1hQYDdXzIFnAiQpcYNslIUVfgNTHXvVsscSlbWz6vronRoZRQretKlRA
         YA0PvxeD52jQwlJV6pt4vvHv6FT4Dmxf79PKVi6LLLYyIlXeQU349Mj5MZ68w2ANcOyf
         CKUg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20130820;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version:content-type;
        bh=qxdvgRmlozWtPD+pOIiOACbyRDuYpFbXvq5AK5Z/z2Q=;
        b=PKeJTaZNeTFHSwMvB1pAJg80zfHXiXnAPcjpfDP+YUsr9UCwHNAL4mbNZ5iTG9Rxxp
         1IUN2Jsa7SQOVDLHX6uyQPQ9plvM1HYQILBtzSoK2F5+yN1zPfwmNtFgkOYzS5qucdJN
         QOapTE8uuNQoq3aDPG3B+92UIKa+xHDbpTbK2WOgtQ4J0xAQKgj+9ITV5X7d/XlpPZcE
         aDiww0MB5Ob1j1MISf8HU/f1p30k9aXD4x1mkwbdLGFaU+E1W4aE8ENqPX8nIRiN9pIR
         hZ+r9xuuz4w0asdlOYd+hYIPavJsRDK+8w6+vA3kT2k28Zu/UUa5+QglgG7D1h3Xv3iL
         Yi3A==
X-Gm-Message-State: AG10YOTwe5C5fLWriF4QFk+binwwcBh9unOtsgSCpi/vV3Qfp0uTdeIy+kJJ8TUak1qGhRUS
X-Received: by 10.66.122.142 with SMTP id ls14mr45844766pab.113.1453933027459;
        Wed, 27 Jan 2016 14:17:07 -0800 (PST)
Received: from [2620:0:1008:1200:77:27bb:147d:6cc2] ([2620:0:1008:1200:77:27bb:147d:6cc2])
        by smtp.gmail.com with ESMTPSA id p66sm11277063pfi.34.2016.01.27.14.17.05
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 14:17:06 -0800 (PST)
Date: Wed, 27 Jan 2016 14:17:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Christian Borntraeger <borntraeger@de.ibm.com>
cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
    linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
    x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk
Subject: Re: [PATCH v3 2/3] x86: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <1453889401-43496-3-git-send-email-borntraeger@de.ibm.com>
Message-ID: <alpine.DEB.2.10.1601271414180.23510@chino.kir.corp.google.com>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com> <1453889401-43496-3-git-send-email-borntraeger@de.ibm.com>
User-Agent: Alpine 2.10 (DEB 1266 2009-07-14)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Wed, 27 Jan 2016, Christian Borntraeger wrote:

> We can use debug_pagealloc_enabled() to check if we can map
> the identity mapping with 2MB pages. We can also add the state
> into the dump_stack output.
> 
> The patch does not touch the code for the 1GB pages, which ignored
> CONFIG_DEBUG_PAGEALLOC. Do we need to fence this as well?
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> ---
>  arch/x86/kernel/dumpstack.c |  5 ++---
>  arch/x86/mm/init.c          |  7 ++++---
>  arch/x86/mm/pageattr.c      | 14 ++++----------
>  3 files changed, 10 insertions(+), 16 deletions(-)
> 
> diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
> index 9c30acf..32e5699 100644
> --- a/arch/x86/kernel/dumpstack.c
> +++ b/arch/x86/kernel/dumpstack.c
> @@ -265,9 +265,8 @@ int __die(const char *str, struct pt_regs *regs, long err)
>  #ifdef CONFIG_SMP
>  	printk("SMP ");
>  #endif
> -#ifdef CONFIG_DEBUG_PAGEALLOC
> -	printk("DEBUG_PAGEALLOC ");
> -#endif
> +	if (debug_pagealloc_enabled())
> +		printk("DEBUG_PAGEALLOC ");
>  #ifdef CONFIG_KASAN
>  	printk("KASAN");
>  #endif
> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
> index 493f541..39823fd 100644
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -150,13 +150,14 @@ static int page_size_mask;
>  
>  static void __init probe_page_size_mask(void)
>  {
> -#if !defined(CONFIG_DEBUG_PAGEALLOC) && !defined(CONFIG_KMEMCHECK)
> +#if !defined(CONFIG_KMEMCHECK)
>  	/*
> -	 * For CONFIG_DEBUG_PAGEALLOC, identity mapping will use small pages.
> +	 * For CONFIG_KMEMCHECK or pagealloc debugging, identity mapping will
> +	 * use small pages.
>  	 * This will simplify cpa(), which otherwise needs to support splitting
>  	 * large pages into small in interrupt context, etc.
>  	 */
> -	if (cpu_has_pse)
> +	if (cpu_has_pse && !debug_pagealloc_enabled())
>  		page_size_mask |= 1 << PG_LEVEL_2M;
>  #endif
>  

I would have thought free_init_pages() would be modified to use 
debug_pagealloc_enabled() as well?

--===============5110007734251253522==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============5110007734251253522==--
