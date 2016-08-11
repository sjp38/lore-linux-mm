Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 782E36B025E
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 09:01:11 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so8400043wmz.2
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 06:01:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ss6si2391351wjb.7.2016.08.11.06.01.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Aug 2016 06:01:10 -0700 (PDT)
Subject: Re: [PATCH 5/5] mm/page_owner: don't define fields on struct page_ext
 by hard-coding
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470809784-11516-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d6b6e7f3-4fc7-a604-3c40-d5c6d6e1b44e@suse.cz>
Date: Thu, 11 Aug 2016 15:01:07 +0200
MIME-Version: 1.0
In-Reply-To: <1470809784-11516-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/10/2016 08:16 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> There is a memory waste problem if we define field on struct page_ext
> by hard-coding. Entry size of struct page_ext includes the size of
> those fields even if it is disabled at runtime. Now, extra memory request
> at runtime is possible so page_owner don't need to define it's own fields
> by hard-coding.
>
> This patch removes hard-coded define and uses extra memory for storing
> page_owner information in page_owner. Most of code are just mechanical
> changes.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
