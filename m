Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 930216B025F
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 03:23:15 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id x37so93697011ybh.3
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 00:23:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q140si19354668wme.33.2016.08.16.00.23.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 00:23:14 -0700 (PDT)
Subject: Re: [PATCH v2 4/6] mm/page_ext: rename offset to index
References: <1471315879-32294-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1471315879-32294-5-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2be8d758-0d61-30a0-9ccc-e74c69f0438a@suse.cz>
Date: Tue, 16 Aug 2016 09:23:13 +0200
MIME-Version: 1.0
In-Reply-To: <1471315879-32294-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/16/2016 04:51 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Here, 'offset' means entry index in page_ext array. Following patch
> will use 'offset' for field offset in each entry so rename current
> 'offset' to prevent confusion.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
