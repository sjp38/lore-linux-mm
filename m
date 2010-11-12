Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 13B626B00B1
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 01:05:05 -0500 (EST)
Received: by iwn9 with SMTP id 9so3196167iwn.14
        for <linux-mm@kvack.org>; Thu, 11 Nov 2010 22:05:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101111075455.GA10210@amd>
References: <20101111075455.GA10210@amd>
Date: Fri, 12 Nov 2010 14:58:52 +0900
Message-ID: <AANLkTik90AS83YyrTtvBeJgUx3ZiQM6AAKqH9y+z4Ewk@mail.gmail.com>
Subject: Re: [patch] mm: find_get_pages_contig fixlet
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2010 at 4:54 PM, Nick Piggin <npiggin@kernel.dk> wrote:
> Testing ->mapping and ->index without a ref is not stable as the page
> may have been reused at this point.
>
> Signed-off-by: Nick Piggin <npiggin@kernel.dk>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nice catch.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
