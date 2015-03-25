Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 325DA6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 11:07:59 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so31188551pdb.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 08:07:58 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id qc10si4049503pac.160.2015.03.25.08.07.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 08:07:58 -0700 (PDT)
Received: by pacwe9 with SMTP id we9so31752999pac.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 08:07:58 -0700 (PDT)
Date: Thu, 26 Mar 2015 00:07:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] zsmalloc: micro-optimize zs_object_copy()
Message-ID: <20150325150750.GD3814@blaptop>
References: <1427210687-6634-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1427210687-6634-3-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427210687-6634-3-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Wed, Mar 25, 2015 at 12:24:47AM +0900, Sergey Senozhatsky wrote:
> A micro-optimization. Avoid additional branching and reduce
> (a bit) registry pressure (f.e. s_off += size; d_off += size;
> may be calculated twise: first for >= PAGE_SIZE check and later
> for offset update in "else" clause).
> 
> /scripts/bloat-o-meter shows some improvement
> 
> add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-10 (-10)
> function                          old     new   delta
> zs_object_copy                    550     540     -10
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
