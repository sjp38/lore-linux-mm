Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C815C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:38:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED06520850
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:38:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HXuNvrsq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED06520850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88F4D6B0003; Wed, 20 Mar 2019 14:38:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83E536B0006; Wed, 20 Mar 2019 14:38:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72C5A6B0007; Wed, 20 Mar 2019 14:38:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 43C8B6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:38:49 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id b123so1313496vka.21
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:38:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=rvbOUyKpmu+AiCtzN1R5Y5Bbn8gMm0EmsqyJr92bPm4=;
        b=rvTQXPdy5EC940Tceo3KztIeRm8pbbg61WWAvGMTB/qPMKac9W4hiORV2OGMqPAYK9
         XCBwlEk5G01vOOub8Mu6Olna9718ZcwuYm/E2YUwEzp+Qs4/6CYwxZimvKck/XTFVpuQ
         AIfd7NjJb2C2dEAaQMkQgmI9S2q51F/OiL1/AJi09vMFEPTu+finLQefKmiw240luuUr
         F/HpMYw88ba9zeX4Um2jnx6xj6wUJlkcZ+ACfZQ/Bba/xftBq2xXCEck8p7EC+76PLnK
         lhwKMOBrjRngatHdyxvVEsdArMcN368l5M0SbsoWpiCcIicu39IycNs6wYUaSnClu3PM
         JSWA==
X-Gm-Message-State: APjAAAXLJ2LxILz+drXPIV14FvysukZCMpZz7qjtckqKoFK+ar/wLPD3
	hxspecxWPj/YWZLkIGcyQxCsPbRXvMGvyvCiIyYOwyR90ivFf1QUrptPnRjgM8fjDTaVHrFuhgS
	ZoZ6wETn5EYNPUy5VGpyNnrI7evgruqJWfNiPaGExz7XgcXW1Lh1mTGYeIShXt/0SKg==
X-Received: by 2002:a67:ea18:: with SMTP id g24mr5537496vso.228.1553107128868;
        Wed, 20 Mar 2019 11:38:48 -0700 (PDT)
X-Received: by 2002:a67:ea18:: with SMTP id g24mr5537442vso.228.1553107127605;
        Wed, 20 Mar 2019 11:38:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553107127; cv=none;
        d=google.com; s=arc-20160816;
        b=JReKTeYcPpd/iV9k8hjsG6qlYLDgKUHVyMZB++g8ROc/VjDd+tOO9j5IWR9IEOc7wX
         L1T0Tndp6fXwSG0GAbdJVVlD8qSxo8v8iXkDEgveT6tyhYpkJ8N+cMv15ad3AjVidjva
         mbV69Pfw0pLSEKG2yslzLvR/FVBNRHdlEXvXypT12btmt6v3sN8y33FBx2PHGH09IXZh
         xXSomCa7yITyWAh7ot7JT0TAiu45S8hP1oeVgP1c0hRhliLj6CyzqMOgCme5B550Q53x
         vNNq6XOhyL7RA1G81oaabI7udTbVvDljaL7lCm1aBSndsiMyLmZ5msXSPb0ocKz+Q1SA
         bWGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=rvbOUyKpmu+AiCtzN1R5Y5Bbn8gMm0EmsqyJr92bPm4=;
        b=psk2Z7OVik3J/Hxpo5XYK4yJPeg+oNR12ERgYaPaT2usvqQ+2KjuiXVEMxuSTb6vWE
         EqEMWZeDK/j/lo/fsY9Y04vhDLONkRHV9094b+x7j82UKF7FU4HTLjPCv/BTr58XofRN
         Rv7VFry0Kc1LbhAkWSmMQf0m9NrpYFSGF2zdkIZMFpk9gd6UA/J2q+fS0+pdJYQDmvQn
         hRE7g1lxegV2b3uGnwkjdNBbFCK+7QSMt4PmovSQanwh8KMIBZDTjwh6KAGeZIklSYyq
         1/dpTbeVO5kAMF94maR8i6bWFl3Dbeu8l/iIgd1I9lqp1YUA2PjoYoitFgpdwJpV0CLI
         xJyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HXuNvrsq;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r15sor2132299vso.94.2019.03.20.11.38.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 11:38:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HXuNvrsq;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=rvbOUyKpmu+AiCtzN1R5Y5Bbn8gMm0EmsqyJr92bPm4=;
        b=HXuNvrsqacrSDP3shXNeKed1aW8sI1oNdnWi/Ek4O3lPUj4Bac+T6pazfBUT6B6lXr
         JTjKTfXg7BnTs1s2FmOT72s2mU6aXquGWUAEvBtyM5ST75wtxtClKSRZ5BdaPdKhNKW7
         YfN/Qs/hEGDZaSvQ7c8/LXzA7BWLjY8BUSaekxQEiT3gNUZ+gDe1c1ZSfgu4Arz8q4cb
         ZrjeztsSRu8XXQLnu/4ID2UIdDfpNmXoK2eDs68n9sDncFaK+FFiXiUw76787mAbeHcw
         +dYAvUih0tMxqYjg2e4ZQ5+0aEWiypbmowCaPshVW38OJqfnf/67eMxchYXY3brzxwUh
         BnrQ==
X-Google-Smtp-Source: APXvYqyXejMHsJCD2Zzd0/nTA6NPYk7zKE3kI510Bxr22HtPshdIeXj5A8f8ZUUrkEMPRoVqDMc013+tm4FKQkZUyMM=
X-Received: by 2002:a67:bc01:: with SMTP id t1mr6069870vsn.149.1553107126804;
 Wed, 20 Mar 2019 11:38:46 -0700 (PDT)
MIME-Version: 1.0
References: <20190318002949.mqknisgt7cmjmt7n@brauner.io> <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io> <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io> <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io> <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org> <20190320182649.spryp5uaeiaxijum@brauner.io>
In-Reply-To: <20190320182649.spryp5uaeiaxijum@brauner.io>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 20 Mar 2019 11:38:35 -0700
Message-ID: <CAKOZuevHbQtrq+Nb-jw1L7O72BmAzcXmbUnfnseeXZjX4PE4tg@mail.gmail.com>
Subject: Re: pidfd design
To: Christian Brauner <christian@brauner.io>
Cc: Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Steven Rostedt <rostedt@goodmis.org>, Sultan Alsawaf <sultan@kerneltoast.com>, 
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>, Oleg Nesterov <oleg@redhat.com>, 
	Andy Lutomirski <luto@amacapital.net>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 11:26 AM Christian Brauner <christian@brauner.io> w=
rote:
> On Wed, Mar 20, 2019 at 07:33:51AM -0400, Joel Fernandes wrote:
> >
> >
> > On March 20, 2019 3:02:32 AM EDT, Daniel Colascione <dancol@google.com>=
 wrote:
> > >On Tue, Mar 19, 2019 at 8:59 PM Christian Brauner
> > ><christian@brauner.io> wrote:
> > >>
> > >> On Tue, Mar 19, 2019 at 07:42:52PM -0700, Daniel Colascione wrote:
> > >> > On Tue, Mar 19, 2019 at 6:52 PM Joel Fernandes
> > ><joel@joelfernandes.org> wrote:
> > >> > >
> > >> > > On Wed, Mar 20, 2019 at 12:10:23AM +0100, Christian Brauner
> > >wrote:
> > >> > > > On Tue, Mar 19, 2019 at 03:48:32PM -0700, Daniel Colascione
> > >wrote:
> > >> > > > > On Tue, Mar 19, 2019 at 3:14 PM Christian Brauner
> > ><christian@brauner.io> wrote:
> > >> > > > > > So I dislike the idea of allocating new inodes from the
> > >procfs super
> > >> > > > > > block. I would like to avoid pinning the whole pidfd
> > >concept exclusively
> > >> > > > > > to proc. The idea is that the pidfd API will be useable
> > >through procfs
> > >> > > > > > via open("/proc/<pid>") because that is what users expect
> > >and really
> > >> > > > > > wanted to have for a long time. So it makes sense to have
> > >this working.
> > >> > > > > > But it should really be useable without it. That's why
> > >translate_pid()
> > >> > > > > > and pidfd_clone() are on the table.  What I'm saying is,
> > >once the pidfd
> > >> > > > > > api is "complete" you should be able to set CONFIG_PROCFS=
=3DN
> > >- even
> > >> > > > > > though that's crazy - and still be able to use pidfds. Thi=
s
> > >is also a
> > >> > > > > > point akpm asked about when I did the pidfd_send_signal
> > >work.
> > >> > > > >
> > >> > > > > I agree that you shouldn't need CONFIG_PROCFS=3DY to use
> > >pidfds. One
> > >> > > > > crazy idea that I was discussing with Joel the other day is
> > >to just
> > >> > > > > make CONFIG_PROCFS=3DY mandatory and provide a new
> > >get_procfs_root()
> > >> > > > > system call that returned, out of thin air and independent o=
f
> > >the
> > >> > > > > mount table, a procfs root directory file descriptor for the
> > >caller's
> > >> > > > > PID namspace and suitable for use with openat(2).
> > >> > > >
> > >> > > > Even if this works I'm pretty sure that Al and a lot of others
> > >will not
> > >> > > > be happy about this. A syscall to get an fd to /proc?
> > >> >
> > >> > Why not? procfs provides access to a lot of core kernel
> > >functionality.
> > >> > Why should you need a mountpoint to get to it?
> > >> >
> > >> > > That's not going
> > >> > > > to happen and I don't see the need for a separate syscall just
> > >for that.
> > >> >
> > >> > We need a system call for the same reason we need a getrandom(2):
> > >you
> > >> > have to bootstrap somehow when you're in a minimal environment.
> > >> >
> > >> > > > (I do see the point of making CONFIG_PROCFS=3Dy the default bt=
w.)
> > >> >
> > >> > I'm not proposing that we make CONFIG_PROCFS=3Dy the default. I'm
> > >> > proposing that we *hardwire* it as the default and just declare
> > >that
> > >> > it's not possible to build a Linux kernel that doesn't include
> > >procfs.
> > >> > Why do we even have that button?
> > >> >
> > >> > > I think his point here was that he wanted a handle to procfs no
> > >matter where
> > >> > > it was mounted and then can later use openat on that. Agreed tha=
t
> > >it may be
> > >> > > unnecessary unless there is a usecase for it, and especially if
> > >the /proc
> > >> > > directory being the defacto mountpoint for procfs is a universal
> > >convention.
> > >> >
> > >> > If it's a universal convention and, in practice, everyone needs
> > >proc
> > >> > mounted anyway, so what's the harm in hardwiring CONFIG_PROCFS=3Dy=
?
> > >If
> > >> > we advertise /proc as not merely some kind of optional debug
> > >interface
> > >> > but *the* way certain kernel features are exposed --- and there's
> > >> > nothing wrong with that --- then we should give programs access to
> > >> > these core kernel features in a way that doesn't depend on
> > >userspace
> > >> > kernel configuration, and you do that by either providing a
> > >> > procfs-root-getting system call or just hardwiring the "/proc/"
> > >prefix
> > >> > into VFS.
> > >> >
> > >> > > > Inode allocation from the procfs mount for the file descriptor=
s
> > >Joel
> > >> > > > wants is not correct. Their not really procfs file descriptors
> > >so this
> > >> > > > is a nack. We can't just hook into proc that way.
> > >> > >
> > >> > > I was not particular about using procfs mount for the FDs but
> > >that's the only
> > >> > > way I knew how to do it until you pointed out anon_inode (my gre=
p
> > >skills
> > >> > > missed that), so thank you!
> > >> > >
> > >> > > > > C'mon: /proc is used by everyone today and almost every
> > >program breaks
> > >> > > > > if it's not around. The string "/proc" is already de facto
> > >kernel ABI.
> > >> > > > > Let's just drop the pretense of /proc being optional and bak=
e
> > >it into
> > >> > > > > the kernel proper, then give programs a way to get to /proc
> > >that isn't
> > >> > > > > tied to any particular mount configuration. This way, we
> > >don't need a
> > >> > > > > translate_pid(), since callers can just use procfs to do the
> > >same
> > >> > > > > thing. (That is, if I understand correctly what translate_pi=
d
> > >does.)
> > >> > > >
> > >> > > > I'm not sure what you think translate_pid() is doing since
> > >you're not
> > >> > > > saying what you think it does.
> > >> > > > Examples from the old patchset:
> > >> > > > translate_pid(pid, ns, -1)      - get pid in our pid namespace
> > >> >
> > >> > Ah, it's a bit different from what I had in mind. It's fair to wan=
t
> > >to
> > >> > translate PIDs between namespaces, but the only way to make the
> > >> > translate_pid under discussion robust is to have it accept and
> > >produce
> > >> > pidfds. (At that point, you might as well call it translate_pidfd.=
)
> > >We
> > >> > should not be adding new APIs to the kernel that accept numeric
> > >PIDs:
> > >>
> > >> The traditional pid-based api is not going away. There are users tha=
t
> > >> have the requirement to translate pids between namespaces and also
> > >doing
> > >> introspection on these namespaces independent of pidfds. We will not
> > >> restrict the usefulness of this syscall by making it only work with
> > >> pidfds.
> > >>
> > >> > it's not possible to use these APIs correctly except under very
> > >> > limited circumstances --- mostly, talking about init or a parent
> > >>
> > >> The pid-based api is one of the most widely used apis of the kernel
> > >and
> > >> people have been using it quite successfully for a long time. Yes,
> > >it's
> > >> rac, but it's here to stay.
> > >>
> > >> > talking about its child.
> > >> >
> > >> > Really, we need a few related operations, and we shouldn't
> > >necessarily
> > >> > mingle them.
> > >>
> > >> Yes, we've established that previously.
> > >>
> > >> >
> > >> > 1) Given a numeric PID, give me a pidfd: that works today: you jus=
t
> > >> > open /proc/<pid>
> > >>
> > >> Agreed.
> > >>
> > >> >
> > >> > 2) Given a pidfd, give me a numeric PID: that works today: you jus=
t
> > >> > openat(pidfd, "stat", O_RDONLY) and read the first token (which is
> > >> > always the numeric PID).
> > >>
> > >> Agreed.
> > >>
> > >> >
> > >> > 3) Given a pidfd, send a signal: that's what pidfd_send_signal
> > >does,
> > >> > and it's a good start on the rest of these operations.
> > >>
> > >> Agreed.
> > >>
> > >> > 5) Given a pidfd in NS1, get a pidfd in NS2. That's what
> > >translate_pid
> > >> > is for. My preferred signature for this routine is
> > >translate_pid(int
> > >> > pidfd, int nsfd) -> pidfd. We don't need two namespace arguments.
> > >Why
> > >> > not? Because the pidfd *already* names a single process, uniquely!
> > >>
> > >> Given that people are interested in pids we can't just always return
> > >a
> > >> pidfd. That would mean a user would need to do get the pidfd read
> > >from
> > >> <pidfd>/stat and then close the pidfd. If you do that for a 100 pids
> > >or
> > >> more you end up allocating and closing file descriptors constantly
> > >for
> > >> no reason. We can't just debate pids away. So it will also need to b=
e
> > >> able to yield pids e.g. through a flag argument.
> > >
> > >Sure, but that's still not a reason that we should care about pidfds
> > >working separately from procfs..
>
> That's unrelated to the point made in the above paragraph.
> Please note, I said that the pidfd api should work when proc is not
> available not that they can't be dirfds.

What do you mean by "not available"? CONFIG_PROCFS=3Dn? If pidfds
supposed to work when proc is unavailable yet also be directory FDs,
to what directory should the FD refer? As I mentioned in my previous
message, trying to make pidfd work without CONFIG_PROCFS is a very bad
idea.

>
> >
> > Agreed. I can't imagine pidfd being anything but a proc pid directory h=
andle. So I am confused what Christian meant. Pidfd *is* a procfs directory=
 fid  always. That's what I gathered from his pidfd_send_signal patch but l=
et me know if I'm way off in the woods.
>
> (K9 Mail still hasn't learned to wrap lines at 80 it seems. :))
>
> Again, I never said that pidfds should be a directory handle.
> (Though I would like to point out that one of the original ideas I
> discussed at LPC was to have something like this to get regular file
> descriptors instead of dirfds:
> https://gist.github.com/brauner/59eec91550c5624c9999eaebd95a70df)

As I mentioned in my original email on this thread, if you have
regular file descriptors instead of directory FDs, you have to use
some special new API instead of openat to get metadata about a
process. That's pointless duplication of functionality considering
that a directory FD gives you that information automatically.

> > For my next revision, I am thinking of adding the flag argument Christi=
an mentioned to make translate_pid return an anon_inode FD which can be use=
d for death status, given a <pid>. Since it is thought that translate_pid c=
an be made to return a pid FD, I think it is ok to have it return a pid sta=
tus FD for the purposes of the death status as well.

> translate_pid() should just return you a pidfd. Having it return a pidfd
> and a status fd feels like stuffing too much functionality in there. If
> you're fine with it I'll finish prototyping what I had in mind. As I
> said in previous mails I'm already working on this.

translate_pid also needs to *accept* pidfds, at least optionally.
Unless you have a function from pidfd to pidfd, you race.

