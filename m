Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3E586B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 08:16:31 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id j12so54529301lbo.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 05:16:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bd7si44068869wjb.241.2016.05.30.05.16.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 05:16:29 -0700 (PDT)
Subject: Re: [PATCH v6 03/12] mm: balloon: use general non-lru movable page
 feature
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-4-git-send-email-minchan@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <94563783-c485-8046-528c-ef0cba747225@suse.cz>
Date: Mon, 30 May 2016 14:16:28 +0200
MIME-Version: 1.0
In-Reply-To: <1463754225-31311-4-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rafael Aquini <aquini@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On 05/20/2016 04:23 PM, Minchan Kim wrote:
> Now, VM has a feature to migrate non-lru movable pages so
> balloon doesn't need custom migration hooks in migrate.c
> and compaction.c. Instead, this patch implements
> page->mapping->a_ops->{isolate|migrate|putback} functions.
>
> With that, we could remove hooks for ballooning in general
> migration functions and make balloon compaction simple.
>
> Cc: virtualization@lists.linux-foundation.org
> Cc: Rafael Aquini <aquini@redhat.com>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Signed-off-by: Gioh Kim <gi-oh.kim@profitbricks.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Except for the inode/pseudofs stuff which I'm not familiar with,

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
