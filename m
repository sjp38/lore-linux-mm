Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19F45C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:33:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9B602083E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:33:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hvqm/Ik4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9B602083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D8976B028F; Wed, 10 Apr 2019 07:33:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5618C6B0290; Wed, 10 Apr 2019 07:33:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 428196B0291; Wed, 10 Apr 2019 07:33:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22E6C6B028F
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:33:42 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id o197so1969798ito.3
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:33:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TjsaQPbNShbvkpeAw80k99dKqAmZ5aA0r05zKVOr+cY=;
        b=KsoGP3qi4fIhowJI2uEglAh5uy9fggFKwjCVMhj/Uo9beeW3hgXXzr3tnGhg/7jWQ2
         pdBmIVjzDTXa6ngRa+OyI7gjZDPZY+csAt/XOfhoJAAJ3w+DOW3S0sGA3v1Tv2Je4lfN
         j6npFlJZsw6BYA/WwtSTkpRN/1IKynxy54ChbRhpLBlAI+ztZdU0/I+K4LXzrkOJlRL/
         87kO/pEEr1aix6i0wMAB+Wnn0eKMsnLrGuNIdVnLayW9H7UCd4kR9JY4l7Tn37FwGynU
         n2L35AkAqxhBSHH0rvQ5dlAgRZdcJdzLj9ff/VWPFX2u7i7wdGboiWBxqf9nY4xjMVmT
         AYYQ==
X-Gm-Message-State: APjAAAXSsm2G044jkM4YaPdHBog1d9bL+FZuAEWNj0lsxoTYmYxhwjta
	+gy+BuSRHw3Mo3olhYOORld+Js3uLYzONF5f6fJVYSMt9tCOpq1m91nLAnNIa/gQOBmO7mPxjw4
	KHDjf5zkAz6UdLOoYpjicDDzNEidIERJ9olxCalfLLXGxtDpaGJIt+iYR9PnfOjmwug==
X-Received: by 2002:a02:234b:: with SMTP id u72mr18331108jau.4.1554896021876;
        Wed, 10 Apr 2019 04:33:41 -0700 (PDT)
X-Received: by 2002:a02:234b:: with SMTP id u72mr18331060jau.4.1554896021204;
        Wed, 10 Apr 2019 04:33:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554896021; cv=none;
        d=google.com; s=arc-20160816;
        b=vGPUfd+mKxz9MW8ih+Jp3QQyLIsf85LrEGlVVzqEqfz2f8FDHXFwYyY/rycgxnO3CR
         MgS/+6WRJ0H2Cxiab+5ax+myiWNSQucYEs/Bc+iePgpOtJKco55IZZ55IJLL+JpdILjD
         pnYtRl1okBHAdjmqwtGbK3BP6bcUT1+orf0tWiew2TBoySwtm4SjTFFdVQH3hZ0HDDqD
         88yvgyKB0YDMClYFbuMERAWxdyHIBg9hcuwmYqVci/MiOvQtFz8B3GqlO9yhK69HlWQj
         myUYoqkc6iV3n87GssVrkgDWU1YpFN3nMC6NaFzeOJOo/PWxdkjpuIXCYpYz1aHT2R5b
         7Kpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TjsaQPbNShbvkpeAw80k99dKqAmZ5aA0r05zKVOr+cY=;
        b=aF56iPTChNuOT+dq/Awsxh+tVqGcx57yYUqOHs8g6YMaEeKojjKZukt0XPRIEm34ju
         5dF4/xQPCB0kwqwbZOoxLQwAgGigfKzwQxDxs35WOxqz7dA40JPb8dvN+F9lkyh5uEiV
         D4y+MJ5C5ScBcA8QQM3OmHb1HEj6p68jr8OE46uD6ly/2jz0ShsRkgm5D9+6IWAeaa/H
         P7xoLKjGpxe8zGrvV4/Jl3ZPonzyRw5uGpSfBPAqnAoMvWzLzyVmb9Em757SqmOGrNcP
         ZwpA6u89u5vSt8zkYdnrWPLor3OUXmyNCnxByByZY9V1htETYqZ7UHAsS3X0R9meMrgn
         7j5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="hvqm/Ik4";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y72sor2807701itb.11.2019.04.10.04.33.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 04:33:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="hvqm/Ik4";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TjsaQPbNShbvkpeAw80k99dKqAmZ5aA0r05zKVOr+cY=;
        b=hvqm/Ik4KxAHtz43m6VcZ5ZJb2oTQcRYl5Wa6EFlDWWtQIi0309hOCfGWPlvYW5CVu
         GZHhxum7cn1LWR0Gn5hQAkUnGo2RnPYUnA+BEEdXJzWjNEILyLzzmsNitTrupttoKTLu
         Su3SEScp55+gHgArWw1x0UIoInY4PebKVgMZmKE3KkUWVMXpHYWWbPioc6d2Yd309vPj
         3qgKEWXpxQRMisGZUqn86Cy97q2MH6J9E9cF4I+qLRPFRyT6sIfIrdr1cvB+yu1RxVNE
         fkcGJVfCp3wZrD5fqsP5thPPZQFAHbawJwusIqzSk5/QKRHof2aMYBr+BjAqbIrPIHvc
         xOoQ==
X-Google-Smtp-Source: APXvYqzT8uWFTmOVFg+lawKasWyQAVi5QIe9VZzcU7UqZE3f+PI2gxUaNo6UcjcJ8i56WEL9XlBPLD7tIGbalaBanow=
X-Received: by 2002:a24:2f49:: with SMTP id j70mr2774640itj.122.1554896020630;
 Wed, 10 Apr 2019 04:33:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190410102754.387743324@linutronix.de> <20190410103645.862294081@linutronix.de>
In-Reply-To: <20190410103645.862294081@linutronix.de>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 10 Apr 2019 13:33:29 +0200
Message-ID: <CACT4Y+YBvhbBLfrCvJ0t21ZQ_Pd-ZTR9UnzOYGUyyvdJD+0M2A@mail.gmail.com>
Subject: Re: [RFC patch 25/41] mm/kasan: Simplify stacktrace handling
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, 
	Alexander Potapenko <glider@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 1:06 PM Thomas Gleixner <tglx@linutronix.de> wrote:
>
> Replace the indirection through struct stack_trace by using the storage
> array based interfaces.
>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org
> ---
>  mm/kasan/common.c |   30 ++++++++++++------------------
>  mm/kasan/report.c |    7 ++++---
>  2 files changed, 16 insertions(+), 21 deletions(-)
>
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -48,34 +48,28 @@ static inline int in_irqentry_text(unsig
>                  ptr < (unsigned long)&__softirqentry_text_end);
>  }
>
> -static inline void filter_irq_stacks(struct stack_trace *trace)
> +static inline unsigned int filter_irq_stacks(unsigned long *entries,
> +                                            unsigned int nr_entries)
>  {
> -       int i;
> +       unsigned int i;
>
> -       if (!trace->nr_entries)
> -               return;
> -       for (i = 0; i < trace->nr_entries; i++)
> -               if (in_irqentry_text(trace->entries[i])) {
> +       for (i = 0; i < nr_entries; i++) {
> +               if (in_irqentry_text(entries[i])) {
>                         /* Include the irqentry function into the stack. */
> -                       trace->nr_entries = i + 1;
> -                       break;
> +                       return i + 1;
>                 }
> +       }
> +       return nr_entries;
>  }
>
>  static inline depot_stack_handle_t save_stack(gfp_t flags)
>  {
>         unsigned long entries[KASAN_STACK_DEPTH];
> -       struct stack_trace trace = {
> -               .nr_entries = 0,
> -               .entries = entries,
> -               .max_entries = KASAN_STACK_DEPTH,
> -               .skip = 0
> -       };
> +       unsigned int nent;
>
> -       save_stack_trace(&trace);
> -       filter_irq_stacks(&trace);
> -
> -       return depot_save_stack(&trace, flags);
> +       nent = stack_trace_save(entries, ARRAY_SIZE(entries), 0);
> +       nent = filter_irq_stacks(entries, nent);
> +       return stack_depot_save(entries, nent, flags);
>  }
>
>  static inline void set_track(struct kasan_track *track, gfp_t flags)
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -100,10 +100,11 @@ static void print_track(struct kasan_tra
>  {
>         pr_err("%s by task %u:\n", prefix, track->pid);
>         if (track->stack) {
> -               struct stack_trace trace;
> +               unsigned long *entries;
> +               unsigned int nent;
>
> -               depot_fetch_stack(track->stack, &trace);
> -               print_stack_trace(&trace, 0);
> +               nent = stack_depot_fetch(track->stack, &entries);
> +               stack_trace_print(entries, nent, 0);
>         } else {
>                 pr_err("(stack is not available)\n");
>         }


Acked-by: Dmitry Vyukov <dvyukov@google.com>

