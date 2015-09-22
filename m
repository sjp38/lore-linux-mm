Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id B0D886B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:58:07 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so22229061ioi.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:58:07 -0700 (PDT)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id y1si3380202igl.74.2015.09.22.10.58.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 10:58:07 -0700 (PDT)
Received: by iofb144 with SMTP id b144so22388055iof.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:58:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1442903021-3893-7-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
	<1442903021-3893-7-git-send-email-mingo@kernel.org>
Date: Tue, 22 Sep 2015 10:58:06 -0700
Message-ID: <CA+55aFw5BLBTFWQpcOGYv4ALAM02aywTk1vz5ng=wqPnNH3qKw@mail.gmail.com>
Subject: Re: [PATCH 06/11] x86/virt/guest/xen: Remove use of pgd_list from the
 Xen guest code
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Sep 21, 2015 at 11:23 PM, Ingo Molnar <mingo@kernel.org> wrote:
> xen_mm_pin_all()/unpin_all() are used to implement full guest instance
> suspend/restore. It's a stop-all method that needs to iterate through
> all allocated pgds in the system to fix them up for Xen's use.

And _this_ is why I'd reall ylike that "for_each_mm()" helper.

Yeah, yeah, maybe it would require syntax like

    for_each_mm (tsk, mm) {
        ...
    } end_for_each_mm(mm);

to do variable allocation things or cleanups (ie "end_for_each_mm()"
might drop the task lock etc), but wouldn't that still be better than
this complex boilerplate thing?

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
