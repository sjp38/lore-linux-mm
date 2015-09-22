Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD636B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:41:22 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so21791882ioi.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:41:21 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id rj8si13761823igc.53.2015.09.22.10.41.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 10:41:21 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so104250857igb.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:41:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1442903021-3893-2-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
	<1442903021-3893-2-git-send-email-mingo@kernel.org>
Date: Tue, 22 Sep 2015 10:41:21 -0700
Message-ID: <CA+55aFz2YH6F1L7JULQZOUMqyqeR+2LL2GWeg+QV1T8aRkJw1w@mail.gmail.com>
Subject: Re: [PATCH 01/11] x86/mm/pat: Don't free PGD entries on memory unmap
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Sep 21, 2015 at 11:23 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> This complicates PGD management, so don't do this. We can keep the
> PGD mapped and the PUD table all clear - it's only a single 4K page
> per 512 GB of memory mapped.

I'm ok with this just from a "it removes code" standpoint.  That said,
some of the other patches here make me go "hmm". I'll answer them
separately.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
