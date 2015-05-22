Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 09BD382997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 03:02:38 -0400 (EDT)
Received: by wibt6 with SMTP id t6so37141582wib.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 00:02:37 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id bo1si2205548wjb.27.2015.05.22.00.02.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 00:02:36 -0700 (PDT)
Date: Fri, 22 May 2015 09:02:39 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 3/10] x86, asm: Change is_new_memtype_allowed() for
 WT
In-Reply-To: <1431551151-19124-4-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1505220901380.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com> <1431551151-19124-4-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Wed, 13 May 2015, Toshi Kani wrote:

> __ioremap_caller() calls reserve_memtype() to set new_pcm
> (existing map type if any), and then calls
> is_new_memtype_allowed() to verify if converting to new_pcm
> is allowed when pcm (request type) is different from new_pcm.
> 
> When WT is requested, the caller expects that writes are
> ordered and uncached.  Therefore, this patch changes
> is_new_memtype_allowed() to disallow the following cases.
> 
>  - If the request is WT, mapping type cannot be WB
>  - If the request is WT, mapping type cannot be WC
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
