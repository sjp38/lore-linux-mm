Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 7C3746B0009
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 18:58:11 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id k10so12746898iea.15
        for <linux-mm@kvack.org>; Tue, 22 Jan 2013 15:58:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1358898745-4873-1-git-send-email-minchan@kernel.org>
References: <1358898745-4873-1-git-send-email-minchan@kernel.org>
Date: Tue, 22 Jan 2013 15:58:10 -0800
Message-ID: <CAPkvG_f2mDr2p=ypqcikeNMRoE3tK1-kDjLWyz6bb9yQUpGgZQ@mail.gmail.com>
Subject: Re: [PATCH v5 1/4] zram: Fix deadlock bug in partial write
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, jmarchan@redhat.com, stable@vger.kernel.org

On Tue, Jan 22, 2013 at 3:52 PM, Minchan Kim <minchan@kernel.org> wrote:
> Now zram allocates new page with GFP_KERNEL in zram I/O path
> if IO is partial. Unfortunately, It may cuase deadlock with
> reclaim path so this patch solves the problem.
>
> Cc: Jerome Marchand <jmarchan@redhat.com>
> Cc: stable@vger.kernel.org
> Acked-by: Nitin Gupta <ngupta@vflare.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zram/zram_drv.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>

Changelog for v4 vs v5?

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
