Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 202B66B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:59:36 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so104554708igc.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:59:36 -0700 (PDT)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id h10si1740828igq.38.2015.09.22.10.59.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 10:59:35 -0700 (PDT)
Received: by ioiz6 with SMTP id z6so22267418ioi.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:59:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1442903021-3893-8-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
	<1442903021-3893-8-git-send-email-mingo@kernel.org>
Date: Tue, 22 Sep 2015 10:59:35 -0700
Message-ID: <CA+55aFyQukAgZ7wsOW85GZpMYHt0Ssw99Rx7sQkabMSHJUGqjQ@mail.gmail.com>
Subject: Re: [PATCH 07/11] x86/mm: Remove pgd_list use from vmalloc_sync_all()
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
> +
> +                       p = find_lock_task_mm(g);
> +                       if (!p)
> +                               continue;
...
> +                       task_unlock(p);

You know the drill by now..

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
