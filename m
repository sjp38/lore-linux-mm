Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 679A36B0009
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 00:04:29 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id x65so86208869pfb.1
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 21:04:29 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id fe7si37044595pab.100.2016.02.21.21.04.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 21:04:28 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id e127so86343535pfe.3
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 21:04:28 -0800 (PST)
Date: Mon, 22 Feb 2016 14:05:45 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v2 2/3] zram: use zs_get_huge_class_size_watermark()
Message-ID: <20160222050545.GD11961@swordfish>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222000436.GA21710@bbox>
 <20160222004047.GA4958@swordfish>
 <20160222012758.GA27829@bbox>
 <20160222015912.GA488@swordfish>
 <20160222025709.GD27829@bbox>
 <20160222035448.GB11961@swordfish>
 <20160222045458.GF27829@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160222045458.GF27829@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (02/22/16 13:54), Minchan Kim wrote:
[..]
> > well, at the same time zram must not dictate what to do. zram simply spoils
> > zsmalloc; it does not offer guaranteed good compression, and it does not let
> > zsmalloc to do it's job. zram has only excuses to be the way it is.
> > the existing zram->zsmalloc dependency looks worse than zsmalloc->zram to me.
> 
> I don't get it why you think it's zram->zsmalloc dependency.

clearly 'dependency' was simply a wrong word to use, 'enforcement' or 'policy'
are better choices here. but you got my point.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
