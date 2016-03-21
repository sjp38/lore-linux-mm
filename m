Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 16F7B6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 13:02:25 -0400 (EDT)
Received: by mail-io0-f173.google.com with SMTP id m184so216519710iof.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 10:02:25 -0700 (PDT)
Received: from mail-ig0-x241.google.com (mail-ig0-x241.google.com. [2607:f8b0:4001:c05::241])
        by mx.google.com with ESMTPS id 7si7029986ioo.19.2016.03.21.10.02.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 10:02:24 -0700 (PDT)
Received: by mail-ig0-x241.google.com with SMTP id nt3so11154363igb.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 10:02:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1458561998-126622-2-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1458561998-126622-2-git-send-email-kirill.shutemov@linux.intel.com>
Date: Mon, 21 Mar 2016 10:02:23 -0700
Message-ID: <CA+55aFx=E66fSEFu5brOsyCgYWXhyNzGjHmN-JZFmXdeVywpqg@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm, fs: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon, Mar 21, 2016 at 5:06 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> This patch contains automated changes generated with coccinelle using
> script below. For some reason, coccinelle doesn't patch header files.
> I've called spatch for them manually.

Looks good.

Mind reminding me and re-sending the patches about this after the
merge window is over? Maybe around rc2 or so?

I definitely don't want to apply this while I'm still in the merge
window, but considering that it's almost entirely automated and should
be very safe - and to avoid conflicts during the _next_ merge window -
I'd actually prefer to merge  this early rather than late.

     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
