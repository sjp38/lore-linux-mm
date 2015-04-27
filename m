Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 811BF6B006E
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 17:27:54 -0400 (EDT)
Received: by widdi4 with SMTP id di4so115791592wid.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 14:27:54 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id pa2si35188660wjb.137.2015.04.27.14.27.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 14:27:52 -0700 (PDT)
Received: by wizk4 with SMTP id k4so115991058wiz.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 14:27:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <553E00A5.370.3E3700BE@pageexec.freemail.hu>
References: <1429909549-11726-1-git-send-email-anisse@astier.eu>
 <87tww2ejit.fsf@tassilo.jf.intel.com> <CALUN=qL6X=RXyTmxezFDzif+3PZCykpB0mT9hkbgAab4vV59sg@mail.gmail.com>
 <553E00A5.370.3E3700BE@pageexec.freemail.hu>
From: Anisse Astier <anisse@astier.eu>
Date: Mon, 27 Apr 2015 23:27:31 +0200
Message-ID: <CALUN=qLNX-ybF3_WWYMLjF2iqduEk4f5P0rs_9oE8-0rrSePyg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/page_alloc.c: add config option to sanitize freed pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PaX Team <pageexec@freemail.hu>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Apr 27, 2015 at 11:25 AM, PaX Team <pageexec@freemail.hu> wrote:
>
> the PaX SANITIZE feature does exactly this in mm/page_alloc.c:prep_new_page:
>
> #ifndef CONFIG_PAX_MEMORY_SANITIZE
>         if (gfp_flags & __GFP_ZERO)
>                 prep_zero_page(page, order, gfp_flags);
> #endif
>

Thanks, I'll do that in the next iteration.

>> you'd need to clear memory on boot for example.
>
> it happens automagically because on boot during the transition from the
> boot allocator to the buddy one each page gets freed which will then go
> through the page clearing path.

Interesting, I'll see how it works.

>
> however there's a known problem/conflict with HIBERNATION (see
> http://marc.info/?l=linux-pm&m=132871433416256&w=2) which i think would
> have to be resolved before upstream acceptance.

I don't use hibernation, but I'll see if I can create a swap partition
to test that.

Regards,

Anisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
