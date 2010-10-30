Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9DB4A8D005B
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 19:34:02 -0400 (EDT)
Received: by iwn38 with SMTP id 38so4518543iwn.14
        for <linux-mm@kvack.org>; Sat, 30 Oct 2010 16:34:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net>
Date: Sun, 31 Oct 2010 08:34:01 +0900
Message-ID: <AANLkTi=nMU3ezNFD8LKBhJxr6CmW6-qHY_Mo3HRt6Os0@mail.gmail.com>
Subject: Re: [PATCH] cgroup: Avoid a memset by using vzalloc
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sun, Oct 31, 2010 at 6:35 AM, Jesper Juhl <jj@chaosbits.net> wrote:
> Hi,
>
> We can avoid doing a memset in swap_cgroup_swapon() by using vzalloc().
>
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

There are so many placed need vzalloc.
Thanks, Jesper.



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
