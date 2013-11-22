Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A40856B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 17:59:30 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so1847110pdj.39
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 14:59:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id dk5si20859561pbc.166.2013.11.22.14.59.28
        for <linux-mm@kvack.org>;
        Fri, 22 Nov 2013 14:59:29 -0800 (PST)
Date: Fri, 22 Nov 2013 14:59:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm, memory-failure: fix the typo in
 me_pagecache_dirty()
Message-Id: <20131122145927.f3745790b1332c231087fd60@linux-foundation.org>
In-Reply-To: <1383914858-14533-3-git-send-email-zwu.kernel@gmail.com>
References: <1383914858-14533-1-git-send-email-zwu.kernel@gmail.com>
	<1383914858-14533-3-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

On Fri,  8 Nov 2013 20:47:38 +0800 Zhi Yong Wu <zwu.kernel@gmail.com> wrote:

> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -611,7 +611,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
>  }
>  
>  /*
> - * Dirty cache page page
> + * Dirty cache page
>   * Issues: when the error hit a hole page the error is not properly
>   * propagated.
>   */

The accurate and complete description of this page is actually
"pagecache page", so...

--- a/mm/memory-failure.c~mm-memory-failure-fix-the-typo-in-me_pagecache_dirty-fix
+++ a/mm/memory-failure.c
@@ -611,7 +611,7 @@ static int me_pagecache_clean(struct pag
 }
 
 /*
- * Dirty cache page
+ * Dirty pagecache page
  * Issues: when the error hit a hole page the error is not properly
  * propagated.
  */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
