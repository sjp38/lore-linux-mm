Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 70F7C6B0008
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 03:06:01 -0500 (EST)
Date: Tue, 29 Jan 2013 23:20:06 -0500
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RESEND PATCH v5 1/4] zram: Fix deadlock bug in partial write
Message-ID: <20130130042006.GA24538@kroah.com>
References: <1359333506-13599-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359333506-13599-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, stable@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>

On Mon, Jan 28, 2013 at 09:38:23AM +0900, Minchan Kim wrote:
> Now zram allocates new page with GFP_KERNEL in zram I/O path
> if IO is partial. Unfortunately, It may cuase deadlock with
> reclaim path so this patch solves the problem.
> 
> Cc: stable@vger.kernel.org
> Cc: Jerome Marchand <jmarchan@redhat.com>
> Acked-by: Nitin Gupta <ngupta@vflare.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zram/zram_drv.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Due to the discussion on this series, I don't know what patch to apply,
so care to do a v6 of this with the patches that everyone has finally
agreed on?

I'm dropping these from my to-apply queue now.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
