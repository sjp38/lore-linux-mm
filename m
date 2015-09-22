Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id AC5F66B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:48:57 -0400 (EDT)
Received: by igxx6 with SMTP id x6so14165396igx.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:48:57 -0700 (PDT)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id j3si3367474igx.31.2015.09.22.10.48.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 10:48:57 -0700 (PDT)
Received: by ioiz6 with SMTP id z6so21991234ioi.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:48:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1442903021-3893-3-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
	<1442903021-3893-3-git-send-email-mingo@kernel.org>
Date: Tue, 22 Sep 2015 10:48:56 -0700
Message-ID: <CA+55aFzN7MMoxzaq-mcNcNoVzUMr0aPHDTipU-OVdaz7_YZ12Q@mail.gmail.com>
Subject: Re: [PATCH 02/11] x86/mm/hotplug: Remove pgd_list use from the memory
 hotplug code
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Sep 21, 2015 at 11:23 PM, Ingo Molnar <mingo@kernel.org> wrote:
> +
> +               for_each_process(g) {
> +                       struct task_struct *p;
> +                       struct mm_struct *mm;
>                         pgd_t *pgd;
>                         spinlock_t *pgt_lock;
>
> +                       p = find_lock_task_mm(g);
> +                       if (!p)
> +                               continue;
> +
> +                       mm = p->mm;

So quite frankly, this is *much* better than the earlier version that
walked over all threads.

However, this now becomes a pattern for the series, and that just makes me think

    "Why is this not a 'for_each_mm()' pattern helper?"

if it only showed up once, that would be one thing. But this
patch-series makes it a thing. Which is why I wonder..

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
