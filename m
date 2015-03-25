Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id BEBFC6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 11:09:34 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so31255394pdb.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 08:09:34 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id fc4si4116508pbc.28.2015.03.25.08.09.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 08:09:34 -0700 (PDT)
Received: by padcy3 with SMTP id cy3so31735001pad.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 08:09:33 -0700 (PDT)
Date: Thu, 26 Mar 2015 00:09:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] zsmalloc: remove synchronize_rcu from zs_compact()
Message-ID: <20150325150927.GE3814@blaptop>
References: <1427117199-2763-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1427117199-2763-2-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427117199-2763-2-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Mon, Mar 23, 2015 at 10:26:38PM +0900, Sergey Senozhatsky wrote:
> Do not synchronize rcu in zs_compact(). Neither zsmalloc not
> zram use rcu.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
