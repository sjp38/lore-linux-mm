Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0B2A6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 23:35:21 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id x140so3723494oix.2
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 20:35:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k136sor4696556oih.261.2018.01.08.20.35.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 20:35:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHp75VdjBnd=yr9YDPvf0P-e6ofoJwi8d-iOehoP=vuj9rnB8w@mail.gmail.com>
References: <1514082821-24256-1-git-send-email-nick.desaulniers@gmail.com>
 <CAEwNFnC9FA44y1vCWmm=LEyQHjJC=Sd8GzbYgY6rS9h9i2HOiw@mail.gmail.com> <CAHp75VdjBnd=yr9YDPvf0P-e6ofoJwi8d-iOehoP=vuj9rnB8w@mail.gmail.com>
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Date: Mon, 8 Jan 2018 20:35:19 -0800
Message-ID: <CAH7mPvj449dgjeLmWHHN9xTmM+4qXXrxM_2uQoBhcPPGgnhrSw@mail.gmail.com>
Subject: Re: [PATCH] zsmalloc: use U suffix for negative literals being shifted
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>, Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Jan 7, 2018 at 7:04 AM, Minchan Kim <minchan@kernel.org> wrote:
> Sorry for the delay. I have missed this until now. ;-(

No worries, figured patches would need a post holiday bump for review.

>
> On Sun, Dec 24, 2017 at 11:33 AM, Nick Desaulniers
> <nick.desaulniers@gmail.com> wrote:
>> -                       link->next = -1 << OBJ_TAG_BITS;
>> +                       link->next = -1U << OBJ_TAG_BITS;
>
> -1UL?

Oops, good catch.

> Please, resend it with including Andrew Morton
> <akpm@linux-foundation.org> who merges zsmalloc patch into his tree.

Will do.

On Sun, Jan 7, 2018 at 3:02 PM, Andy Shevchenko
<andy.shevchenko@gmail.com> wrote:
> Oh, boy, shouldn't be rather GENMASK() / GENMASK_ULL() in a way how

Thanks for the suggestion. `GENMASK(BITS_PER_LONG - 1, OBJ_TAG_BITS);`
is equivalent.  Whether that is more readable, I'll wait for Minchan
to decide.  If that's preferred, I'll make sure to credit you with the
Suggested-By tag in the commit message.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
