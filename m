Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 821636B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:51:09 -0400 (EDT)
Date: Sun, 5 Jul 2009 19:14:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/5] add per-zone statistics to show_free_areas()
Message-ID: <20090705111440.GA2064@localhost>
References: <20090705182259.08F6.A69D9226@jp.fujitsu.com> <20090705110548.GA1898@localhost> <20090705200757.0911.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090705200757.0911.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 05, 2009 at 07:09:55PM +0800, KOSAKI Motohiro wrote:
> > On Sun, Jul 05, 2009 at 05:23:35PM +0800, KOSAKI Motohiro wrote:
> > > Subject: [PATCH] add per-zone statistics to show_free_areas()
> > > 
> > > Currently, show_free_area() mainly display system memory usage. but it
> > > doesn't display per-zone memory usage information.
> > > 
> > > However, if DMA zone OOM occur, Administrator definitely need to know
> > > per-zone memory usage information.
> > 
> > DMA zone is normally lowmem-reserved. But I think the numbers still
> > make sense for DMA32.
> > 
> > Acked-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> Yes, x86_64 have DMA and DMA32, but almost 64-bit architecture have
> 2 or 4GB "DMA" zone.

Ah Yes!

> Then, I wrote the patch description by generic name.

OK.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
