Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 648166B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:57:42 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n187so19873890pfn.10
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 00:57:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n128si14866371pga.72.2017.12.22.00.57.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Dec 2017 00:57:41 -0800 (PST)
Date: Fri, 22 Dec 2017 09:57:30 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: general protection fault in finish_task_switch
Message-ID: <20171222085730.c4kkiohz3fkwsqnr@hirez.programming.kicks-ass.net>
References: <001a113ef748cc1ee50560c7b718@google.com>
 <CA+55aFyco00CBed1ADAz+EGtoP6w+nvuR2Y+YWH13cvkatOg4w@mail.gmail.com>
 <20171222081756.ur5uuh5wjri2ymyk@hirez.programming.kicks-ass.net>
 <CACT4Y+Z7__4qeMP-jG07-M+ugL3PxkQ_z83=TB8O9e4=jjV4ug@mail.gmail.com>
 <20171222083615.dr7jpzjjc6ye3eut@hirez.programming.kicks-ass.net>
 <CACT4Y+Yb7a_tiGc4=NHSMpqv30-kBKO0iwAn79M6yv_EaRwG3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Yb7a_tiGc4=NHSMpqv30-kBKO0iwAn79M6yv_EaRwG3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, syzbot <bot+72c44cd8b0e8a1a64b9c03c4396aea93a16465ef@syzkaller.appspotmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jiang <dave.jiang@intel.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, tcharding <me@tobin.cc>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, syzkaller-bugs@googlegroups.com, Matthew Wilcox <willy@infradead.org>, Eric Biggers <ebiggers3@gmail.com>

On Fri, Dec 22, 2017 at 09:44:11AM +0100, Dmitry Vyukov wrote:
> On Fri, Dec 22, 2017 at 9:36 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Fri, Dec 22, 2017 at 09:26:28AM +0100, Dmitry Vyukov wrote:
> >> I think this is another manifestation of "KASAN: use-after-free Read
> >> in __schedule":
> >> https://groups.google.com/forum/#!msg/syzkaller-bugs/-8JZhr4W8AY/FpPFh8EqAQAJ
> >> +Eric already mailed a fix for it (indeed new bug in kvm code).
> >
> > FWIW, these google links keep translating everything to my local
> > language, is there any way to tell google to not do stupid stuff like
> > that and give me English like computers ought to speak?
> 
> 
> The group has "Group's primary language: English" in settings. I guess
> that's either your Google account settings (if you are signed in), or
> browser settings.
> For chrome there is an option in setting for preferred languages,
> browsers are supposed to send that in requests. For google account
> check https://myaccount.google.com/intro there is "Languages" section.

I do not use (nor want to) a google account to sign in. Chromium has
English set as the preferred language (I typically don't install weird
localisation things and language packs in any case; 7bit ASCII FTW).

I have also done the google.com/ncr thing, which got rid of google.com
defaulting to google.nl, but groups.google.com keeps insisting on
translating the 'app' to Dutch. Seeing both Dutch and English (the
actual messages) at the same time completely screws my brain.

I'd file a bug against groups.google.com for not respecting the /ncr
thing, but I suspect you'd require a google account for that :-(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
