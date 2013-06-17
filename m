Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 333336B003D
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 19:56:20 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id tj12so3371018pac.12
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 16:56:19 -0700 (PDT)
Date: Mon, 17 Jun 2013 16:56:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Remove unlikely from the current_order test
In-Reply-To: <51BF8860.7010909@gmail.com>
Message-ID: <alpine.DEB.2.02.1306171656050.24663@chino.kir.corp.google.com>
References: <51BF8860.7010909@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 18 Jun 2013, Zhang Yanfei wrote:

> From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> 
> In __rmqueue_fallback(), current_order loops down from MAX_ORDER - 1
> to the order passed. MAX_ORDER is typically 11 and pageblock_order
> is typically 9 on x86. Integer division truncates, so pageblock_order / 2
> is 4.  For the first eight iterations, it's guaranteed that
> current_order >= pageblock_order / 2 if it even gets that far!
> 
> So just remove the unlikely(), it's completely bogus.
> 
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
