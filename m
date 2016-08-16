Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DF9D6B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 03:21:50 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i27so159245016qte.3
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 00:21:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c3si23987078wjv.231.2016.08.16.00.21.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 00:21:49 -0700 (PDT)
Subject: Re: [PATCH v2 3/6] mm/page_owner: move page_owner specific function
 to page_owner.c
References: <1471315879-32294-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1471315879-32294-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b926de74-95ca-1d61-9aab-d35a6e9d12c8@suse.cz>
Date: Tue, 16 Aug 2016 09:21:46 +0200
MIME-Version: 1.0
In-Reply-To: <1471315879-32294-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/16/2016 04:51 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> There is no reason that page_owner specific function resides on vmstat.c.
>
> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
