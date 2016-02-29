Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D5B276B0253
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 01:25:10 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id fl4so86569207pad.0
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 22:25:10 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id l62si40682772pfi.125.2016.02.28.22.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 22:25:09 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id w128so41538371pfb.2
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 22:25:09 -0800 (PST)
Date: Mon, 29 Feb 2016 15:26:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: add compact column to pool stat
Message-ID: <20160229062628.GA576@swordfish>
References: <1456554233-9088-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20160229060247.GA3382@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229060247.GA3382@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

On (02/29/16 15:02), Minchan Kim wrote:
> On Sat, Feb 27, 2016 at 03:23:53PM +0900, Sergey Senozhatsky wrote:
> > Add a new column to pool stats, which will tell us class' zs_can_compact()
> > number, so it will be easier to analyze zsmalloc fragmentation.
> 
> Just nitpick:
> 
> Strictly speaking, zs_can_compact number is number of "ideal freeable page
> by compaction". How about using high level term in description rather than
> function name?

OK, makes sense.


> > At the moment, we have only numbers of FULL and ALMOST_EMPTY classes, but
> > they don't tell us how badly the class is fragmented internally.
> > 
> > The new /sys/kernel/debug/zsmalloc/zramX/classes output look as follows:
> > 
> >  class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage compact
> > [..]
> >     12   224           0            2           146          5          8                4       4
> >     13   240           0            0             0          0          0                1       0
> >     14   256           1           13          1840       1672        115                1      10
> >     15   272           0            0             0          0          0                1       0
> > [..]
> >     49   816           0            3           745        735        149                1       2
> >     51   848           3            4           361        306         76                4       8
> >     52   864          12           14           378        268         81                3      21
> >     54   896           1           12           117         57         26                2      12
> >     57   944           0            0             0          0          0                3       0
> > [..]
> >  Total                26          131         12709      10994       1071                      134
> > 
> > For example, from this particular output we can easily conclude that class-896
> > is heavily fragmented -- it occupies 26 pages, 12 can be freed by compaction.
> 
> How about using "freeable" or something which could represent "freeable"?
> IMO, it's more strightforward for user.

OK. didn't want to put any long column name there, which would bloat the
output. will take a look.

> Other than that,
> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> 
> 
> Thanks for the nice job!

thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
