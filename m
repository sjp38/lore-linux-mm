Date: Tue, 16 May 2006 09:31:12 -0700
From: Valerie Henson <val_henson@linux.intel.com>
Subject: Re: [patch 00/14] remap_file_pages protection support
Message-ID: <20060516163111.GK9612@goober>
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au> <200605030225.54598.blaisorblade@yahoo.it> <445CC949.7050900@redhat.com> <445D75EB.5030909@yahoo.com.au> <4465E981.60302@yahoo.com.au> <20060513181945.GC9612@goober> <4469D3F8.8020305@yahoo.com.au> <20060516135135.GA28995@rhlx01.fht-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060516135135.GA28995@rhlx01.fht-esslingen.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ulrich Drepper <drepper@redhat.com>, Blaisorblade <blaisorblade@yahoo.it>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, Val Henson <val.henson@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 16, 2006 at 03:51:35PM +0200, Andreas Mohr wrote:
> 
> I cannot offer much other than some random confirmation that from my own
> oprofiling, whatever I did (often running a load test script consisting of
> launching 30 big apps at the same time), find_vma basically always showed up
> very prominently in the list of vmlinux-based code (always ranking within the
> top 4 or 5 kernel hotspots, such as timer interrupts, ACPI idle I/O etc.pp.).
> call-tracing showed it originating from mmap syscalls etc., and AFAIR quite
> some find_vma activity from oprofile itself.

This is important: Which kernel?

The cases I saw it in were in a (now old) SuSE kernel which as it
turns out had old/different vma lookup code.

Thanks,

-VAL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
