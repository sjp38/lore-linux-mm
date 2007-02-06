Date: Mon, 5 Feb 2007 21:31:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC/PATCH] prepare_unmapped_area
Message-Id: <20070205213130.308a8c76.akpm@linux-foundation.org>
In-Reply-To: <1170738296.2620.220.camel@localhost.localdomain>
References: <200702060405.l1645R7G009668@shell0.pdx.osdl.net>
	<1170736938.2620.213.camel@localhost.localdomain>
	<20070206044516.GA16647@wotan.suse.de>
	<1170738296.2620.220.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <npiggin@suse.de>, hugh@veritas.com, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 06 Feb 2007 16:04:56 +1100 Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> +#ifndef HAVE_ARCH_PREPARE_UNMAPPED_AREA
> +int arch_prepare_unmapped_area(struct file *file, unsigned long addr,

__attribute__((weak)), please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
