Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2DAA26B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:48:55 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id ib6so389926vcb.41
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 19:48:54 -0700 (PDT)
Received: from mail-ve0-x22a.google.com (mail-ve0-x22a.google.com [2607:f8b0:400c:c01::22a])
        by mx.google.com with ESMTPS id at8si7198876vec.199.2014.04.22.19.48.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 19:48:54 -0700 (PDT)
Received: by mail-ve0-f170.google.com with SMTP id pa12so412878veb.29
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 19:48:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5356FCC1.6060807@zytor.com>
References: <5356FCC1.6060807@zytor.com>
Date: Tue, 22 Apr 2014 19:48:54 -0700
Message-ID: <CA+55aFwsPs12_57YEBHdb4ti1BXSuDX_RPSf6S4JSRLGK_2X7Q@mail.gmail.com>
Subject: Re: Why do we set _PAGE_DIRTY for page tables?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Apr 22, 2014 at 4:35 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> I just noticed this:
>
> #define _PAGE_TABLE     (_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |       \
>                          _PAGE_ACCESSED | _PAGE_DIRTY)
> #define _KERNPG_TABLE   (_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |   \
>                          _PAGE_DIRTY)
>
> Is there a reason we set _PAGE_DIRTY for page tables?  It has no
> function, but doesn't do any harm either (the dirty bit is ignored for
> page tables)... it just looks funny to me.

I think it just got copied, and at least the A bit does matter even in
page tables (well, it gets updated, I don't know how much that
"matters"). So the fact that D is ignored is actually the odd man out.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
