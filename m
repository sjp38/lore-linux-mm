Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id A0C9A6B026B
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 11:57:39 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id m1-v6so8171316ywd.17
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 08:57:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y186-v6sor104106ywc.360.2018.10.01.08.57.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Oct 2018 08:57:39 -0700 (PDT)
Received: from mail-yw1-f47.google.com (mail-yw1-f47.google.com. [209.85.161.47])
        by smtp.gmail.com with ESMTPSA id z130-v6sm2723965ywd.91.2018.10.01.08.57.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 08:57:36 -0700 (PDT)
Received: by mail-yw1-f47.google.com with SMTP id m129-v6so5708491ywc.1
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 08:57:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181001143138.95119-3-jannh@google.com>
References: <20181001143138.95119-1-jannh@google.com> <20181001143138.95119-3-jannh@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 1 Oct 2018 08:57:34 -0700
Message-ID: <CAGXu5jK7Wv4R9Vm4oPnfLQQCd+WgmH0CLPTHBSvxkC4gHOrTHQ@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] mm/vmstat: assert that vmstat_text is in sync with stat_items_size
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Roman Gushchin <guro@fb.com>, Kemi Wang <kemi.wang@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>

On Mon, Oct 1, 2018 at 7:31 AM, Jann Horn <jannh@google.com> wrote:
> As evidenced by the previous two patches, having two gigantic arrays that
> must manually be kept in sync, including ifdefs, isn't exactly robust.
> To make it easier to catch such issues in the future, add a BUILD_BUG_ON().
>
> Signed-off-by: Jann Horn <jannh@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  mm/vmstat.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 7878da76abf2..b678c607e490 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1663,6 +1663,8 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
>         stat_items_size += sizeof(struct vm_event_state);
>  #endif
>
> +       BUILD_BUG_ON(stat_items_size !=
> +                    ARRAY_SIZE(vmstat_text) * sizeof(unsigned long));
>         v = kmalloc(stat_items_size, GFP_KERNEL);
>         m->private = v;
>         if (!v)
> --
> 2.19.0.605.g01d371f741-goog
>



-- 
Kees Cook
Pixel Security
