Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5F316B02E8
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 16:04:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f4so8284309wmh.7
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 13:04:47 -0700 (PDT)
Received: from smtp.smtpout.orange.fr (smtp07.smtpout.orange.fr. [80.12.242.129])
        by mx.google.com with ESMTPS id r6si7530303wre.366.2017.09.11.13.04.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 13:04:44 -0700 (PDT)
Subject: Re: [PATCH] mm/backing-dev.c: fix an error handling path in
 'cgwb_create()'
References: <20170911194323.17833-1-christophe.jaillet@wanadoo.fr>
 <512a90ae-a8bf-7ead-32ba-b4fe36866b20@kernel.dk>
From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Message-ID: <1c50dbc9-f765-5b90-1f00-7d87205382d7@wanadoo.fr>
Date: Mon, 11 Sep 2017 22:04:42 +0200
MIME-Version: 1.0
In-Reply-To: <512a90ae-a8bf-7ead-32ba-b4fe36866b20@kernel.dk>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: fr
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>, jack@suse.cz, tj@kernel.org, geliangtang@gmail.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

Le 11/09/2017 A  21:52, Jens Axboe a A(C)critA :
> On 09/11/2017 01:43 PM, Christophe JAILLET wrote:
>> If the 'kmalloc' fails, we must go through the existing error handling
>> path.
> Looks good to me, probably wants a
>
> Fixes: 52ebea749aae ("writeback: make backing_dev_info host cgroup-specific bdi_writebacks")
>
> line as well.
>
Hi,

do you want me to resend with the Fixes tag? Or will it be added if merged?

CJ

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
