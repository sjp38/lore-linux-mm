Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93D426B025F
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 16:54:58 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id x25so6472961uax.16
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 13:54:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x64sor5542736vkc.219.2017.12.19.13.54.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 13:54:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com>
References: <001a113e9ca8a3affd05609d7ccf@google.com> <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros> <20171219132246.GD13680@bombadil.infradead.org> <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 19 Dec 2017 13:54:56 -0800
Message-ID: <CAGXu5jLZGW8sodoNw6h+BWxnAGjpW0HTMEjx=Ee9AZ6PgVwX4A@mail.gmail.com>
Subject: Re: BUG: bad usercopy in memdup_user
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, "Tobin C. Harding" <me@tobin.cc>, Dmitry Vyukov <dvyukov@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On Tue, Dec 19, 2017 at 1:36 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> In this case, there's obviously no permission issue: it's an error
> report. So it's either "remove it, or switch to %px".

Yup, my intention was to kill this %p and enhance the report to
actually include the useful information like, "what is the offset from
the start of the object", etc. That's what really matters.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
