Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 63AFA6B0253
	for <linux-mm@kvack.org>; Tue, 10 May 2016 11:14:04 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 68so13578261lfq.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 08:14:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r64si3702920wme.10.2016.05.10.08.14.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 08:14:03 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm/page_owner: introduce split_page_owner and replace
 manual handling
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1462252984-8524-5-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5731FABA.8070308@suse.cz>
Date: Tue, 10 May 2016 17:14:02 +0200
MIME-Version: 1.0
In-Reply-To: <1462252984-8524-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/03/2016 07:23 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> split_page() calls set_page_owner() to set up page_owner to each pages.
> But, it has a drawback that head page and the others have different
> stacktrace because callsite of set_page_owner() is slightly differnt.
> To avoid this problem, this patch copies head page's page_owner to
> the others. It needs to introduce new function, split_page_owner() but
> it also remove the other function, get_page_owner_gfp() so looks good
> to do.

OK.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
