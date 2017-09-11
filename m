Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C74676B02E5
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 15:53:00 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o200so13454666itg.2
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 12:53:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m15sor1812528iod.275.2017.09.11.12.52.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 12:52:59 -0700 (PDT)
Subject: Re: [PATCH] mm/backing-dev.c: fix an error handling path in
 'cgwb_create()'
References: <20170911194323.17833-1-christophe.jaillet@wanadoo.fr>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <512a90ae-a8bf-7ead-32ba-b4fe36866b20@kernel.dk>
Date: Mon, 11 Sep 2017 13:52:56 -0600
MIME-Version: 1.0
In-Reply-To: <20170911194323.17833-1-christophe.jaillet@wanadoo.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>, jack@suse.cz, tj@kernel.org, geliangtang@gmail.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On 09/11/2017 01:43 PM, Christophe JAILLET wrote:
> If the 'kmalloc' fails, we must go through the existing error handling
> path.

Looks good to me, probably wants a

Fixes: 52ebea749aae ("writeback: make backing_dev_info host cgroup-specific bdi_writebacks")

line as well.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
