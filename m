Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 074758D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 07:21:22 -0500 (EST)
Received: by iwl42 with SMTP id 42so3855474iwl.14
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 04:21:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1298371877-2906-1-git-send-email-namhyung@gmail.com>
References: <1298371877-2906-1-git-send-email-namhyung@gmail.com>
Date: Tue, 22 Feb 2011 21:21:19 +0900
Message-ID: <AANLkTin2trwC1BUNq8=bOSq+GfB2Bye44GMK9OS3DFUz@mail.gmail.com>
Subject: Re: [PATCH] mempolicy: remove redundant check in __mpol_equal()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>

On Tue, Feb 22, 2011 at 7:51 PM, Namhyung Kim <namhyung@gmail.com> wrote:
> The 'flags' field is already checked, no need to do it again.
>
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> Cc: Bob Liu <lliubbo@gmail.com>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Bob's mempolicy: remove redundant check(1980050250) made it redundant.
Good eye!


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
