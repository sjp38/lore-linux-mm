Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 767C26B0092
	for <linux-mm@kvack.org>; Thu, 17 May 2012 05:19:52 -0400 (EDT)
Date: Thu, 17 May 2012 18:19:42 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH v2 1/3] zsmalloc: support zsmalloc to ARM, MIPS, SUPERH
Message-ID: <20120517091942.GA24355@linux-sh.org>
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>
 <20120517083213.GC14027@linux-sh.org>
 <4FB4BFB0.4010805@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FB4BFB0.4010805@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Chen Liqin <liqin.chen@sunplusct.com>

On Thu, May 17, 2012 at 06:06:56PM +0900, Minchan Kim wrote:
> On 05/17/2012 05:32 PM, Paul Mundt wrote:
> > One thing you might consider is providing a stubbed definition that wraps
> > to flush_tlb_kernel_range() in the !SMP case, as this will extend your
> > testing coverage for staging considerably.
> 
> 
> AFAIUC, you mean following as,
> 
> ifndef CONFIG_SMP
> void flush_tlb_kernel_range(unsinged long start, unsigned log end)
> {
> 	local_flush_tlb_kernel_range(start, end);
> }
> #endif
> 
Actually I meant the opposite:

#ifndef CONFIG_SMP
#define local_flush_tlb_kernel_range flush_tlb_kernel_range
#endif

as the UP case is going to be local already. It's a bit hacky, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
