Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9C16B018F
	for <linux-mm@kvack.org>; Fri, 22 May 2015 10:27:56 -0400 (EDT)
Received: by obcus9 with SMTP id us9so14215828obc.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 07:27:56 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id zk6si1429634obc.85.2015.05.22.07.27.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 07:27:55 -0700 (PDT)
Message-ID: <1432303710.3184.3.camel@misato.fc.hp.com>
Subject: Re: [PATCH v9 5/10] arch/*/asm/io.h: Add ioremap_wt() to all
 architectures
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 22 May 2015 08:08:30 -0600
In-Reply-To: <alpine.DEB.2.11.1505220909530.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com>
	 <1431551151-19124-6-git-send-email-toshi.kani@hp.com>
	 <alpine.DEB.2.11.1505220909530.5457@nanos>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Fri, 2015-05-22 at 09:15 +0200, Thomas Gleixner wrote:
> On Wed, 13 May 2015, Toshi Kani wrote:
> 
> > This patch adds ioremap_wt() to all arch-specific asm/io.h which
> > define ioremap_wc() locally.  These arch-specific asm/io.h do not
> > include <asm-generic/iomap.h>.  Some of them include
> > <asm-generic/io.h>, but ioremap_wt() is defined for consistency
> > since they define all ioremap_xxx locally.
> > 
> > ioremap_wt() is defined indentical to ioremap_nocache() to all
> > architectures without WT support.
> > 
> > frv and m68k already have ioremap_writethrough().  This patch
> > implements ioremap_wt() indetical to ioremap_writethrough() and
> > defines ARCH_HAS_IOREMAP_WT in both architectures.
> 
> This wants a follow up patch, which replaces ioremap_writethrough() in
> drivers/ with ioremap_wt and removes ioremap_writethrough() from arch/

Will do.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
