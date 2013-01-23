Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id C201D6B0011
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 19:06:49 -0500 (EST)
Date: Wed, 23 Jan 2013 09:06:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 1/4] zram: Fix deadlock bug in partial write
Message-ID: <20130123000648.GA2723@blaptop>
References: <1358898745-4873-1-git-send-email-minchan@kernel.org>
 <CAPkvG_f2mDr2p=ypqcikeNMRoE3tK1-kDjLWyz6bb9yQUpGgZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPkvG_f2mDr2p=ypqcikeNMRoE3tK1-kDjLWyz6bb9yQUpGgZQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, jmarchan@redhat.com, stable@vger.kernel.org

Hi Nitin,

On Tue, Jan 22, 2013 at 03:58:10PM -0800, Nitin Gupta wrote:
> On Tue, Jan 22, 2013 at 3:52 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Now zram allocates new page with GFP_KERNEL in zram I/O path
> > if IO is partial. Unfortunately, It may cuase deadlock with
> > reclaim path so this patch solves the problem.
> >
> > Cc: Jerome Marchand <jmarchan@redhat.com>
> > Cc: stable@vger.kernel.org
> > Acked-by: Nitin Gupta <ngupta@vflare.org>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/staging/zram/zram_drv.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> 
> Changelog for v4 vs v5?

It's just adding your Acked-by in whole series.
I thought it's minor.

Thanks for the review, Nitin.

> 
> Thanks,
> Nitin
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
