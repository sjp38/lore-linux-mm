Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 416176B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 14:26:44 -0400 (EDT)
Received: by mail-io0-f178.google.com with SMTP id e3so124494679ioa.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 11:26:44 -0700 (PDT)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id x77si10793291iod.88.2016.03.31.11.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 11:26:43 -0700 (PDT)
Received: by mail-io0-x236.google.com with SMTP id a129so116352106ioe.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 11:26:43 -0700 (PDT)
Subject: Re: [PATCH] writeback: fix the wrong congested state variable
 definition
References: <1459430381-13947-1-git-send-email-xiakaixu@huawei.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <56FD6BE0.1050802@kernel.dk>
Date: Thu, 31 Mar 2016 12:26:40 -0600
MIME-Version: 1.0
In-Reply-To: <1459430381-13947-1-git-send-email-xiakaixu@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kaixu Xia <xiakaixu@huawei.com>, tj@kernel.org
Cc: lizefan@huawei.com, jack@suse.cz, linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, neilb@suse.de, linux-kernel@vger.kernel.org

On 03/31/2016 07:19 AM, Kaixu Xia wrote:
> The right variable definition should be wb_congested_state that
> include WB_async_congested and WB_sync_congested. So fix it.

Added, thanks.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
