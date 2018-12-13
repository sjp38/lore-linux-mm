Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9B118E0161
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 23:03:14 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id w2so530437edc.13
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 20:03:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b27sor555151edn.5.2018.12.12.20.03.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 20:03:13 -0800 (PST)
Date: Thu, 13 Dec 2018 04:03:12 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, memory_hotplug: pass next_memory_node to
 new_page_nodemask()
Message-ID: <20181213040312.ql6az6spnkpbicjq@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181213032744.68323-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181213032744.68323-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de, david@redhat.com

On Thu, Dec 13, 2018 at 11:27:44AM +0800, Wei Yang wrote:
>As the document says new_page_nodemask() will try to allocate from a
>different node, but current behavior just do the opposite by passing
>current nid as preferred_nid to new_page_nodemask().
>

Hmm... my understanding is not correct.

Sorry for the broadcasting.

>This patch pass next_memory_node as preferred_nid to new_page_nodemask()
>to fix it.
>
>Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>---
> mm/memory_hotplug.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index 6910e0eea074..0c075aac0a81 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -1335,7 +1335,7 @@ static struct page *new_node_page(struct page *page, unsigned long private)
> 	if (nodes_empty(nmask))
> 		node_set(nid, nmask);
> 
>-	return new_page_nodemask(page, nid, &nmask);
>+	return new_page_nodemask(page, next_memory_node(nid), &nmask);
> }
> 
> #define NR_OFFLINE_AT_ONCE_PAGES	(256)
>-- 
>2.15.1

-- 
Wei Yang
Help you, Help me
