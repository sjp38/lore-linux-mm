Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 02AE76B0074
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 00:42:29 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id md12so917390pbc.17
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 21:42:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id zk3si775855pbb.155.2014.06.12.21.42.28
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 21:42:28 -0700 (PDT)
Date: Thu, 12 Jun 2014 21:40:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/vmscan.c: wrap five parameters into shrink_result
 for reducing the stack consumption
Message-Id: <20140612214016.1beda952.akpm@linux-foundation.org>
In-Reply-To: <1402634191-3442-1-git-send-email-slaoub@gmail.com>
References: <1402634191-3442-1-git-send-email-slaoub@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 13 Jun 2014 12:36:31 +0800 Chen Yucong <slaoub@gmail.com> wrote:

> @@ -1148,7 +1146,8 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  		.priority = DEF_PRIORITY,
>  		.may_unmap = 1,
>  	};
> -	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
> +	unsigned long ret;
> +	struct shrink_result dummy = { };

You didn't like the idea of making this static?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
