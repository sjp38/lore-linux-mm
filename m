Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E39A6B025E
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 03:03:45 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id u5so522571939pgi.7
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 00:03:45 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id b3si22387063pll.166.2016.12.29.00.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Dec 2016 00:03:44 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id i5so18224734pgh.2
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 00:03:44 -0800 (PST)
Date: Thu, 29 Dec 2016 17:03:51 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: mm: fix typo of cache_alloc_zspage()
Message-ID: <20161229080351.GC3892@jagdpanzerIV.localdomain>
References: <58646FB7.2040502@huawei.com>
 <20161229064457.GD1815@bbox>
 <20161229065205.GA3892@jagdpanzerIV.localdomain>
 <20161229065935.GE1815@bbox>
 <20161229073403.GB3892@jagdpanzerIV.localdomain>
 <20161229075654.GF1815@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161229075654.GF1815@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>, ngupta@vflare.org, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On (12/29/16 16:56), Minchan Kim wrote:
> > for instance, we can have Xishi's fix up as part of this "fix documentation
> > typos" patch. which can be counted in as trivial.
> 
> Xishi, Could you send your patch with fixing ones Sergey pointed out
> if Sergey doesn't mind?

I don't.
  Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

will be more than enough (well, to me).


> > - * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
> > + * A single 'zspage' is composed of up to 2^N discontinuous 0-order (single)
> 
> Hmm, discontinuous is right?
> I'm not a native but discontiguos is wrong? "contiguous" was used mm part widely.

oh, you're definitely much closer to native speaker than `aspell' tool!
you're right. Xishi, please drop that 'discontiguous' "correction".
sorry for that.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
