Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id D01AF6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:55:15 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so104497299igb.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:55:15 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id t2si3577571ioe.182.2015.09.22.10.55.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 10:55:10 -0700 (PDT)
Received: by igbni9 with SMTP id ni9so14293123igb.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:55:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1442903021-3893-6-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
	<1442903021-3893-6-git-send-email-mingo@kernel.org>
Date: Tue, 22 Sep 2015 10:55:09 -0700
Message-ID: <CA+55aFzyZ6UKb_Ujm3E3eFwW_KUf8Vw3sV6tFpmAAGnificVvQ@mail.gmail.com>
Subject: Re: [PATCH 05/11] mm: Introduce arch_pgd_init_late()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Sep 21, 2015 at 11:23 PM, Ingo Molnar <mingo@kernel.org> wrote:
> Add a late PGD init callback to places that allocate a new MM
> with a new PGD: copy_process() and exec().
>
> The purpose of this callback is to allow architectures to implement
> lockless initialization of task PGDs, to remove the scalability
> limit of pgd_list/pgd_lock.

Do we really need this?

Can't we just initialize the pgd when we allocate it, knowing that
it's not in sync, but just depend on the vmalloc fault to add in any
kernel entries that we might have missed?

I liked the other patches in the series because they remove code and
simplify things. This patch I don't like.

There may be some reason we need it that I missed, and which makes me
go "Duh!" when you tell me. But please do tell me.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
