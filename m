Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8AF6B0109
	for <linux-mm@kvack.org>; Wed, 20 May 2015 08:28:00 -0400 (EDT)
Received: by wghq2 with SMTP id q2so51121699wgh.1
        for <linux-mm@kvack.org>; Wed, 20 May 2015 05:27:59 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id k7si3494128wiw.92.2015.05.20.05.27.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 05:27:58 -0700 (PDT)
Received: by wizk4 with SMTP id k4so153257792wiz.1
        for <linux-mm@kvack.org>; Wed, 20 May 2015 05:27:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFP4FLo9Lrr=pQzwLhj6EfiN5LgRTDMj_hBhQW58UQkC55mYHA@mail.gmail.com>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu>
 <1431613188-4511-3-git-send-email-anisse@astier.eu> <20150518112152.GA16999@amd>
 <CALUN=qLHfz5DnSKfaRf833eewOM65FNtxybY9Xw9sp1=qq+Zqw@mail.gmail.com>
 <20150518130213.GA771@amd> <CALUN=q+VyQgQ+F1HudumDSjFk1PFyEXdwxPNrM_VqKjDKHTfbw@mail.gmail.com>
 <CAFP4FLo9Lrr=pQzwLhj6EfiN5LgRTDMj_hBhQW58UQkC55mYHA@mail.gmail.com>
From: Anisse Astier <anisse@astier.eu>
Date: Wed, 20 May 2015 14:27:37 +0200
Message-ID: <CALUN=qJdiWn9BSYRq9HgXhGDaBKzApVG=JqFVb1B34Ut8U0k1w@mail.gmail.com>
Subject: Re: [PATCH v4 2/3] mm/page_alloc.c: add config option to sanitize
 freed pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, May 19, 2015 at 3:58 AM, yalin wang <yalin.wang2010@gmail.com> wrote:
> 2015-05-18 21:04 GMT+08:00 Anisse Astier <anisse@astier.eu>:
>> On Mon, May 18, 2015 at 3:02 PM, Pavel Machek <pavel@ucw.cz> wrote:
>>>
>>> Ok. So there is class of errors where this helps, but you are not
>>> aware of any such errors in kernel, so you can't fix them... Right?
>>
>> Correct.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> i feel your patch is the same as CONFIG_DEBUG_PAGEALLOC ,
> the difference is that CONFIG_DEBUG_PAGEALLOC  will clear
> page to a magic number, while your patch will
> clear to zero,
> do we really need this duplicated function ?

It's different because DEBUG_PAGEALLOC will only use page poisoning on
certain architectures, and clearing a page to a magic number doesn't
allow to optimize alloc with _GFP_ZERO.

Regards,

Anisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
