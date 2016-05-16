Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBBE6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 12:20:43 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id v81so406477149ywa.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 09:20:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b81si9230348qkc.242.2016.05.16.09.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 09:20:42 -0700 (PDT)
Date: Mon, 16 May 2016 18:20:39 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/1] userfaultfd: don't pin the user memory in
 userfaultfd_file_create()
Message-ID: <20160516162039.GA19459@redhat.com>
References: <20160516152522.GA19120@redhat.com>
 <20160516152546.GA19129@redhat.com>
 <20160516155729.GH550@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160516155729.GH550@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/16, Andrea Arcangeli wrote:
>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks,

> > +static inline bool userfaultfd_get_mm(struct userfaultfd_ctx *ctx)
> > +{
> > +	return atomic_inc_not_zero(&ctx->mm->mm_users);
> > +}
>
> Nice cleanup, but wouldn't it be more generic to implement this as
> mmget(&ctx->mm) (or maybe mmget_not_zero) in include/linux/mm.h
> instead of userfaultfd.c, so then others can use it too, see:

Yes, agreed. userfaultfd_get_mm() doesn't look as good as I initially thought.

So I guess it would be better to make V2 right now, to avoid another change in
userfaultfd.c which changes the same code.

Except I think mmget_not_zero() should go to linux/sched.h, until we move
mmdrop/mmput/etc to linux/mm.h.

I'll send V2 soon...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
