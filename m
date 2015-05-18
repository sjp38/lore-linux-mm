Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 84AD96B00B2
	for <linux-mm@kvack.org>; Mon, 18 May 2015 09:04:23 -0400 (EDT)
Received: by laat2 with SMTP id t2so218467929laa.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 06:04:23 -0700 (PDT)
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com. [209.85.215.50])
        by mx.google.com with ESMTPS id qh5si6671108lbb.28.2015.05.18.06.04.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 06:04:22 -0700 (PDT)
Received: by labbd9 with SMTP id bd9so219045809lab.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 06:04:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150518130213.GA771@amd>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu>
 <1431613188-4511-3-git-send-email-anisse@astier.eu> <20150518112152.GA16999@amd>
 <CALUN=qLHfz5DnSKfaRf833eewOM65FNtxybY9Xw9sp1=qq+Zqw@mail.gmail.com> <20150518130213.GA771@amd>
From: Anisse Astier <anisse@astier.eu>
Date: Mon, 18 May 2015 15:04:00 +0200
Message-ID: <CALUN=q+VyQgQ+F1HudumDSjFk1PFyEXdwxPNrM_VqKjDKHTfbw@mail.gmail.com>
Subject: Re: [PATCH v4 2/3] mm/page_alloc.c: add config option to sanitize
 freed pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, May 18, 2015 at 3:02 PM, Pavel Machek <pavel@ucw.cz> wrote:
>
> Ok. So there is class of errors where this helps, but you are not
> aware of any such errors in kernel, so you can't fix them... Right?

Correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
