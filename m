Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3616B028C
	for <linux-mm@kvack.org>; Sat, 14 Oct 2017 11:15:02 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y7so3032867pgb.16
        for <linux-mm@kvack.org>; Sat, 14 Oct 2017 08:15:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s14sor813182pgc.161.2017.10.14.08.15.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Oct 2017 08:15:00 -0700 (PDT)
Subject: Re: [PATCH for linux-next] mm/page-writeback.c: make changes of
 dirty_writeback_centisecs take effect immediately
References: <1507970307-16431-1-git-send-email-laoar.shao@gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <082a7d89-d2c1-cef7-e07d-d7876f653e92@kernel.dk>
Date: Sat, 14 Oct 2017 09:14:53 -0600
MIME-Version: 1.0
In-Reply-To: <1507970307-16431-1-git-send-email-laoar.shao@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>, akpm@linux-foundation.org
Cc: jack@suse.cz, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, yamada.masahiro@socionext.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/14/2017 02:38 AM, Yafang Shao wrote:
> This patch is the followup of the prvious patch:
> [writeback: schedule periodic writeback with sysctl].
> 
> There's another issue to fix.
> For example,
> - When the tunable was set to one hour and is reset to one second, the
>   new setting will not take effect for up to one hour.
> 
> Kicking the flusher threads immediately fixes it.

Queued up, thanks.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
