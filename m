Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9399E6B025E
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 22:28:39 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 74so8968150oty.15
        for <linux-mm@kvack.org>; Sat, 23 Dec 2017 19:28:39 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w134sor9005293oiw.167.2017.12.23.19.28.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 23 Dec 2017 19:28:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171224032437.GB5273@bombadil.infradead.org>
References: <1514082821-24256-1-git-send-email-nick.desaulniers@gmail.com> <20171224032437.GB5273@bombadil.infradead.org>
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Date: Sat, 23 Dec 2017 22:28:37 -0500
Message-ID: <CAH7mPvgqLf5x5QvdP1u1hpJCD+p2vy3aj=nt0RsHQH+aKTdovA@mail.gmail.com>
Subject: Re: [PATCH] zsmalloc: use U suffix for negative literals being shifted
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Dec 23, 2017 at 10:24 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Sat, Dec 23, 2017 at 09:33:40PM -0500, Nick Desaulniers wrote:
>> Fixes warnings about shifting unsigned literals being undefined
>> behavior.
>
> Do you mean signed literals?


A sorry, s/unsigned/negative signed/g.  The warning is:

mm/zsmalloc.c:1059:20: warning: shifting a negative signed value is undefined
      [-Wshift-negative-value]
                        link->next = -1 << OBJ_TAG_BITS;
                                     ~~ ^

>
>>                        */
>> -                     link->next = -1 << OBJ_TAG_BITS;
>> +                     link->next = -1U << OBJ_TAG_BITS;
>>               }
>
> I don't understand what -1U means.  Seems like a contradiction in terms,
> a negative unsigned number.  Is this supposed to be ~0U?

$ ag \\-1U[^L]

The code base is full of that literal.  I think of it as:

(unsigned) -1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
