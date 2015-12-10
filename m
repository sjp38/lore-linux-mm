Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id ABE1B6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 14:34:19 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id v187so49060034wmv.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 11:34:19 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id s204si312959wmf.51.2015.12.10.11.34.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Dec 2015 11:34:18 -0800 (PST)
Date: Thu, 10 Dec 2015 19:33:51 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v5] fs: clear file privilege bits when mmap writing
Message-ID: <20151210193351.GE20997@ZenIV.linux.org.uk>
References: <20151209225148.GA14794@www.outflux.net>
 <20151210070635.GC31922@1wt.eu>
 <CAGXu5jLZ8Ldv4vCjN6+QOa8v=GuUDU9t8sJsTNaQJGYtpdCayA@mail.gmail.com>
 <20151210181611.GB32083@1wt.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151210181611.GB32083@1wt.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 10, 2015 at 07:16:11PM +0100, Willy Tarreau wrote:

> > Is f_flags safe to write like this without holding a lock?
> 
> Unfortunately I have no idea. I've seen places where it's written without
> taking a lock such as in blkdev_open() and I don't think that this one is
> called with a lock held.

In any ->open() we obviously have nobody else able to find that struct file,
let alone modify it, so there the damn thing is essentially caller-private
and no locking is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
