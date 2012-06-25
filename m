Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 367566B0373
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:59:22 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6878853dak.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 09:59:21 -0700 (PDT)
Date: Mon, 25 Jun 2012 09:59:16 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/3] zsmalloc: add generic path and remove x86 dependency
Message-ID: <20120625165915.GA20464@kroah.com>
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1340640878-27536-3-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340640878-27536-3-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Mon, Jun 25, 2012 at 11:14:37AM -0500, Seth Jennings wrote:
> This patch adds generic pages mapping methods that
> work on all archs in the absence of support for
> local_tlb_flush_kernel_range() advertised by the
> arch through __HAVE_LOCAL_TLB_FLUSH_KERNEL_RANGE

Is this #define something that other arches define now?  Or is this
something new that you are adding here?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
