Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 040066B025C
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 23:17:47 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so43057280pab.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:17:46 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id rp7si13715361pab.99.2016.02.18.20.17.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 20:17:46 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id e127so43855791pfe.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:17:46 -0800 (PST)
Date: Fri, 19 Feb 2016 13:19:02 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160219041902.GA976@swordfish>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
 <CAAmzW4O-yQ5GBTE-6WvCL-hZeqyW=k3Fzn4_9G2qkMmp=ceuJg@mail.gmail.com>
 <20160218095536.GA503@swordfish>
 <20160218101909.GB503@swordfish>
 <CAAmzW4NQt4jD2q92Hh4XFzt5fV=-i3J9eoxS3now6Y4Xw7OqGg@mail.gmail.com>
 <20160219041601.GA820@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160219041601.GA820@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/19/16 13:16), Sergey Senozhatsky wrote:
> # cat /sys/kernel/debug/zsmalloc/zram0/classes 
>   class  size  huge almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage
>      0    32             0            0             0          0          0                1
>      1    48             0            0             0          0          0                3
>      2    64             3            0         31360      31355        490                1
>      3    80             1            1         62781      62753       1231                1
[..]
>    254  4096 Y           0            0        632586     632586     632586                1
> 

> so BAD classes are 10 times more often than 64 bytes objects for example. and not all of 4096
a typo, 				^^^^^ 80 bytes. and 20 times class 64.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
