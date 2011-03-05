Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3468D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 12:05:04 -0500 (EST)
Received: by gyb13 with SMTP id 13so1515882gyb.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 09:05:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299343345-3984-3-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
	<1299343345-3984-3-git-send-email-cesarb@cesarb.net>
Date: Sat, 5 Mar 2011 19:05:01 +0200
Message-ID: <AANLkTik-75TNoUZ-XLm4nmbq7zJSbUn+gECHYhQiN43C@mail.gmail.com>
Subject: Re: [PATCHv2 02/24] sys_swapon: remove changelog from function comment
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>

On Sat, Mar 5, 2011 at 6:42 PM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> Changelogs belong in the git history instead of in the source code.
>
> Also, "The swapon system call" is redundant with
> "SYSCALL_DEFINE2(swapon, ...)".
>
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> Tested-by: Eric B Munson <emunson@mgebm.net>
> Acked-by: Eric B Munson <emunson@mgebm.net>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
