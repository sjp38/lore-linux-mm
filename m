Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 530FD6B0260
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 03:25:36 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id f123so151610691ywd.2
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 00:25:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l7si24047058wjj.147.2016.08.16.00.25.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 00:25:35 -0700 (PDT)
Subject: Re: [PATCH v2 5/6] mm/page_ext: support extra space allocation by
 page_ext user
References: <1471315879-32294-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1471315879-32294-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c797f056-60a5-eeb9-9917-e5f7971f106e@suse.cz>
Date: Tue, 16 Aug 2016 09:25:34 +0200
MIME-Version: 1.0
In-Reply-To: <1471315879-32294-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/16/2016 04:51 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Until now, if some page_ext users want to use it's own field on page_ext,
> it should be defined in struct page_ext by hard-coding. It has a problem
> that wastes memory in following situation.
>
> struct page_ext {
>  #ifdef CONFIG_A
> 	int a;
>  #endif
>  #ifdef CONFIG_B
> 	int b;
>  #endif
> };
>
> Assume that kernel is built with both CONFIG_A and CONFIG_B.
> Even if we enable feature A and doesn't enable feature B at runtime,
> each entry of struct page_ext takes two int rather than one int.
> It's undesirable result so this patch tries to fix it.
>
> To solve above problem, this patch implements to support extra space
> allocation at runtime. When need() callback returns true, it's extra
> memory requirement is summed to entry size of page_ext. Also, offset
> for each user's extra memory space is returned. With this offset,
> user can use this extra space and there is no need to define needed
> field on page_ext by hard-coding.
>
> This patch only implements an infrastructure. Following patch will use it
> for page_owner which is only user having it's own fields on page_ext.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
