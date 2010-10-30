Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DE3128D005B
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 19:28:23 -0400 (EDT)
Received: by iwn38 with SMTP id 38so4514749iwn.14
        for <linux-mm@kvack.org>; Sat, 30 Oct 2010 16:28:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1010302340260.1572@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1010302340260.1572@swampdragon.chaosbits.net>
Date: Sun, 31 Oct 2010 08:28:19 +0900
Message-ID: <AANLkTik0hfWygPnBSBPEj2nwgx_Cx0fYoU1h07=ZqM=P@mail.gmail.com>
Subject: Re: [PATCH] kmemleak: remove memset by using kzalloc
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>
List-ID: <linux-mm.kvack.org>

On Sun, Oct 31, 2010 at 6:43 AM, Jesper Juhl <jj@chaosbits.net> wrote:
> We don't need to memset if we just use kzalloc() rather than kmalloc() in
> kmemleak_test_init().
>
> (please CC on replies)
>
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
