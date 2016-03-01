Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id E31D0828E2
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 08:49:35 -0500 (EST)
Received: by mail-oi0-f48.google.com with SMTP id m82so128813531oif.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 05:49:35 -0800 (PST)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id x3si25693209oel.12.2016.03.01.05.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 05:49:35 -0800 (PST)
Received: by mail-ob0-x22c.google.com with SMTP id xx9so53230092obc.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 05:49:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1456839793-31276-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <201603012155.h5NIKpFO%fengguang.wu@intel.com>
	<1456839793-31276-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 1 Mar 2016 22:49:35 +0900
Message-ID: <CAAmzW4PKHg+XfeRb4TN1qQbyJXCzm244iVNEwSwT+Qa33+pH7g@mail.gmail.com>
Subject: Re: [PATCH] mm/page_ref: fix build failure for xtensa
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-03-01 22:43 GMT+09:00  <js1304@gmail.com>:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> This patch includes struct page definition to fix build failure on xtensa.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/debug_page_ref.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/debug_page_ref.c b/mm/debug_page_ref.c
> index 87e60e8..1aef3d5 100644
> --- a/mm/debug_page_ref.c
> +++ b/mm/debug_page_ref.c
> @@ -1,3 +1,4 @@
> +#include <linux/mm_types.h>
>  #include <linux/tracepoint.h>
>
>  #define CREATE_TRACE_POINTS

Seems like I used wrong message-id for in-reply-to.

Andrew, please fold this patch into
mm-page_ref-add-tracepoint-to-track-down-page-reference-manipulation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
