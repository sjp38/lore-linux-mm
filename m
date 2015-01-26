Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id BBC846B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 10:45:29 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so12493112pdb.11
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:45:29 -0800 (PST)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id h10si12713213pdl.88.2015.01.26.07.45.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 07:45:28 -0800 (PST)
Received: by mail-pd0-f171.google.com with SMTP id fp1so12570317pdb.2
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:45:28 -0800 (PST)
Date: Tue, 27 Jan 2015 00:45:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: free meta table in zram_meta_free
Message-ID: <20150126154506.GA528@blaptop>
References: <1422107153-9701-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422107153-9701-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: ngupta@vflare.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Sat, Jan 24, 2015 at 09:45:53PM +0800, Ganesh Mahendran wrote:
> zram_meta_alloc() and zram_meta_free() are a pair.
> In zram_meta_alloc(), meta table is allocated. So it it better to free
> it in zram_meta_free().
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Minchan Kim <minchan@kernel.org>

Looks good to me but it seems the patch is based on my recent work
"zram: free meta out of init_lock".
Please resend it on recent mmotm because I will respin my patch and
your patch is orthogonal with mine.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
