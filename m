Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1486B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 09:56:13 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id j185so7344025qkj.15
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 06:56:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor8748416qtd.118.2017.11.06.06.56.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 06:56:12 -0800 (PST)
Date: Mon, 6 Nov 2017 06:56:09 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] writeback: remove the unused function parameter
Message-ID: <20171106145609.GX3252168@devbig577.frc2.facebook.com>
References: <1509685485-15278-1-git-send-email-wanglong19@meituan.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509685485-15278-1-git-send-email-wanglong19@meituan.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <wanglong19@meituan.com>
Cc: jack@suse.cz, akpm@linux-foundation.org, gregkh@linuxfoundation.org, axboe@fb.com, nborisov@suse.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 03, 2017 at 01:04:45AM -0400, Wang Long wrote:
> The parameter `struct bdi_writeback *wb` is not been used in the function
> body. so we just remove it.
> 
> Signed-off-by: Wang Long <wanglong19@meituan.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
