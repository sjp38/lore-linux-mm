Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id ECEBA6B0035
	for <linux-mm@kvack.org>; Sun, 20 Apr 2014 11:03:23 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so3075431eei.28
        for <linux-mm@kvack.org>; Sun, 20 Apr 2014 08:03:23 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id 45si49923870eeh.273.2014.04.20.08.03.22
        for <linux-mm@kvack.org>;
        Sun, 20 Apr 2014 08:03:22 -0700 (PDT)
Date: Sun, 20 Apr 2014 17:03:21 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Message-ID: <20140420150321.GC15332@amd.pavel.ucw.cz>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
 <20140320153250.GC20618@thunk.org>
 <CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com>
 <20140320163806.GA10440@thunk.org>
 <5346ED93.9040500@amacapital.net>
 <20140410203246.GB31614@thunk.org>
 <CALCETrVmaGNCxo-L4-dPbUev3VXXEPR7xBzo3Fux6ny7yh_Gzw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVmaGNCxo-L4-dPbUev3VXXEPR7xBzo3Fux6ny7yh_Gzw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Theodore Ts'o <tytso@mit.edu>, David Herrmann <dh.herrmann@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Thu 2014-04-10 13:37:26, Andy Lutomirski wrote:
> On Thu, Apr 10, 2014 at 1:32 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> > On Thu, Apr 10, 2014 at 12:14:27PM -0700, Andy Lutomirski wrote:
> >>
> >> This is the second time in a week that someone has asked for a way to
> >> have a struct file (or struct inode or whatever) that can't be reopened
> >> through /proc/pid/fd.  This should be quite easy to implement as a
> >> separate feature.
> >
> > What I suggested on a different thread was to add the following new
> > file descriptor flags, to join FD_CLOEXEC, which would be maniuplated
> > using the F_GETFD and F_SETFD fcntl commands:
> >
> > FD_NOPROCFS     disallow being able to open the inode via /proc/<pid>/fd
> >
> > FD_NOPASSFD     disallow being able to pass the fd via a unix domain socket
> >
> > FD_LOCKFLAGS    if this bit is set, disallow any further changes of FD_CLOEXEC,
> >                 FD_NOPROCFS, FD_NOPASSFD, and FD_LOCKFLAGS flags.
> >
> > Regardless of what else we might need to meet the use case for the
> > proposed File Sealing API, I think this is a useful feature that could
> > be used in many other contexts besides just the proposed
> > memfd_create() use case.
> 
> It occurs to me that, before going nuts with these kinds of flags, it
> may pay to just try to fix the /proc/self/fd issue for real -- we
> could just make open("/proc/self/fd/3", O_RDWR) fail if fd 3 is
> read-only.  That may be enough for the file sealing thing.

Yes please.

Current behaviour is very unexpected, and unexpected behaviour in
security area is normally called "security hole".

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
