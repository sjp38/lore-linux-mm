Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 495FF6B0081
	for <linux-mm@kvack.org>; Tue, 15 May 2012 11:55:23 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so11299353pbb.14
        for <linux-mm@kvack.org>; Tue, 15 May 2012 08:55:22 -0700 (PDT)
Date: Tue, 15 May 2012 08:55:16 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/3] zram: remove comment in Kconfig
Message-ID: <20120515155516.GA24696@kroah.com>
References: <1336985134-31967-1-git-send-email-minchan@kernel.org>
 <1336985134-31967-2-git-send-email-minchan@kernel.org>
 <4FB119CA.2080606@linux.vnet.ibm.com>
 <4FB1BFFC.8080405@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FB1BFFC.8080405@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 15, 2012 at 11:31:24AM +0900, Minchan Kim wrote:
> On 05/14/2012 11:42 PM, Seth Jennings wrote:
> 
> > On 05/14/2012 03:45 AM, Minchan Kim wrote:
> > 
> >> Exactly speaking, zram should has dependency with
> >> zsmalloc, not x86. So x86 dependeny check is redundant.
> >>
> >> Signed-off-by: Minchan Kim <minchan@kernel.org>
> >> ---
> >>  drivers/staging/zram/Kconfig |    4 +---
> >>  1 file changed, 1 insertion(+), 3 deletions(-)
> >>
> >> diff --git a/drivers/staging/zram/Kconfig b/drivers/staging/zram/Kconfig
> >> index 9d11a4c..ee23a86 100644
> >> --- a/drivers/staging/zram/Kconfig
> >> +++ b/drivers/staging/zram/Kconfig
> >> @@ -1,8 +1,6 @@
> >>  config ZRAM
> >>  	tristate "Compressed RAM block device support"
> >> -	# X86 dependency is because zsmalloc uses non-portable pte/tlb
> >> -	# functions
> >> -	depends on BLOCK && SYSFS && X86
> >> +	depends on BLOCK && SYSFS
> > 
> > 
> > Two comments here:
> > 
> > 1) zram should really depend on ZSMALLOC instead of selecting it
> > because, as the patch has it, zram could be selected on an arch that
> > zsmalloc doesn't support.
> 
> 
> Argh, Totally my mistake. my patch didn't match with my comment, either. :(
> 
> > 
> > 2) This change would need to be done in zcache as well.
> 
> 
> I see.
> Seth, Thanks.
> 
> send v2.

It's all messed up with tabs and spaces, care to resend?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
