Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 284E96B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 17:35:51 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so22591547pdj.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 14:35:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bx3si10480404pbb.197.2015.06.09.14.35.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 14:35:50 -0700 (PDT)
Date: Tue, 9 Jun 2015 14:35:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: show proportional swap share of the mapping
Message-Id: <20150609143548.870150b59d78752680c172db@linux-foundation.org>
In-Reply-To: <1433861031-13233-1-git-send-email-minchan@kernel.org>
References: <1433861031-13233-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bongkyu Kim <bongkyu.kim@lge.com>

On Tue,  9 Jun 2015 23:43:51 +0900 Minchan Kim <minchan@kernel.org> wrote:

> For system uses swap heavily and has lots of shared anonymous page,
> it's very trouble to find swap set size per process because currently
> smaps doesn't report proportional set size of swap.
> It ends up that sum of the number of swap for all processes is greater
> than swap device size.
> 
> This patch introduces SwapPss field on /proc/<pid>/smaps.
> 

We should be told quite a bit more about the value of this change,
please.  Use cases, what problems it solves, etc.  Enough to justify
adding new code to the kernel, enough to justify adding yet another
userspace interface which must be maintained for ever.

> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
>
> ...
>
> @@ -441,7 +442,7 @@ indicates the amount of memory currently marked as referenced or accessed.
>  a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
>  and a page is modified, the file page is replaced by a private anonymous copy.
>  "Swap" shows how much would-be-anonymous memory is also used, but out on
> -swap.
> +swap. "SwapPss" shows process' proportional swap share of this mapping.
>  
>  "VmFlags" field deserves a separate description. This member represents the kernel
>  flags associated with the particular virtual memory area in two letter encoded

Documentation/filesystems/proc.txt doesn't actually explain what
"proportional share" means.  A patient reader will hopefully find the
comment over PSS_SHIFT in fs/proc/task_mmu.c, but that isn't very
user-friendly.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
