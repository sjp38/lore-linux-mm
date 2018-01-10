Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 56C236B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 00:53:46 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id r196so13505675itc.4
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 21:53:46 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n3sor10608022iti.75.2018.01.09.21.53.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 21:53:45 -0800 (PST)
Date: Wed, 10 Jan 2018 14:53:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: use U suffix for negative literals being
 shifted
Message-ID: <20180110055338.h3cs5hw7mzsdtcad@eng-minchan1.roam.corp.google.com>
References: <1514082821-24256-1-git-send-email-nick.desaulniers@gmail.com>
 <CAEwNFnC9FA44y1vCWmm=LEyQHjJC=Sd8GzbYgY6rS9h9i2HOiw@mail.gmail.com>
 <CAHp75VdjBnd=yr9YDPvf0P-e6ofoJwi8d-iOehoP=vuj9rnB8w@mail.gmail.com>
 <CAH7mPvj449dgjeLmWHHN9xTmM+4qXXrxM_2uQoBhcPPGgnhrSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH7mPvj449dgjeLmWHHN9xTmM+4qXXrxM_2uQoBhcPPGgnhrSw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Nick,

On Mon, Jan 08, 2018 at 08:35:19PM -0800, Nick Desaulniers wrote:
> On Sun, Jan 7, 2018 at 7:04 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Sorry for the delay. I have missed this until now. ;-(
> 
> No worries, figured patches would need a post holiday bump for review.
> 
> >
> > On Sun, Dec 24, 2017 at 11:33 AM, Nick Desaulniers
> > <nick.desaulniers@gmail.com> wrote:
> >> -                       link->next = -1 << OBJ_TAG_BITS;
> >> +                       link->next = -1U << OBJ_TAG_BITS;
> >
> > -1UL?
> 
> Oops, good catch.
> 
> > Please, resend it with including Andrew Morton
> > <akpm@linux-foundation.org> who merges zsmalloc patch into his tree.
> 
> Will do.
> 
> On Sun, Jan 7, 2018 at 3:02 PM, Andy Shevchenko
> <andy.shevchenko@gmail.com> wrote:
> > Oh, boy, shouldn't be rather GENMASK() / GENMASK_ULL() in a way how
> 
> Thanks for the suggestion. `GENMASK(BITS_PER_LONG - 1, OBJ_TAG_BITS);`
> is equivalent.  Whether that is more readable, I'll wait for Minchan
> to decide.  If that's preferred, I'll make sure to credit you with the
> Suggested-By tag in the commit message.

I don't see any benefit with GENMASK in our usecase.
If it's not a good justfication, I'd like to use just -1UL which
would be more readable without effort to understand new API.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
