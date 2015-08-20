Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id D02AF6B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 15:47:28 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so2200236wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 12:47:28 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id mx11si14520998wic.49.2015.08.20.12.47.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 12:47:27 -0700 (PDT)
Date: Thu, 20 Aug 2015 21:46:50 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 1/10] x86/vdso32: Define PGTABLE_LEVELS to 32bit
 VDSO
In-Reply-To: <1438811013-30983-2-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1508202145540.3873@nanos>
References: <1438811013-30983-1-git-send-email-toshi.kani@hp.com> <1438811013-30983-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com

On Wed, 5 Aug 2015, Toshi Kani wrote:

> In case of CONFIG_X86_64, vdso32/vclock_gettime.c fakes a 32bit
> kernel configuration by re-defining it to CONFIG_X86_32.  However,
> it does not re-define CONFIG_PGTABLE_LEVELS leaving it as 4 levels.
> Fix it by re-defining CONFIG_PGTABLE_LEVELS to 2 as X86_PAE is not
> set.

You fail to explain WHY this is required. I have not yet spotted any
code in vclock_gettime.c which is affected by this.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
