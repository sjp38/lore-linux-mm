Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8111C6B0279
	for <linux-mm@kvack.org>; Sun,  2 Jul 2017 22:16:56 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 125so25547132pgi.2
        for <linux-mm@kvack.org>; Sun, 02 Jul 2017 19:16:56 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f23si11938796plk.160.2017.07.02.19.16.55
        for <linux-mm@kvack.org>;
        Sun, 02 Jul 2017 19:16:55 -0700 (PDT)
Date: Mon, 3 Jul 2017 11:16:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify zs_max_alloc_size handling
Message-ID: <20170703021654.GC2567@bbox>
References: <20170630012436.GA24520@bbox>
 <20170630114859.1979-1-jmarchan@redhat.com>
 <20170703021312.GB2567@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170703021312.GB2567@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Mahendran Ganesh <opensource.ganesh@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Forgot to add Andrew.

On Mon, Jul 03, 2017 at 11:13:12AM +0900, Minchan Kim wrote:
> On Fri, Jun 30, 2017 at 01:48:59PM +0200, Jerome Marchand wrote:
> > Commit 40f9fb8cffc6 ("mm/zsmalloc: support allocating obj with size of
> > ZS_MAX_ALLOC_SIZE") fixes a size calculation error that prevented
> > zsmalloc to allocate an object of the maximal size
> > (ZS_MAX_ALLOC_SIZE). I think however the fix is unneededly
> > complicated.
> > 
> > This patch replaces the dynamic calculation of zs_size_classes at init
> > time by a compile time calculation that uses the DIV_ROUND_UP() macro
> > already used in get_size_class_index().
> > 
> > Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> 
> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
