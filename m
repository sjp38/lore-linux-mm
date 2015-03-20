Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8FF6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 12:09:14 -0400 (EDT)
Received: by lbblx11 with SMTP id lx11so56646304lbb.3
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:09:13 -0700 (PDT)
Received: from mail-lb0-x22c.google.com (mail-lb0-x22c.google.com. [2a00:1450:4010:c04::22c])
        by mx.google.com with ESMTPS id z6si328496lag.156.2015.03.20.09.09.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 09:09:12 -0700 (PDT)
Received: by lbcgn8 with SMTP id gn8so78679370lbc.2
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:09:12 -0700 (PDT)
Date: Fri, 20 Mar 2015 19:09:10 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH -next v2 0/4] mm: replace mmap_sem for mm->exe_file
 serialization
Message-ID: <20150320160910.GA27066@moon>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
 <20150315142137.GA21741@redhat.com>
 <1426431270.28068.92.camel@stgolabs.net>
 <20150315152652.GA24590@redhat.com>
 <1426434125.28068.100.camel@stgolabs.net>
 <20150315170521.GA2278@moon>
 <CAGXu5j+S1iw6VCjqfS_sPTOjNz8XAy0kkFD7dTvvTTgagx-PMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+S1iw6VCjqfS_sPTOjNz8XAy0kkFD7dTvvTTgagx-PMA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, koct9i@gmail.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 16, 2015 at 03:08:40PM -0700, Kees Cook wrote:
> >
> >> Ok I think I am finally seeing where you are going. And I like it *a
> >> lot* because it allows us to basically replace mmap_sem with rcu
> >> (MMF_EXE_FILE_CHANGED being the only user that requires a lock!!), but
> >> am afraid it might not be possible. I mean currently we have no rule wrt
> >> to users that don't deal with prctl.
> >>
> >> Forbidding multiple exe_file changes to be generic would certainly
> >> change address space semantics, probably for the better (tighter around
> >> security), but changed nonetheless so users would have a right to
> >> complain, no? So if we can get away with removing MMF_EXE_FILE_CHANGED
> >> I'm all for it. Andrew?
> 
> I can't figure out why MMF_EXE_FILE_CHANGED is used to stop a second
> change. But it does seem useful to mark a process as "hey, we know for
> sure this the exe_file changed on this process" from an accounting
> perspective.

Sure, except it start being more stopper for further development so
ripping it off would help ;)

> 
> And I'd agree about the malware: it would never use this interface, so
> there's no security benefit I can see. Maybe I haven't had enough
> coffee, though. :)

Yes, same here, would never use it either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
