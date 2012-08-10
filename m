Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 5E44D6B002B
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 21:15:51 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so1264794vcb.14
        for <linux-mm@kvack.org>; Thu, 09 Aug 2012 18:15:50 -0700 (PDT)
Date: Thu, 9 Aug 2012 21:15:46 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 0/7] zram/zsmalloc promotion
Message-ID: <20120810011545.GA25218@localhost.localdomain>
References: <1344406340-14128-1-git-send-email-minchan@kernel.org>
 <5022A369.5020304@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5022A369.5020304@vflare.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>

On Wed, Aug 08, 2012 at 10:35:37AM -0700, Nitin Gupta wrote:
> On 08/07/2012 11:12 PM, Minchan Kim wrote:
> > This patchset promotes zram/zsmalloc from staging.
> > Both are very clean and zram is used by many embedded product
> > for a long time.
> > 
> > [1-3] are patches not merged into linux-next yet but needed
> > it as base for [4-5] which promotes zsmalloc.
> > Greg, if you merged [1-3] already, skip them.
> > 
> > Seth Jennings (5):
> >   1. zsmalloc: s/firstpage/page in new copy map funcs
> >   2. zsmalloc: prevent mappping in interrupt context
> >   3. zsmalloc: add page table mapping method
> >   4. zsmalloc: collapse internal .h into .c
> >   5. zsmalloc: promote to mm/
> > 
> > Minchan Kim (2):
> >   6. zram: promote zram from staging
> >   7. zram: select ZSMALLOC when ZRAM is configured
> > 
> 
> All the changes look good to me. FWIW, for the entire series:
> Acked-by: Nitin Gupta <ngupta@vflare.org>

And Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
as well. Thanks!
> 
> Thanks for all the work.
> Nitin
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
