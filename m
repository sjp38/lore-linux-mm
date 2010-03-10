Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D14A46B009F
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 09:31:33 -0500 (EST)
Received: by pzk10 with SMTP id 10so2057708pzk.11
        for <linux-mm@kvack.org>; Wed, 10 Mar 2010 06:31:31 -0800 (PST)
Subject: Re: [PATCH] kvm : remove redundant initialization of page->private
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <4B977244.4010603@redhat.com>
References: <1268040782-28561-1-git-send-email-shijie8@gmail.com>
	 <1268065219.1254.12.camel@barrios-desktop>  <4B977244.4010603@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 10 Mar 2010 23:31:22 +0900
Message-ID: <1268231482.1254.28.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-03-10 at 12:19 +0200, Avi Kivity wrote:

> Whitespace damage, please resend.
> 

Sorry for forgetting preformatted option of mail client.
Here is resend version.

== CUT_HERE ==

>From e64322cde914e43d080d8f3be6f72459d809a934 Mon Sep 17 00:00:00 2001
From: Minchan Kim<barrios@barrios-desktop.(none)>
Date: Tue, 9 Mar 2010 01:09:56 +0900
Subject: [PATCH] kvm : remove redundant initialization of page->private.

The prep_new_page() in page allocator calls set_page_private(page, 0). 
So we don't need to reinitialize private of page.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Avi Kivity<avi@redhat.com>
---
 arch/x86/kvm/mmu.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 741373e..9851d0e 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -326,7 +326,6 @@ static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
 		page = alloc_page(GFP_KERNEL);
 		if (!page)
 			return -ENOMEM;
-		set_page_private(page, 0);
 		cache->objects[cache->nobjs++] = page_address(page);
 	}
 	return 0;
-- 
1.6.5



-- 
Kind regards,
Minchan Kim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
