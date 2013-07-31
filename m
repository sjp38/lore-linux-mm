Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 514BA6B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 13:34:43 -0400 (EDT)
Date: Wed, 31 Jul 2013 20:34:34 +0300
From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: mm/slab: ppc: ubi: kmalloc_slab WARNING / PPC + UBI driver
Message-ID: <20130731173434.GA27470@blackmetal.musicnaut.iki.fi>
References: <51F8F827.6020108@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F8F827.6020108@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wladislav Wiebe <wladislav.kw@gmail.com>
Cc: penberg@kernel.org, cl@linux.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, dedekind1@gmail.com, dwmw2@infradead.org, linux-mtd@lists.infradead.org

Hi,

On Wed, Jul 31, 2013 at 01:42:31PM +0200, Wladislav Wiebe wrote:
> DEBUG: xxx kmalloc_slab, requested 'size' = 8388608, KMALLOC_MAX_SIZE = 4194304
[...]
> [ccd3be60] [c0099fd4] kmalloc_slab+0x48/0xe8 (unreliable)
> [ccd3be70] [c00ae650] __kmalloc+0x20/0x1b4
> [ccd3be90] [c00d46f4] seq_read+0x2a4/0x540
> [ccd3bee0] [c00fe09c] proc_reg_read+0x5c/0x90
> [ccd3bef0] [c00b4e1c] vfs_read+0xa4/0x150
> [ccd3bf10] [c00b500c] SyS_read+0x4c/0x84
> [ccd3bf40] [c000be80] ret_from_syscall+0x0/0x3c

It seems some procfs file is trying to dump 8 MB at a single go. You
need to fix that to return data in smaller chunks. What file is it?

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
