Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 442356B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 13:47:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b187so18403489wme.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 10:47:50 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id ke3si16244027wjb.240.2016.09.12.10.47.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 10:47:49 -0700 (PDT)
Date: Mon, 12 Sep 2016 19:47:47 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] PM / Hibernate: allow hibernation with
 PAGE_POISONING_ZERO
Message-ID: <20160912174747.GA8285@amd>
References: <1473410612-6207-1-git-send-email-anisse@astier.eu>
 <20160912113238.GA30927@amd>
 <CALUN=qJNX6HqrwXkk--8u0PiOxV-USE4tEouqimXPiRaobtAEw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALUN=qJNX6HqrwXkk--8u0PiOxV-USE4tEouqimXPiRaobtAEw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, linux-pm@vger.kernel.org, Mathias Krause <minipli@googlemail.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, Brad Spengler <spender@grsecurity.net>, Jianyu Zhan <nasa4836@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Yves-Alexis Perez <corsac@debian.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Len Brown <len.brown@intel.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, PaX Team <pageexec@freemail.hu>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>

Hi!

On Mon 2016-09-12 17:19:54, Anisse Astier wrote:
> Le 12 sept. 2016 13:32, "Pavel Machek" <pavel@ucw.cz> a ecrit :
> >
> > On Fri 2016-09-09 10:43:32, Anisse Astier wrote:
> > > PAGE_POISONING_ZERO disables zeroing new pages on alloc, they are
> > > poisoned (zeroed) as they become available.
> > > In the hibernate use case, free pages will appear in the system without
> > > being cleared, left there by the loading kernel.
> > >
> > > This patch will make sure free pages are cleared on resume when
> > > PAGE_POISONING_ZERO is enabled. We free the pages just after resume
> > > because we can't do it later: going through any device resume code might
> > > allocate some memory and invalidate the free pages bitmap.
> > >
> > > Thus we don't need to disable hibernation when PAGE_POISONING_ZERO is
> > > enabled.
> > >
> > > Signed-off-by: Anisse Astier <anisse@astier.eu>
> > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Cc: Laura Abbott <labbott@fedoraproject.org>
> > > Cc: Mel Gorman <mgorman@suse.de>
> > > Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
> >
> > Looks reasonable to me.
> >
> > Acked-by: Pavel Machek <pavel@ucw.cz>
> >
> > Actually.... this takes basically zero time come. Do we want to do it
> > unconditionally?
> >
> > (Yes, it is free memory, but for sake of debugging, I guess zeros are
> > preffered to random content that changed during hibernation.)
> >
> > (But that does not change the Ack.)
> >
> > Best regards,
> >
> Pavel
> > --
> 
> I have no opposition on doing this unconditionally. I can send a v2 as soon
> as I get closer to a computer.

Actually, I'd keep this one as is, when it works and there are no
problems for a release or so, we can delete the ifdefs.

Thanks!
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
