Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 870B36B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 01:17:14 -0400 (EDT)
Received: by ywh28 with SMTP id 28so1204573ywh.15
        for <linux-mm@kvack.org>; Thu, 10 Sep 2009 22:17:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1252633966-20541-1-git-send-email-shijie8@gmail.com>
References: <1252633966-20541-1-git-send-email-shijie8@gmail.com>
Date: Fri, 11 Sep 2009 14:16:59 +0900
Message-ID: <28c262360909102216x3568142fk47a656a902416557@mail.gmail.com>
Subject: Re: [PATCH] mmap : save some cycles for the shared anonymous mapping
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 11, 2009 at 10:52 AM, Huang Shijie <shijie8@gmail.com> wrote:
> The shmem_zere_setup() does not change vm_start, pgoff or vm_flags,
> only some drivers change them (such as /driver/video/bfin-t350mcqb-fb.c).
>
> Moving these codes to a more proper place to save cycles for shared anonymous mapping.
>
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
Reviewed-by: Minchan Kim<minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
