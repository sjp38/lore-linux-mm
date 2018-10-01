Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACC566B000A
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 11:57:00 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id c2-v6so8763907ybl.16
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 08:57:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q125-v6sor5871213ybc.123.2018.10.01.08.56.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Oct 2018 08:56:59 -0700 (PDT)
Received: from mail-yw1-f41.google.com (mail-yw1-f41.google.com. [209.85.161.41])
        by smtp.gmail.com with ESMTPSA id v34-v6sm12819880ywh.45.2018.10.01.08.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 08:56:57 -0700 (PDT)
Received: by mail-yw1-f41.google.com with SMTP id j202-v6so1197616ywa.13
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 08:56:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181001143138.95119-1-jannh@google.com>
References: <20181001143138.95119-1-jannh@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 1 Oct 2018 08:56:56 -0700
Message-ID: <CAGXu5jKWxMeHgv=FRa_HjQZBDdiG_m2cjkyy-z6eCAUusVhWeg@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] mm/vmstat: fix outdated vmstat_text
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Roman Gushchin <guro@fb.com>, Kemi Wang <kemi.wang@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>

On Mon, Oct 1, 2018 at 7:31 AM, Jann Horn <jannh@google.com> wrote:
> commit 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
> removed the VMACACHE_FULL_FLUSHES statistics, but didn't remove the
> corresponding entry in vmstat_text. This causes an out-of-bounds access in
> vmstat_show().
>
> Luckily this only affects kernels with CONFIG_DEBUG_VM_VMACACHE=y, which is
> probably very rare.
>
> Fixes: 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jannh@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees


> ---
>  mm/vmstat.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 8ba0870ecddd..4cea7b8f519d 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1283,7 +1283,6 @@ const char * const vmstat_text[] = {
>  #ifdef CONFIG_DEBUG_VM_VMACACHE
>         "vmacache_find_calls",
>         "vmacache_find_hits",
> -       "vmacache_full_flushes",
>  #endif
>  #ifdef CONFIG_SWAP
>         "swap_ra",
> --
> 2.19.0.605.g01d371f741-goog
>



-- 
Kees Cook
Pixel Security
