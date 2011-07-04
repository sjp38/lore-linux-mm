Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 981F79000C2
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 20:43:12 -0400 (EDT)
Received: by qwa26 with SMTP id 26so3242810qwa.14
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 17:43:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1309721963-5577-1-git-send-email-dmitry.fink@palm.com>
References: <1309721963-5577-1-git-send-email-dmitry.fink@palm.com>
Date: Mon, 4 Jul 2011 09:43:09 +0900
Message-ID: <CAEwNFnAYAWy4tabCuzGUwXjLpZVbxhKMmPXnhmCuH5pckOXBRw@mail.gmail.com>
Subject: Re: [PATCH 1/1] mmap: Don't count shmem pages as free in __vm_enough_memory
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Fink <finikk@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Fink <dmitry.fink@palm.com>

On Mon, Jul 4, 2011 at 4:39 AM, Dmitry Fink <finikk@gmail.com> wrote:
> shmem pages can't be reclaimed and if they are swapped out
> that doesn't affect the overall available memory in the system,
> so don't count them along with the rest of the file backed pages.
>
> Signed-off-by: Dmitry Fink <dmitry.fink@palm.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I am not sure the description is good. :(
But I think this patch is reasonable.

In swapless system,guessing overcommit can have a problem.
And in current implementation of OVERCOMMIT_GUESS, we consider anon
pages as empty space of swap so shmem pages should be accounted by
that.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
