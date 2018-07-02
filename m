Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4422D6B028D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 17:56:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v13-v6so89672wmc.1
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 14:56:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e204-v6sor1318550wma.48.2018.07.02.14.56.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 14:56:23 -0700 (PDT)
MIME-Version: 1.0
References: <20180627191250.209150-2-shakeelb@google.com> <20180702215439.211597-1-shakeelb@google.com>
In-Reply-To: <20180702215439.211597-1-shakeelb@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 2 Jul 2018 14:56:10 -0700
Message-ID: <CALvZod6uGK+hYxwnVWbwj6LDxq4Aqd-D2jwp=QyKNTaJH0e4vw@mail.gmail.com>
Subject: Re: [PATCH] fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch.cleanup
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Mon, Jul 2, 2018 at 2:54 PM Shakeel Butt <shakeelb@google.com> wrote:
>
> Hi Andres, this is a small cleanup to the patch "fs: fsnotify: account

*Andrew*

> fsnotify metadata to kmemcg". Please squash.
>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  fs/notify/fanotify/fanotify.c        | 2 +-
>  fs/notify/inotify/inotify_fsnotify.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
> index 6ff1f75d156d..eb4e75175cfb 100644
> --- a/fs/notify/fanotify/fanotify.c
> +++ b/fs/notify/fanotify/fanotify.c
> @@ -142,7 +142,7 @@ struct fanotify_event_info *fanotify_alloc_event(struct fsnotify_group *group,
>                                                  const struct path *path)
>  {
>         struct fanotify_event_info *event = NULL;
> -       gfp_t gfp = GFP_KERNEL | __GFP_ACCOUNT;
> +       gfp_t gfp = GFP_KERNEL_ACCOUNT;
>
>         /*
>          * For queues with unlimited length lost events are not expected and
> diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
> index 52e167d04b11..f4184b4f3815 100644
> --- a/fs/notify/inotify/inotify_fsnotify.c
> +++ b/fs/notify/inotify/inotify_fsnotify.c
> @@ -101,7 +101,7 @@ int inotify_handle_event(struct fsnotify_group *group,
>
>         /* Whoever is interested in the event, pays for the allocation. */
>         memalloc_use_memcg(group->memcg);
> -       event = kmalloc(alloc_len, GFP_KERNEL | __GFP_ACCOUNT);
> +       event = kmalloc(alloc_len, GFP_KERNEL_ACCOUNT);
>         memalloc_unuse_memcg();
>
>         if (unlikely(!event)) {
> --
> 2.18.0.399.gad0ab374a1-goog
>
