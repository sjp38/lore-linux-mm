Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0596B027F
	for <linux-mm@kvack.org>; Sun,  7 Jan 2018 18:02:11 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id b26so7494834qtb.18
        for <linux-mm@kvack.org>; Sun, 07 Jan 2018 15:02:11 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e64sor7468313qkb.113.2018.01.07.15.02.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Jan 2018 15:02:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAEwNFnC9FA44y1vCWmm=LEyQHjJC=Sd8GzbYgY6rS9h9i2HOiw@mail.gmail.com>
References: <1514082821-24256-1-git-send-email-nick.desaulniers@gmail.com> <CAEwNFnC9FA44y1vCWmm=LEyQHjJC=Sd8GzbYgY6rS9h9i2HOiw@mail.gmail.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Mon, 8 Jan 2018 01:02:09 +0200
Message-ID: <CAHp75VdjBnd=yr9YDPvf0P-e6ofoJwi8d-iOehoP=vuj9rnB8w@mail.gmail.com>
Subject: Re: [PATCH] zsmalloc: use U suffix for negative literals being shifted
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nick Desaulniers <nick.desaulniers@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Jan 7, 2018 at 5:04 PM, Minchan Kim <minchan@kernel.org> wrote:

>> -                       link->next = -1 << OBJ_TAG_BITS;
>> +                       link->next = -1U << OBJ_TAG_BITS;
>
> -1UL?

Oh, boy, shouldn't be rather GENMASK() / GENMASK_ULL() in a way how
it's done, for example, here:
https://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-pinctrl.git/commit/?h=for-next&id=d2b3c353595a855794f8b9df5b5bdbe8deb0c413

-- 
With Best Regards,
Andy Shevchenko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
