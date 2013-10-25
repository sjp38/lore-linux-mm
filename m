Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B8D356B00C4
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 06:20:43 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so4908053pad.0
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 03:20:43 -0700 (PDT)
Received: from psmtp.com ([74.125.245.114])
        by mx.google.com with SMTP id rr7si3665490pbc.315.2013.10.25.03.20.41
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 03:20:41 -0700 (PDT)
Received: by mail-wi0-f181.google.com with SMTP id l12so847523wiv.14
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 03:20:39 -0700 (PDT)
Date: Fri, 25 Oct 2013 19:20:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RESEND 2/2] mm/zswap: refoctor the get/put routines
Message-ID: <20131025102032.GE6612@gmail.com>
References: <000101ced09e$fed90a10$fc8b1e30$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000101ced09e$fed90a10$fc8b1e30$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: akpm@linux-foundation.org, sjennings@variantweb.net, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu, Oct 24, 2013 at 05:53:32PM +0800, Weijie Yang wrote:
> The refcount routine was not fit the kernel get/put semantic exactly,
> There were too many judgement statements on refcount and it could be minus.
> 
> This patch does the following:
> 
> - move refcount judgement to zswap_entry_put() to hide resource free function.
> 
> - add a new function zswap_entry_find_get(), so that callers can use easily
> in the following pattern:
> 
>    zswap_entry_find_get
>    .../* do something */
>    zswap_entry_put
> 
> - to eliminate compile error, move some functions declaration
> 
> This patch is based on Minchan Kim <minchan@kernel.org> 's idea and suggestion.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> Cc: Seth Jennings <sjennings@variantweb.net>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Bob Liu <bob.liu@oracle.com>


I remember Bob had a idea to remove a look up and I think it's doable.
Anyway, I don't mind you send it with fix or not.

Thanks for handling this, Weijie!

Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
