Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 688EE6B00B0
	for <linux-mm@kvack.org>; Mon, 18 May 2015 09:02:17 -0400 (EDT)
Received: by wibt6 with SMTP id t6so68806773wib.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 06:02:16 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id fj6si12597664wib.55.2015.05.18.06.02.15
        for <linux-mm@kvack.org>;
        Mon, 18 May 2015 06:02:15 -0700 (PDT)
Date: Mon, 18 May 2015 15:02:13 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v4 2/3] mm/page_alloc.c: add config option to sanitize
 freed pages
Message-ID: <20150518130213.GA771@amd>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu>
 <1431613188-4511-3-git-send-email-anisse@astier.eu>
 <20150518112152.GA16999@amd>
 <CALUN=qLHfz5DnSKfaRf833eewOM65FNtxybY9Xw9sp1=qq+Zqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALUN=qLHfz5DnSKfaRf833eewOM65FNtxybY9Xw9sp1=qq+Zqw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon 2015-05-18 14:41:19, Anisse Astier wrote:
> On Mon, May 18, 2015 at 1:21 PM, Pavel Machek <pavel@ucw.cz> wrote:
> > On Thu 2015-05-14 16:19:47, Anisse Astier wrote:
> >> This new config option will sanitize all freed pages. This is a pretty
> >> low-level change useful to track some cases of use-after-free, help
> >> kernel same-page merging in VM environments, and counter a few info
> >> leaks.
> >
> > Could you document the "few info leaks"? We may want to fix them for
> > !SANTIZE_FREED_PAGES case, too...
> >
> 
> I wish I could; I'd be sending patches for those info leaks, too.
> 
> What I meant is that this feature can also be used as a general
> protection mechanism against a certain class of info leaks; for
> example, some drivers allocating pages that were previously used by
> other subsystems, and then sending structures to userspace that
> contain padding or uninitialized fields, leaking kernel pointers.
> Having all pages cleared unconditionally can help a bit in some cases
> (hence "a few"), but it's of course not an end-all solution.

Ok. So there is class of errors where this helps, but you are not
aware of any such errors in kernel, so you can't fix them... Right?

> I'll edit the commit and kconfig messages to be more precise.

Thanks,
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
