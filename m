Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 159696B0005
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 22:22:16 -0500 (EST)
Date: Sun, 3 Feb 2013 17:53:33 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v6 4/4] zram: get rid of lockdep warning
Message-ID: <20130204015333.GA6548@kroah.com>
References: <1359513702-18709-1-git-send-email-minchan@kernel.org>
 <1359513702-18709-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359513702-18709-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, jmarchan@redhat.com

On Wed, Jan 30, 2013 at 11:41:42AM +0900, Minchan Kim wrote:
> Lockdep complains about recursive deadlock of zram->init_lock.
> [1] made it false positive because we can't request IO to zram
> before setting disksize. Anyway, we should shut lockdep up to
> avoid many reporting from user.
> 
> [1] : zram: force disksize setting before using zram
> 
> Acked-by: Jerome Marchand <jmarchand@redhat.com>
> Acked-by: Nitin Gupta <ngupta@vflare.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zram/zram_drv.c   |  189 +++++++++++++++++++------------------
>  drivers/staging/zram/zram_drv.h   |   12 ++-
>  drivers/staging/zram/zram_sysfs.c |   11 ++-
>  3 files changed, 116 insertions(+), 96 deletions(-)

This patch fails to apply to my staging-next branch, but the three
others did, so I took them.  Please refresh this one and resend if you
want it applied.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
