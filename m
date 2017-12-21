Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 902826B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 10:08:45 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e128so4002176wmg.1
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 07:08:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j10si4948274wmi.182.2017.12.21.07.08.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Dec 2017 07:08:44 -0800 (PST)
Date: Thu, 21 Dec 2017 16:08:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: known bad patch in -mm tree was Re: [PATCH 2/2] mmap.2:
 MAP_FIXED updated documentation
Message-ID: <20171221150840.GF4831@dhcp22.suse.cz>
References: <20171213130458.GI25185@dhcp22.suse.cz>
 <20171213130900.GA19932@amd>
 <20171213131640.GJ25185@dhcp22.suse.cz>
 <20171213132105.GA20517@amd>
 <20171213144050.GG11493@rei>
 <CAGXu5jLqE6cUxk-Girx6PG7upEzz8jmu1OH_3LVC26iJc2vTxQ@mail.gmail.com>
 <c7c7a30e-a122-1bbf-88a2-3349d755c62d@gmail.com>
 <CAGXu5jJ289R9koVoHmxcvUWr6XHSZR2p0qq3WtpNyN-iNSvrNQ@mail.gmail.com>
 <87po78fe7m.fsf@concordia.ellerman.id.au>
 <20171221145907.GA7604@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171221145907.GA7604@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Michael Ellerman <mpe@ellerman.id.au>, vojtech@suse.cz, jikos@suse.cz, Kees Cook <keescook@chromium.org>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Cyril Hrubis <chrubis@suse.cz>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Thu 21-12-17 15:59:07, Pavel Machek wrote:
> Hi!
> 
> > >>> And if Michal doesn't want to touch this patch any more, I'm happy to
> > >>> do the search/replace/resend. :P
> > >>
> > >> Something with the prefix MAP_FIXED_ seems to me obviously desirable,
> > >> both to suggest that the function is similar, and also for easy
> > >> grepping of the source code to look for instances of both.
> > >> MAP_FIXED_SAFE didn't really bother me as a name, but
> > >> MAP_FIXED_NOREPLACE (or MAP_FIXED_NOCLOBBER) seem slightly more
> > >> descriptive of what the flag actually does, so a little better.
> > >
> > > Great, thanks!
> > >
> > > Andrew, can you s/MAP_FIXED_SAFE/MAP_FIXED_NOREPLACE/g in the series?
> > 
> > This seems to have not happened. Presumably Andrew just missed the mail
> > in the flood. And will probably miss this one too ... :)
> 
> Nice way to mess up kernel development, Michal. Thank you! :-(.

Thank you for your valuable feedback! Maybe you have noticed that I
haven't enforced the patch and led others to decide the final name
(either by resubmitting patches or a simple replace in mmotm tree). Or
maybe you haven't because you are so busy bikesheding that you can
hardly see anything else.
 
> Andrew, everyone and their dog agrees MAP_FIXED_SAFE is stupid name,
> but Michal decided to just go ahead, ignoring feedback...
>
> Can you either s/MAP_FIXED_SAFE/MAP_FIXED_NOREPLACE/g or drop the patches?

You have surely saved the world today and I hardly find words to thank
you (and your dog of course).

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
