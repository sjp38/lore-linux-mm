Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id ECE2F6B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 07:30:16 -0400 (EDT)
Received: by wibdy8 with SMTP id dy8so34939385wib.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 04:30:16 -0700 (PDT)
Received: from mail-we0-x22c.google.com (mail-we0-x22c.google.com. [2a00:1450:400c:c03::22c])
        by mx.google.com with ESMTPS id lx7si17322656wjb.33.2015.03.16.04.30.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 04:30:15 -0700 (PDT)
Received: by weop45 with SMTP id p45so10486116weo.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 04:30:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1426372766-3029-5-git-send-email-dave@stgolabs.net>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
	<1426372766-3029-5-git-send-email-dave@stgolabs.net>
Date: Mon, 16 Mar 2015 14:30:14 +0300
Message-ID: <CALYGNiMt7j8+mpxBPzLkYPd+dA77B17r9FfSwkGjj3+48EgbGA@mail.gmail.com>
Subject: Re: [PATCH 4/4] kernel/fork: use pr_alert() for rss counter bugs
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Cyrill Gorcunov <gorcunov@openvz.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Davidlohr Bueso <dbueso@suse.de>

On Sun, Mar 15, 2015 at 1:39 AM, Davidlohr Bueso <dave@stgolabs.net> wrote:
> ... everyone else does.
>
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Oleg Nesterov <oleg@redhat.com>
> CC: Konstantin Khlebnikov <koct9i@gmail.com>
> ---
>  kernel/fork.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 54b0b91..fc5d4f3 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -602,8 +602,8 @@ static void check_mm(struct mm_struct *mm)
>                 long x = atomic_long_read(&mm->rss_stat.count[i]);
>
>                 if (unlikely(x))
> -                       printk(KERN_ALERT "BUG: Bad rss-counter state "
> -                                         "mm:%p idx:%d val:%ld\n", mm, i, x);
> +                       pr_alert("BUG: Bad rss-counter state "
> +                                "mm:%p idx:%d val:%ld\n", mm, i, x);
>         }

Ack.

>
>         if (atomic_long_read(&mm->nr_ptes))
> --
> 2.1.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
