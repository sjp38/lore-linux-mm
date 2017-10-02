Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC5676B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 07:23:24 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id w32so1159947uaw.23
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 04:23:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e6si3996361qkc.541.2017.10.02.04.23.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 04:23:24 -0700 (PDT)
Subject: Re: [PATCH RFC] mm: implement write-behind policy for sequential file
 writes
References: <150693809463.587641.5712378065494786263.stgit@buzz>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <c684ee77-27a6-1522-b443-0c6d33d569a0@redhat.com>
Date: Mon, 2 Oct 2017 13:23:18 +0200
MIME-Version: 1.0
In-Reply-To: <150693809463.587641.5712378065494786263.stgit@buzz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Jens Axboe <axboe@kernel.dk>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 10/02/2017 11:54 AM, Konstantin Khlebnikov wrote:
> This patch implements write-behind policy which tracks sequential writes
> and starts background writeback when have enough dirty pages in a row.

Does this apply to data for files which have never been written to disk 
before?

I think one of the largest benefits of the extensive write-back caching 
in Linux is that the cache is discarded if the file is deleted before it 
is ever written to disk.  (But maybe I'm wrong about this.)

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
