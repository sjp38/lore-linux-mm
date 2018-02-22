Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id E23D76B000C
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 20:28:19 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id h185so1943871vkg.20
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 17:28:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d46sor979816uah.231.2018.02.21.17.28.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 17:28:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1802151104140.2970@nuc-kabylake>
References: <20180214182618.14627-1-willy@infradead.org> <20180214182618.14627-3-willy@infradead.org>
 <alpine.DEB.2.20.1802141354530.28235@nuc-kabylake> <20180214201400.GD20627@bombadil.infradead.org>
 <alpine.DEB.2.20.1802150953080.1902@nuc-kabylake> <20180215162303.GC12360@bombadil.infradead.org>
 <alpine.DEB.2.20.1802151104140.2970@nuc-kabylake>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 21 Feb 2018 17:28:17 -0800
Message-ID: <CAGXu5jJaQUbwo0_a3KpzzV0Roc898bkO7xQ5VScbgTe-s59TQg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Thu, Feb 15, 2018 at 9:06 AM, Christopher Lameter <cl@linux.com> wrote:
> On Thu, 15 Feb 2018, Matthew Wilcox wrote:
>
>> I dunno.  Yes, there's macro trickery going on here, but it certainly
>> resembles a function.  It doesn't fail any of the rules laid out in that
>> chapter of coding-style about unacceptable uses of macros.
>
> It sure looks like a function but does magic things with the struct
> parameter. So its not working like a function and the capitalization makes
> one aware of that.

I think readability trumps that -- nearly everything else in the
kernel that hides these kinds of details is lower case.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
