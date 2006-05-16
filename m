Date: Tue, 16 May 2006 09:33:39 -0700
From: Valerie Henson <val_henson@linux.intel.com>
Subject: Re: [patch 00/14] remap_file_pages protection support
Message-ID: <20060516163339.GL9612@goober>
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au> <200605030225.54598.blaisorblade@yahoo.it> <445CC949.7050900@redhat.com> <445D75EB.5030909@yahoo.com.au> <4465E981.60302@yahoo.com.au> <20060513181945.GC9612@goober> <4469D3F8.8020305@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4469D3F8.8020305@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ulrich Drepper <drepper@redhat.com>, Blaisorblade <blaisorblade@yahoo.it>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 16, 2006 at 11:30:32PM +1000, Nick Piggin wrote:
> 
> Hi Val,
> 
> Thanks, I've tried with your most recent ebizzy and with 256 threads and
> 50,000 vmas (which gives really poor mmap_cache hits), I'm still unable
> to get find_vma above a few % of kernel time.

How excellent!  Sometimes negative results are worth publishing. :)

-VAL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
