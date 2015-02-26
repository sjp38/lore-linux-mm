Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id EB7096B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 15:05:03 -0500 (EST)
Received: by lbvn10 with SMTP id n10so13152986lbv.6
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 12:05:03 -0800 (PST)
Received: from filtteri1.pp.htv.fi (filtteri1.pp.htv.fi. [213.243.153.184])
        by mx.google.com with ESMTP id v2si1447419lav.12.2015.02.26.12.05.01
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 12:05:02 -0800 (PST)
Date: Thu, 26 Feb 2015 22:04:55 +0200
From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: [PATCHv3 01/17] mm: add missing __PAGETABLE_{PUD,PMD}_FOLDED
 defines
Message-ID: <20150226200455.GB14117@fuloong-minipc.musicnaut.iki.fi>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1424950520-90188-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424950520-90188-2-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Helge Deller <deller@gmx.de>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Hi,

On Thu, Feb 26, 2015 at 01:35:04PM +0200, Kirill A. Shutemov wrote:
> Core mm expects __PAGETABLE_{PUD,PMD}_FOLDED to be defined if these page
> table levels folded. Usually, these defines are provided by
> <asm-generic/pgtable-nopmd.h> and <asm-generic/pgtable-nopud.h>.
> 
> But some architectures fold page table levels in a custom way. They need
> to define these macros themself. This patch adds missing defines.
> 
> The patch fixes mm->nr_pmds underflow and eliminates dead __pmd_alloc()
> and __pud_alloc() on architectures without these page table levels.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Aaro Koskinen <aaro.koskinen@iki.fi>

PA-RISC change:

Tested-by: Aaro Koskinen <aaro.koskinen@iki.fi>

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
