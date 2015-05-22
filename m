Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6614782997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 03:08:59 -0400 (EDT)
Received: by wizk4 with SMTP id k4so37708402wiz.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 00:08:59 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id k7si1117796wiw.92.2015.05.22.00.08.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 00:08:57 -0700 (PDT)
Date: Fri, 22 May 2015 09:08:59 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 4/10] x86, mm, asm-gen: Add ioremap_wt() for WT
In-Reply-To: <1431551151-19124-5-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1505220908470.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com> <1431551151-19124-5-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Wed, 13 May 2015, Toshi Kani wrote:
> This patch adds ioremap_wt() for creating WT mapping on x86.
> It follows the same model as ioremap_wc() for multi-architecture
> support.  ARCH_HAS_IOREMAP_WT is defined in the x86 version of
> io.h to indicate that ioremap_wt() is implemented on x86.
> 
> Also update the PAT documentation file to cover ioremap_wt().
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
