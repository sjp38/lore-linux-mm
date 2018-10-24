Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D846D6B000D
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 01:17:54 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j1-v6so1922810pll.8
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 22:17:54 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id g3-v6si3635384pgr.325.2018.10.23.22.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 22:17:53 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 24 Oct 2018 10:47:52 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH] mm: convert totalram_pages, totalhigh_pages and
 managed_pages to atomic.
In-Reply-To: <CAGXu5j+NsDHRWA5PKAKeJCO_oiGkFAUeWE8O-1fEBQX80MDu1A@mail.gmail.com>
References: <1540229092-25207-1-git-send-email-arunks@codeaurora.org>
 <c57bcc584b3700c483b0311881ec3ae8786f88b1.camel@perches.com>
 <15247f54-53f3-83d4-6706-e9264b90ca7a@yandex-team.ru>
 <CAGXu5j+NsDHRWA5PKAKeJCO_oiGkFAUeWE8O-1fEBQX80MDu1A@mail.gmail.com>
Message-ID: <7a4fcbaee7efb71d2a3c6b403c090db4@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Joe Perches <joe@perches.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Arun Sudhilal <getarunks@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>

On 2018-10-24 01:34, Kees Cook wrote:
> On Mon, Oct 22, 2018 at 10:11 PM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>> On 23.10.2018 7:15, Joe Perches wrote:> On Mon, 2018-10-22 at 22:53 
>> +0530,
>> Arun KS wrote:
>>>> Remove managed_page_count_lock spinlock and instead use atomic
>>>> variables.
>>> 
>>> Perhaps better to define and use macros for the accesses
>>> instead of specific uses of atomic_long_<inc/dec/read>
>>> 
>>> Something like:
>>> 
>>> #define totalram_pages()      (unsigned
>>> long)atomic_long_read(&_totalram_pages)
>> 
>> or proper static inline
>> this code isn't so low level for breaking include dependencies with 
>> macro
> 
> BTW, I noticed a few places in the patch that did multiple evaluations
> of totalram_pages. It might be worth fixing those prior to doing the
> conversion, too. e.g.:
> 
> if (totalram_pages > something)
>    foobar(totalram_pages); <- value may have changed here
> 
> should, instead, be:
> 
> var = totalram_pages; <- get stable view of the value
> if (var > something)
>     foobar(var);

Thanks for reviewing. Point taken.
> 
> -Kees
> 
>> [dropped bloated cc - my server rejects this mess]
> 
> Thank you -- I was struggling to figure out the best way to reply to 
> this. :)
I'm sorry for the trouble caused. Sent the email using,
git send-email  --to-cmd="scripts/get_maintainer.pl -i" 
0001-convert-totalram_pages-totalhigh_pages-and-managed_p.patch

Is this not a recommended approach?

Regards,
Arun

> 
> -Kees
