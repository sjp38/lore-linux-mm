Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83C446B0279
	for <linux-mm@kvack.org>; Sun,  2 Jul 2017 22:13:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v62so188658009pfd.10
        for <linux-mm@kvack.org>; Sun, 02 Jul 2017 19:13:15 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id e61si12052807plb.200.2017.07.02.19.13.13
        for <linux-mm@kvack.org>;
        Sun, 02 Jul 2017 19:13:14 -0700 (PDT)
Date: Mon, 3 Jul 2017 11:13:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify zs_max_alloc_size handling
Message-ID: <20170703021312.GB2567@bbox>
References: <20170630012436.GA24520@bbox>
 <20170630114859.1979-1-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170630114859.1979-1-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Mahendran Ganesh <opensource.ganesh@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 30, 2017 at 01:48:59PM +0200, Jerome Marchand wrote:
> Commit 40f9fb8cffc6 ("mm/zsmalloc: support allocating obj with size of
> ZS_MAX_ALLOC_SIZE") fixes a size calculation error that prevented
> zsmalloc to allocate an object of the maximal size
> (ZS_MAX_ALLOC_SIZE). I think however the fix is unneededly
> complicated.
> 
> This patch replaces the dynamic calculation of zs_size_classes at init
> time by a compile time calculation that uses the DIV_ROUND_UP() macro
> already used in get_size_class_index().
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
