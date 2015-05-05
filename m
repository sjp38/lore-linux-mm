Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A56AE6B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 08:43:51 -0400 (EDT)
Received: by wiun10 with SMTP id n10so144732054wiu.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 05:43:51 -0700 (PDT)
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id fu7si16689551wib.72.2015.05.05.05.43.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 05:43:49 -0700 (PDT)
Received: by wgso17 with SMTP id o17so181687413wgs.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 05:43:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5547E996.16766.8008534@pageexec.freemail.hu>
References: <1430774218-5311-1-git-send-email-anisse@astier.eu>
 <1430774218-5311-5-git-send-email-anisse@astier.eu> <5547E996.16766.8008534@pageexec.freemail.hu>
From: Anisse Astier <anisse@astier.eu>
Date: Tue, 5 May 2015 14:43:28 +0200
Message-ID: <CALUN=q+mR7QE9hSHv7sY3BGyO++OEx3r4sLw2nKVONjQ02shfA@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] mm: Add debug code for SANITIZE_FREED_PAGES
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PaX Team <pageexec@freemail.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, May 4, 2015 at 11:50 PM, PaX Team <pageexec@freemail.hu> wrote:
> On 4 May 2015 at 23:16, Anisse Astier wrote:
>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index c29e3a0..ba8aa25 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -975,6 +975,31 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>>               for (i = 0; i < (1 << order); i++)
>>                       clear_highpage(page + i);
>>  #endif
>> +#ifdef CONFIG_SANITIZE_FREED_PAGES_DEBUG
>> +     for (i = 0; i < (1 << order); i++) {
>> +             struct page *p = page + i;
>> +             int j;
>> +             bool err = false;
>> +             void *kaddr = kmap_atomic(p);
>> +
>> +             for (j = 0; j < PAGE_SIZE; j++) {
>
> did you mean to use memchr_inv(kaddr, 0, PAGE_SIZE) instead? ;)

Will be fixed in v3, although as I said I'm not sure if this debug
code should go in or not.

Thanks for you time.

Anisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
