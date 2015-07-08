Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 556146B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 23:49:00 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so123949889pac.2
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 20:49:00 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ca15si1678040pdb.31.2015.07.07.20.48.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 20:48:59 -0700 (PDT)
Received: by pacgz10 with SMTP id gz10so50301603pac.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 20:48:59 -0700 (PDT)
Date: Wed, 8 Jul 2015 12:49:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v6 7/7] zsmalloc: use shrinker to trigger auto-compaction
Message-ID: <20150708034928.GB1520@swordfish>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436270221-17844-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150707134445.GD3898@blaptop>
 <20150707144107.GC1450@swordfish>
 <20150707150143.GC23003@blaptop>
 <20150707151204.GE1450@swordfish>
 <20150708021836.GA1520@swordfish>
 <20150708030410.GA873@blaptop.AC68U>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150708030410.GA873@blaptop.AC68U>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (07/08/15 12:04), Minchan Kim wrote:
> Hi Sergey,
> 

Hi Minchan,

[..]
> > (a) we need something to signify that zs_unregister_shrinker() was successful
> 
> I think a) is simple way to handle it now.
> I don't want to stuck with this issue.
> 
> Please comment out why we need such boolean so after someone who has interest
> on shrinker clean-up is able to grab a chance.


OK, sure.

Do you think that (c) deserves a separate discussion (I can fork a new
discussion thread and Cc more people). It does look like we can do a bit
better and make shrinker less fragile (and probably cleanup/fix several
places in the kernel).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
