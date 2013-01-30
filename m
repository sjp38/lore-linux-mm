Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C29C16B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 03:21:15 -0500 (EST)
Date: Wed, 30 Jan 2013 17:21:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RESEND PATCH v5 1/4] zram: Fix deadlock bug in partial write
Message-ID: <20130130082112.GA23548@blaptop>
References: <1359333506-13599-1-git-send-email-minchan@kernel.org>
 <20130130042006.GA24538@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130130042006.GA24538@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, stable@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>

Hi Greg,

On Tue, Jan 29, 2013 at 11:20:06PM -0500, Greg Kroah-Hartman wrote:
> On Mon, Jan 28, 2013 at 09:38:23AM +0900, Minchan Kim wrote:
> > Now zram allocates new page with GFP_KERNEL in zram I/O path
> > if IO is partial. Unfortunately, It may cuase deadlock with
> > reclaim path so this patch solves the problem.
> > 
> > Cc: stable@vger.kernel.org
> > Cc: Jerome Marchand <jmarchan@redhat.com>
> > Acked-by: Nitin Gupta <ngupta@vflare.org>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/staging/zram/zram_drv.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Due to the discussion on this series, I don't know what patch to apply,
> so care to do a v6 of this with the patches that everyone has finally
> agreed on?

I already sent v6.
https://lkml.org/lkml/2013/1/29/680

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
