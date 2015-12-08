Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6F13E6B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 10:19:25 -0500 (EST)
Received: by wmww144 with SMTP id w144so33878074wmw.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 07:19:25 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id u128si5519728wme.112.2015.12.08.07.19.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 07:19:24 -0800 (PST)
Date: Tue, 8 Dec 2015 16:18:18 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 14/34] x86, pkeys: add functions to fetch PKRU
In-Reply-To: <20151204011444.526641BA@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081617250.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011444.526641BA@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
> +#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> +static inline u32 __read_pkru(void)
> +{
> +	unsigned int ecx = 0;
> +	unsigned int edx, pkru;

  	u32 please.

Other than that: Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

> +
> +	/*
> +	 * "rdpkru" instruction.  Places PKRU contents in to EAX,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
