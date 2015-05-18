Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD466B00AA
	for <linux-mm@kvack.org>; Mon, 18 May 2015 08:41:43 -0400 (EDT)
Received: by laat2 with SMTP id t2so217427641laa.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 05:41:42 -0700 (PDT)
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com. [209.85.215.51])
        by mx.google.com with ESMTPS id p5si6611966laj.137.2015.05.18.05.41.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 05:41:41 -0700 (PDT)
Received: by lagr1 with SMTP id r1so136147226lag.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 05:41:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150518112152.GA16999@amd>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu>
 <1431613188-4511-3-git-send-email-anisse@astier.eu> <20150518112152.GA16999@amd>
From: Anisse Astier <anisse@astier.eu>
Date: Mon, 18 May 2015 14:41:19 +0200
Message-ID: <CALUN=qLHfz5DnSKfaRf833eewOM65FNtxybY9Xw9sp1=qq+Zqw@mail.gmail.com>
Subject: Re: [PATCH v4 2/3] mm/page_alloc.c: add config option to sanitize
 freed pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, May 18, 2015 at 1:21 PM, Pavel Machek <pavel@ucw.cz> wrote:
> On Thu 2015-05-14 16:19:47, Anisse Astier wrote:
>> This new config option will sanitize all freed pages. This is a pretty
>> low-level change useful to track some cases of use-after-free, help
>> kernel same-page merging in VM environments, and counter a few info
>> leaks.
>
> Could you document the "few info leaks"? We may want to fix them for
> !SANTIZE_FREED_PAGES case, too...
>

I wish I could; I'd be sending patches for those info leaks, too.

What I meant is that this feature can also be used as a general
protection mechanism against a certain class of info leaks; for
example, some drivers allocating pages that were previously used by
other subsystems, and then sending structures to userspace that
contain padding or uninitialized fields, leaking kernel pointers.
Having all pages cleared unconditionally can help a bit in some cases
(hence "a few"), but it's of course not an end-all solution.

I'll edit the commit and kconfig messages to be more precise.

Regards,

Anisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
