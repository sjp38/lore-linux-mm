Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC3082997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 03:15:15 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so32362886wic.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 00:15:15 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id ce7si2220149wjc.102.2015.05.22.00.15.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 00:15:14 -0700 (PDT)
Date: Fri, 22 May 2015 09:15:13 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 5/10] arch/*/asm/io.h: Add ioremap_wt() to all
 architectures
In-Reply-To: <1431551151-19124-6-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1505220909530.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com> <1431551151-19124-6-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Wed, 13 May 2015, Toshi Kani wrote:

> This patch adds ioremap_wt() to all arch-specific asm/io.h which
> define ioremap_wc() locally.  These arch-specific asm/io.h do not
> include <asm-generic/iomap.h>.  Some of them include
> <asm-generic/io.h>, but ioremap_wt() is defined for consistency
> since they define all ioremap_xxx locally.
> 
> ioremap_wt() is defined indentical to ioremap_nocache() to all
> architectures without WT support.
> 
> frv and m68k already have ioremap_writethrough().  This patch
> implements ioremap_wt() indetical to ioremap_writethrough() and
> defines ARCH_HAS_IOREMAP_WT in both architectures.

This wants a follow up patch, which replaces ioremap_writethrough() in
drivers/ with ioremap_wt and removes ioremap_writethrough() from arch/

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
