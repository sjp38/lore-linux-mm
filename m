Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7236B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 20:03:29 -0400 (EDT)
Received: by qwa26 with SMTP id 26so889815qwa.14
        for <linux-mm@kvack.org>; Thu, 26 May 2011 17:03:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110526222218.GS19505@random.random>
References: <20110526222218.GS19505@random.random>
Date: Fri, 27 May 2011 09:03:28 +0900
Message-ID: <BANLkTinmo4pRRxY1aVPgus6F7JgQbAn5-w@mail.gmail.com>
Subject: Re: mm: remove khugepaged double thp vmstat update with CONFIG_NUMA=n
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>

On Fri, May 27, 2011 at 7:22 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Subject: mm: remove khugepaged double thp vmstat update with CONFIG_NUMA=n
>
> From: Andrea Arcangeli <aarcange@redhat.com>
>
> Johannes noticed the vmstat update is already taken care of by
> khugepaged_alloc_hugepage() internally. The only places that are
> required to update the vmstat are the callers of alloc_hugepage
> (callers of khugepaged_alloc_hugepage aren't).
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
