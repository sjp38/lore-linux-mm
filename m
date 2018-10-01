Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3265B6B0269
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 11:57:22 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id g126-v6so8304422ywg.20
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 08:57:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 65-v6sor5856039ybz.96.2018.10.01.08.57.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Oct 2018 08:57:21 -0700 (PDT)
Received: from mail-yw1-f51.google.com (mail-yw1-f51.google.com. [209.85.161.51])
        by smtp.gmail.com with ESMTPSA id u22-v6sm9439953ywu.49.2018.10.01.08.57.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 08:57:19 -0700 (PDT)
Received: by mail-yw1-f51.google.com with SMTP id y76-v6so5700569ywd.2
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 08:57:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181001143138.95119-2-jannh@google.com>
References: <20181001143138.95119-1-jannh@google.com> <20181001143138.95119-2-jannh@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 1 Oct 2018 08:57:17 -0700
Message-ID: <CAGXu5j+tw5Z7ZYLJM_b+rHV7Ft8WR3psUdRr+qH5k+a-vCgNZw@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] mm/vmstat: skip NR_TLB_REMOTE_FLUSH* properly
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Roman Gushchin <guro@fb.com>, Kemi Wang <kemi.wang@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>

On Mon, Oct 1, 2018 at 7:31 AM, Jann Horn <jannh@google.com> wrote:
> commit 5dd0b16cdaff ("mm/vmstat: Make NR_TLB_REMOTE_FLUSH_RECEIVED
> available even on UP") made the availability of the NR_TLB_REMOTE_FLUSH*
> counters inside the kernel unconditional to reduce #ifdef soup, but
> (either to avoid showing dummy zero counters to userspace, or because that
> code was missed) didn't update the vmstat_array, meaning that all following
> counters would be shown with incorrect values.
>
> This only affects kernel builds with
> CONFIG_VM_EVENT_COUNTERS=y && CONFIG_DEBUG_TLBFLUSH=y && CONFIG_SMP=n.
>
> Fixes: 5dd0b16cdaff ("mm/vmstat: Make NR_TLB_REMOTE_FLUSH_RECEIVED available even on UP")
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jannh@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  mm/vmstat.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 4cea7b8f519d..7878da76abf2 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1275,6 +1275,9 @@ const char * const vmstat_text[] = {
>  #ifdef CONFIG_SMP
>         "nr_tlb_remote_flush",
>         "nr_tlb_remote_flush_received",
> +#else
> +       "", /* nr_tlb_remote_flush */
> +       "", /* nr_tlb_remote_flush_received */
>  #endif /* CONFIG_SMP */
>         "nr_tlb_local_flush_all",
>         "nr_tlb_local_flush_one",
> --
> 2.19.0.605.g01d371f741-goog
>



-- 
Kees Cook
Pixel Security
