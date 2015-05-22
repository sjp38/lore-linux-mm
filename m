Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7D33E82997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 02:55:56 -0400 (EDT)
Received: by wgfl8 with SMTP id l8so8564162wgf.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 23:55:55 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id c8si2146929wjw.93.2015.05.21.23.55.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 21 May 2015 23:55:54 -0700 (PDT)
Date: Fri, 22 May 2015 08:55:49 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 1/10] x86, mm, pat: Set WT to PA7 slot of PAT MSR
In-Reply-To: <1431551151-19124-2-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1505220855330.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com> <1431551151-19124-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Wed, 13 May 2015, Toshi Kani wrote:
> This patch sets WT to the PA7 slot in the PAT MSR when the processor
> is not affected by the PAT errata.  The PA7 slot is chosen to improve
> robustness in the presence of errata that might cause the high PAT bit
> to be ignored.  This way a buggy PA7 slot access will hit the PA3 slot,
> which is UC, so at worst we lose performance without causing a correctness
> issue.
> 
> The following Intel processors are affected by the PAT errata.
> 
>    errata               cpuid
>    ----------------------------------------------------
>    Pentium 2, A52       family 0x6, model 0x5
>    Pentium 3, E27       family 0x6, model 0x7, 0x8
>    Pentium 3 Xenon, G26 family 0x6, model 0x7, 0x8, 0xa
>    Pentium M, Y26       family 0x6, model 0x9
>    Pentium M 90nm, X9   family 0x6, model 0xd
>    Pentium 4, N46       family 0xf, model 0x0
> 
> Instead of making sharp boundary checks, this patch makes conservative
> checks to exclude all Pentium 2, 3, M and 4 family processors.  For
> such processors, _PAGE_CACHE_MODE_WT is redirected to UC- per the
> default setup in __cachemode2pte_tbl[].
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> Reviewed-by: Juergen Gross <jgross@suse.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
