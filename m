Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 65D966B006C
	for <linux-mm@kvack.org>; Tue,  5 May 2015 08:42:33 -0400 (EDT)
Received: by wgiu9 with SMTP id u9so18196130wgi.3
        for <linux-mm@kvack.org>; Tue, 05 May 2015 05:42:33 -0700 (PDT)
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id s1si4101024wiy.107.2015.05.05.05.42.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 05:42:32 -0700 (PDT)
Received: by wgyo15 with SMTP id o15so181516791wgy.2
        for <linux-mm@kvack.org>; Tue, 05 May 2015 05:42:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5547E996.30078.8008582@pageexec.freemail.hu>
References: <1430774218-5311-1-git-send-email-anisse@astier.eu>
 <1430774218-5311-3-git-send-email-anisse@astier.eu> <5547E996.30078.8008582@pageexec.freemail.hu>
From: Anisse Astier <anisse@astier.eu>
Date: Tue, 5 May 2015 14:42:11 +0200
Message-ID: <CALUN=qJHsagU66CH0CakdmKae8eSnmb9jtqrHfNo_3f4ECSMMg@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] mm/page_alloc.c: add config option to sanitize
 freed pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PaX Team <pageexec@freemail.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, May 4, 2015 at 11:50 PM, PaX Team <pageexec@freemail.hu> wrote:
> On 4 May 2015 at 23:16, Anisse Astier wrote:
>
>> @@ -960,9 +966,15 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>>       kernel_map_pages(page, 1 << order, 1);
>>       kasan_alloc_pages(page, order);
>>
>> +#ifndef CONFIG_SANITIZE_FREED_PAGES
>> +     /* SANITIZE_FREED_PAGES relies implicitly on the fact that pages are
>> +      * cleared before use, so we don't need gfp zero in the default case
>> +      * because all pages go through the free_pages_prepare code path when
>> +      * switching from bootmem to the default allocator */
>>       if (gfp_flags & __GFP_ZERO)
>>               for (i = 0; i < (1 << order); i++)
>>                       clear_highpage(page + i);
>> +#endif
>
> this hunk should not be applied before the hibernation fix otherwise
> bisect will break.
>

It will be re-ordered in v3, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
