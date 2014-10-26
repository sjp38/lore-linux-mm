Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id AC6D06B0069
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 21:44:59 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so1564303pdb.25
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 18:44:59 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id hh2si7408558pbb.80.2014.10.25.18.44.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Oct 2014 18:44:58 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so3508681pde.22
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 18:44:58 -0700 (PDT)
Date: Sun, 26 Oct 2014 10:44:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] zram: avoid NULL pointer access when reading
 mem_used_total
Message-ID: <20141026014450.GB3328@gmail.com>
References: <000101cff035$d9f50480$8ddf0d80$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000101cff035$d9f50480$8ddf0d80$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Dan Streetman' <ddstreet@ieee.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Nitin Gupta' <ngupta@vflare.org>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

On Sat, Oct 25, 2014 at 05:26:31PM +0800, Weijie Yang wrote:
> There is a rare NULL pointer bug in mem_used_total_show() in concurrent
> situation, like this:
> zram is not initialized, process A is a mem_used_total reader which runs
> periodicity, while process B try to init zram.
> 
> 	process A 				process B
> access meta, get a NULL value
> 						init zram, done
> init_done() is true
> access meta->mem_pool, get a NULL pointer BUG
> 
> This patch fixes this issue.
> 	
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
