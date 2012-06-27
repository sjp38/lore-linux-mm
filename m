Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 8B1356B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 22:43:06 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1073108pbb.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 19:43:05 -0700 (PDT)
Date: Tue, 26 Jun 2012 19:43:01 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3] zram/zcache: swtich Kconfig dependency from X86 to
 ZSMALLOC
Message-ID: <20120627024301.GA8468@kroah.com>
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1340640878-27536-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <4FEA71E5.5090808@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FEA71E5.5090808@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Wed, Jun 27, 2012 at 11:37:25AM +0900, Minchan Kim wrote:
> On 06/26/2012 01:14 AM, Seth Jennings wrote:
> 
> > This patch switches zcache and zram dependency to ZSMALLOC
> > rather than X86.  There is no net change since ZSMALLOC
> > depends on X86, however, this prevent further changes to
> > these files as zsmalloc dependencies change.
> > 
> > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 
> Reviewed-by: Minchan Kim <minchan@kernel.org>
> 
> It could be merged regardless of other patches in this series.

I already did :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
