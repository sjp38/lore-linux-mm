Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id BA5C56B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 03:59:45 -0400 (EDT)
Received: by wiun10 with SMTP id n10so86318628wiu.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 00:59:45 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id el3si10890413wib.24.2015.05.11.00.59.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 00:59:44 -0700 (PDT)
Received: by widdi4 with SMTP id di4so94794279wid.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 00:59:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150509154455.GA32002@amd>
References: <1430980452-2767-1-git-send-email-anisse@astier.eu>
 <1430980452-2767-3-git-send-email-anisse@astier.eu> <20150509154455.GA32002@amd>
From: Anisse Astier <anisse@astier.eu>
Date: Mon, 11 May 2015 09:59:23 +0200
Message-ID: <CALUN=q+OZFarqRoWMynRZy0ckv7qnsAQvWr9wkvdK_JmA=oomw@mail.gmail.com>
Subject: Re: [PATCH v3 2/4] PM / Hibernate: prepare for SANITIZE_FREED_PAGES
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Pavel,

Thanks a lot for taking the time to review this.

On Sat, May 9, 2015 at 5:44 PM, Pavel Machek <pavel@ucw.cz> wrote:
>> +#ifdef CONFIG_SANITIZE_FREED_PAGES
>> +             clear_free_pages();
>> +             printk(KERN_INFO "PM: free pages cleared after restore\n");
>> +#endif
>> +     }
>>       platform_leave(platform_mode);
>>
>>   Power_up:
>
> Can you move the ifdef and the printk into the clear_free_pages?

Sure. I put the printk out originally because i thought there might be
other uses, but since this is the sole call site right now it
shouldn't be an issue.

>
> This is not performance critical in any way...
>
> Otherwise it looks good to me... if the sanitization is considered
> useful. Did it catch some bugs in the past?
>

I've read somewhere that users of grsecurity claim that it caught bugs
in some drivers, but I haven't verified that personally; it's probably
much less useful than kasan (or even the original grsec feature) as a
bug-catcher since it doesn't clear freed slab buffers.

I'll wait a few more days for more reviews before sending the next
version, particularly on the power management part, and in general on
the usefulness of such feature.

Regards,

Anisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
