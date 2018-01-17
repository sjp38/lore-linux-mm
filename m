Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93EFF6B0261
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 18:26:35 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id f133so8060069itb.1
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:26:35 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p198sor3037327ioe.240.2018.01.17.15.26.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 15:26:34 -0800 (PST)
Date: Wed, 17 Jan 2018 15:26:31 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 0/1] Re: kernel BUG at fs/userfaultfd.c:LINE!
Message-ID: <20180117232631.gniczgvil5lsml6p@gmail.com>
References: <20171222222346.GB28786@zzz.localdomain>
 <20171223002505.593-1-aarcange@redhat.com>
 <CACT4Y+av2MyJHHpPQLQ2EGyyW5vAe3i-U0pfVXshFm96t-1tBQ@mail.gmail.com>
 <20180117085629.GA20303@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117085629.GA20303@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs@googlegroups.com

On Wed, Jan 17, 2018 at 09:56:29AM +0100, Pavel Machek wrote:
> Hi!
> 
> > > Andrea Arcangeli (1):
> > >   userfaultfd: clear the vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK
> > >     fails
> > >
> > >  fs/userfaultfd.c | 20 ++++++++++++++++++--
> > >  1 file changed, 18 insertions(+), 2 deletions(-)
> > 
> > The original report footer was stripped, so:
> > 
> > Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
> 
> Please don't. We don't credit our CPUs, and we don't credit Qemu. We
> credit humans.
> 

The difference is that unlike your CPU or QEMU, syzbot is a program specifically
written to find and report Linux kernel bugs.  And although Dmitry Vyukov has
done most of the work, syzkaller and syzbot have had many contributors, and you
are welcome to contribute too: https://github.com/google/syzkaller

> > and we also need to tell syzbot about the fix with:
> > 
> > #syz fix:
> > userfaultfd: clear the vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK fails
> 
> Now you claimed you care about bugs being fixed. What about actually
> testing Andrea's fix and telling us if it fixes the problem or not,
> and maybe saying "thank you"?

Of course the syzbot team cares about bugs being fixed, why else would they
report them?

I too would like to see syzbot become smarter about handling bugs with
reproducers.  For example it could bisect to find the commit which introduced
the bug, and could automatically detect where the bug has/hasn't been fixed.  Of
course due to the nature of the kernel it's not possible with every bug, but for
some it is possible.

Nevertheless, at the end of the day, no matter how a bug is reported or who
reports it, it is primarily the responsibility of the person patching the bug to
test their patch.  I've never really understood why people try to patch
reproducible bugs without even testing their fix; it just doesn't make any
sense.  It's pretty easy to run the syzkaller-provided reproducers too.
Personally I've fixed 20+ syzkaller-reported bugs, and I always run the
reproducer if there is one.  In fact the reproducer is usually needed to even
figure out what to fix in the first place...

Yes, Andrea deserves thanks for fixing this bug!  But so does syzbot and its
authors for reporting this bug.  And personally I am not at all impressed by the
fact that userfaultfd has no maintainer listed in MAINTAINERS, nor did any of
the authors feel responsible enough to quickly patch a critical security bug in
code they wrote less than a year ago, even after I Cc'ed them with a simplified
reproducer and explanation of the problem.  Note that userfaultfd is usable by
unprivileged users and is enabled on most major Linux distros.  Does syzbot need
to start automatically requesting CVE's as well? :-)

(And yes, I wanted to fix this myself, as I've done with a lot of other of the
syzbot-reported bugs, but unfortunately I wasn't familiar enough with the
userfaultfd code, and there are 200 other bugs to work on too...)

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
