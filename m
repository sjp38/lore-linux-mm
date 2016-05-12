Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5EF6B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 07:57:16 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so60526552wme.1
        for <linux-mm@kvack.org>; Thu, 12 May 2016 04:57:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o84si1784822wmb.94.2016.05.12.04.57.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 May 2016 04:57:14 -0700 (PDT)
Subject: Re: [PATCH 6/6] mm/page_owner: use stackdepot to store stacktrace
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1462252984-8524-7-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57346F98.3040401@suse.cz>
Date: Thu, 12 May 2016 13:57:12 +0200
MIME-Version: 1.0
In-Reply-To: <1462252984-8524-7-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/03/2016 07:23 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Currently, we store each page's allocation stacktrace on corresponding
> page_ext structure and it requires a lot of memory. This causes the problem
> that memory tight system doesn't work well if page_owner is enabled.
> Moreover, even with this large memory consumption, we cannot get full
> stacktrace because we allocate memory at boot time and just maintain
> 8 stacktrace slots to balance memory consumption. We could increase it
> to more but it would make system unusable or change system behaviour.
>
> To solve the problem, this patch uses stackdepot to store stacktrace.

FTR, this sounds useful and I've read your discussion with Michal, so 
I'll wait for the next version.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
