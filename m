Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D90FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:52:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9F0C2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:52:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="MUWCNE26"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9F0C2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 799376B0003; Wed, 20 Mar 2019 14:52:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 749FE6B0006; Wed, 20 Mar 2019 14:52:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6393B6B0007; Wed, 20 Mar 2019 14:52:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 22F256B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:52:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d10so3472393pgv.23
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:52:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=O0pwskscChD2KWUNDJytHy8srTR0rSJasyoZouyeUZw=;
        b=oMizOsn3MeMbNPCuZ2IPx+NLw3aqIX1kH+SrU72vz0BCwlPh3S4kZN3CrUCfvTA/hC
         +t5K2y6f/DTIjKtBDAjS98fhNiauqYjNaS8v//Jy+8C81QY63tYbH37ndgF116NFwSSZ
         Od7+v6dDw/J6tUjPoQ1MqbMRLklrZYvl0n7wF8YOrGg1pJLaKnsTOhRrN4aXTLOS7y2F
         HCZir4BrHRWopOGkws/I7bgD1m8xCzJitYQOXQiIwAmi/kttckuR26XLppXutKydsHev
         COvPuqxxWWFHzTAAj0NydyFH4mF92k6dby+3CePaE0rON/gvdCDaNtWB3PNHDdKOat+B
         4kJw==
X-Gm-Message-State: APjAAAWWVYvUenkbmnsdjiPmk/J0TBl3vvXzu43BU00qc88OyU8C/9qJ
	taHzF/Q+5sVglP0GpxpBwUuN82qQcL+qksHdwiOD2r5OkE7HmWROUYFRhJDTTASqRzzKQUNCyOe
	/idK1X2FiSQWyyB+DXGsi6DL//RjfHpVx8CyqtFXanHR/fSRMZtOCrFcDzvaXgPz96w==
X-Received: by 2002:a62:1249:: with SMTP id a70mr9211303pfj.160.1553107921459;
        Wed, 20 Mar 2019 11:52:01 -0700 (PDT)
X-Received: by 2002:a62:1249:: with SMTP id a70mr9211247pfj.160.1553107920514;
        Wed, 20 Mar 2019 11:52:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553107920; cv=none;
        d=google.com; s=arc-20160816;
        b=pa8jNeRX8UAnso1/wysTrPlyNXn8YiVyldXkIG3QKvpQzftDbL+eyJVQ4ODZHMIM2x
         JR4HJ4HS43lxki7se+BvuLBbyFvUxmRM7yLmDG/yO84dn9AZkS+jEO9WIxnRIm3ZwcjT
         x/Mf3ZIw1aVLB/3+ELn86PBemhGlNc4uWwIwvkBu8YE3R33o08VCeYzt+b3xudFOvsN0
         xaUWZXEsGNUTcg7iZ1atVLlIULct+thPIyxur6VfesI3SDldA9lp5NdIOwLmGZMswrtS
         i6kbZYfeAj1WGTqTbLSfLM/TtictCWzui7hZpPQoqMMuYE5gbDwSJNPq9/TLf+E0ubP3
         RPOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=O0pwskscChD2KWUNDJytHy8srTR0rSJasyoZouyeUZw=;
        b=mrG89iKIdIy0ROF5fw2gcNJbLwYt5/TiKMOwCm9oeqKrW80AYhOsCE0Qyi0qZQgzwc
         KSOCnt5RnlnVutBHqCTKXXcOBe+JJVQITGut4NDU2C5Rjx8Jf9wdvQwlDkB3oLa6RFqm
         NBfF2wzkAAkdOL3bmElxYpcu2ywXgqcpWVf1176WejaGdb24d1K/nqk7e6TACbVtjnRb
         sdLBVE7s+xeEwi6FXnMRS0SamtaU1jGUdDCuWPaOY5SXr1PWPv8wNmbOdmeHK3iS0yHW
         eLHPbSwtUYUgu/cByns9kWsqeLbhFuDryzbh+9xI91rMjpIlvaG0/pgjBvYtOQdc5drc
         rSQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=MUWCNE26;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f4sor3233334pgq.28.2019.03.20.11.52.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 11:52:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=MUWCNE26;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=O0pwskscChD2KWUNDJytHy8srTR0rSJasyoZouyeUZw=;
        b=MUWCNE26UfN7REVsUmvmACQjU9soL7hFEPT90Tn9ftMORo8i9z51fSRUofDjGRhvN6
         bvS7iOW9BlfoogwJAguo5Z80p9bJ4RIKgT/qeuDupoYU+qvH+jVGZvWHZTgwxbCqd4Qq
         Ul8DLQ5JxTnGi7vnpi7zGXfk7hKZOa/El0ZbK+3XfNOFw24pjssCCRXK4+KPRVlsUwaa
         iumii/vY3IKnq4KqvwbdCksnIjIKv3zM2atgvjmAUohiciwR8Zk8x4sMzCfSFhipE3l4
         VBajpuj1NQOT/WsjWDvsYVrhMb86nNNYpKhAedNauybFeD4EVGTFjeZNISA2psj8qIkk
         lqTQ==
X-Google-Smtp-Source: APXvYqyMHsEfG60cUEp+mJX0d7JMzUr1naE2/Bd/bcLe+AFpmJJnRvf6MF4gGZgjSWj3UINQ7kkRiA==
X-Received: by 2002:a63:d302:: with SMTP id b2mr8805117pgg.13.1553107919930;
        Wed, 20 Mar 2019 11:51:59 -0700 (PDT)
Received: from brauner.io ([12.25.160.29])
        by smtp.gmail.com with ESMTPSA id k22sm3627823pfa.84.2019.03.20.11.51.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 11:51:59 -0700 (PDT)
Date: Wed, 20 Mar 2019 19:51:57 +0100
From: Christian Brauner <christian@brauner.io>
To: Daniel Colascione <dancol@google.com>
Cc: Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>
Subject: Re: pidfd design
Message-ID: <20190320185156.7bq775vvtsxqlzfn@brauner.io>
References: <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io>
 <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org>
 <20190320182649.spryp5uaeiaxijum@brauner.io>
 <CAKOZuevHbQtrq+Nb-jw1L7O72BmAzcXmbUnfnseeXZjX4PE4tg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAKOZuevHbQtrq+Nb-jw1L7O72BmAzcXmbUnfnseeXZjX4PE4tg@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 11:38:35AM -0700, Daniel Colascione wrote:
> On Wed, Mar 20, 2019 at 11:26 AM Christian Brauner <christian@brauner.io> wrote:
> > On Wed, Mar 20, 2019 at 07:33:51AM -0400, Joel Fernandes wrote:
> > >
> > >
> > > On March 20, 2019 3:02:32 AM EDT, Daniel Colascione <dancol@google.com> wrote:
> > > >On Tue, Mar 19, 2019 at 8:59 PM Christian Brauner
> > > ><christian@brauner.io> wrote:
> > > >>
> > > >> On Tue, Mar 19, 2019 at 07:42:52PM -0700, Daniel Colascione wrote:
> > > >> > On Tue, Mar 19, 2019 at 6:52 PM Joel Fernandes
> > > ><joel@joelfernandes.org> wrote:
> > > >> > >
> > > >> > > On Wed, Mar 20, 2019 at 12:10:23AM +0100, Christian Brauner
> > > >wrote:
> > > >> > > > On Tue, Mar 19, 2019 at 03:48:32PM -0700, Daniel Colascione
> > > >wrote:
> > > >> > > > > On Tue, Mar 19, 2019 at 3:14 PM Christian Brauner
> > > ><christian@brauner.io> wrote:
> > > >> > > > > > So I dislike the idea of allocating new inodes from the
> > > >procfs super
> > > >> > > > > > block. I would like to avoid pinning the whole pidfd
> > > >concept exclusively
> > > >> > > > > > to proc. The idea is that the pidfd API will be useable
> > > >through procfs
> > > >> > > > > > via open("/proc/<pid>") because that is what users expect
> > > >and really
> > > >> > > > > > wanted to have for a long time. So it makes sense to have
> > > >this working.
> > > >> > > > > > But it should really be useable without it. That's why
> > > >translate_pid()
> > > >> > > > > > and pidfd_clone() are on the table.  What I'm saying is,
> > > >once the pidfd
> > > >> > > > > > api is "complete" you should be able to set CONFIG_PROCFS=N
> > > >- even
> > > >> > > > > > though that's crazy - and still be able to use pidfds. This
> > > >is also a
> > > >> > > > > > point akpm asked about when I did the pidfd_send_signal
> > > >work.
> > > >> > > > >
> > > >> > > > > I agree that you shouldn't need CONFIG_PROCFS=Y to use
> > > >pidfds. One
> > > >> > > > > crazy idea that I was discussing with Joel the other day is
> > > >to just
> > > >> > > > > make CONFIG_PROCFS=Y mandatory and provide a new
> > > >get_procfs_root()
> > > >> > > > > system call that returned, out of thin air and independent of
> > > >the
> > > >> > > > > mount table, a procfs root directory file descriptor for the
> > > >caller's
> > > >> > > > > PID namspace and suitable for use with openat(2).
> > > >> > > >
> > > >> > > > Even if this works I'm pretty sure that Al and a lot of others
> > > >will not
> > > >> > > > be happy about this. A syscall to get an fd to /proc?
> > > >> >
> > > >> > Why not? procfs provides access to a lot of core kernel
> > > >functionality.
> > > >> > Why should you need a mountpoint to get to it?
> > > >> >
> > > >> > > That's not going
> > > >> > > > to happen and I don't see the need for a separate syscall just
> > > >for that.
> > > >> >
> > > >> > We need a system call for the same reason we need a getrandom(2):
> > > >you
> > > >> > have to bootstrap somehow when you're in a minimal environment.
> > > >> >
> > > >> > > > (I do see the point of making CONFIG_PROCFS=y the default btw.)
> > > >> >
> > > >> > I'm not proposing that we make CONFIG_PROCFS=y the default. I'm
> > > >> > proposing that we *hardwire* it as the default and just declare
> > > >that
> > > >> > it's not possible to build a Linux kernel that doesn't include
> > > >procfs.
> > > >> > Why do we even have that button?
> > > >> >
> > > >> > > I think his point here was that he wanted a handle to procfs no
> > > >matter where
> > > >> > > it was mounted and then can later use openat on that. Agreed that
> > > >it may be
> > > >> > > unnecessary unless there is a usecase for it, and especially if
> > > >the /proc
> > > >> > > directory being the defacto mountpoint for procfs is a universal
> > > >convention.
> > > >> >
> > > >> > If it's a universal convention and, in practice, everyone needs
> > > >proc
> > > >> > mounted anyway, so what's the harm in hardwiring CONFIG_PROCFS=y?
> > > >If
> > > >> > we advertise /proc as not merely some kind of optional debug
> > > >interface
> > > >> > but *the* way certain kernel features are exposed --- and there's
> > > >> > nothing wrong with that --- then we should give programs access to
> > > >> > these core kernel features in a way that doesn't depend on
> > > >userspace
> > > >> > kernel configuration, and you do that by either providing a
> > > >> > procfs-root-getting system call or just hardwiring the "/proc/"
> > > >prefix
> > > >> > into VFS.
> > > >> >
> > > >> > > > Inode allocation from the procfs mount for the file descriptors
> > > >Joel
> > > >> > > > wants is not correct. Their not really procfs file descriptors
> > > >so this
> > > >> > > > is a nack. We can't just hook into proc that way.
> > > >> > >
> > > >> > > I was not particular about using procfs mount for the FDs but
> > > >that's the only
> > > >> > > way I knew how to do it until you pointed out anon_inode (my grep
> > > >skills
> > > >> > > missed that), so thank you!
> > > >> > >
> > > >> > > > > C'mon: /proc is used by everyone today and almost every
> > > >program breaks
> > > >> > > > > if it's not around. The string "/proc" is already de facto
> > > >kernel ABI.
> > > >> > > > > Let's just drop the pretense of /proc being optional and bake
> > > >it into
> > > >> > > > > the kernel proper, then give programs a way to get to /proc
> > > >that isn't
> > > >> > > > > tied to any particular mount configuration. This way, we
> > > >don't need a
> > > >> > > > > translate_pid(), since callers can just use procfs to do the
> > > >same
> > > >> > > > > thing. (That is, if I understand correctly what translate_pid
> > > >does.)
> > > >> > > >
> > > >> > > > I'm not sure what you think translate_pid() is doing since
> > > >you're not
> > > >> > > > saying what you think it does.
> > > >> > > > Examples from the old patchset:
> > > >> > > > translate_pid(pid, ns, -1)      - get pid in our pid namespace
> > > >> >
> > > >> > Ah, it's a bit different from what I had in mind. It's fair to want
> > > >to
> > > >> > translate PIDs between namespaces, but the only way to make the
> > > >> > translate_pid under discussion robust is to have it accept and
> > > >produce
> > > >> > pidfds. (At that point, you might as well call it translate_pidfd.)
> > > >We
> > > >> > should not be adding new APIs to the kernel that accept numeric
> > > >PIDs:
> > > >>
> > > >> The traditional pid-based api is not going away. There are users that
> > > >> have the requirement to translate pids between namespaces and also
> > > >doing
> > > >> introspection on these namespaces independent of pidfds. We will not
> > > >> restrict the usefulness of this syscall by making it only work with
> > > >> pidfds.
> > > >>
> > > >> > it's not possible to use these APIs correctly except under very
> > > >> > limited circumstances --- mostly, talking about init or a parent
> > > >>
> > > >> The pid-based api is one of the most widely used apis of the kernel
> > > >and
> > > >> people have been using it quite successfully for a long time. Yes,
> > > >it's
> > > >> rac, but it's here to stay.
> > > >>
> > > >> > talking about its child.
> > > >> >
> > > >> > Really, we need a few related operations, and we shouldn't
> > > >necessarily
> > > >> > mingle them.
> > > >>
> > > >> Yes, we've established that previously.
> > > >>
> > > >> >
> > > >> > 1) Given a numeric PID, give me a pidfd: that works today: you just
> > > >> > open /proc/<pid>
> > > >>
> > > >> Agreed.
> > > >>
> > > >> >
> > > >> > 2) Given a pidfd, give me a numeric PID: that works today: you just
> > > >> > openat(pidfd, "stat", O_RDONLY) and read the first token (which is
> > > >> > always the numeric PID).
> > > >>
> > > >> Agreed.
> > > >>
> > > >> >
> > > >> > 3) Given a pidfd, send a signal: that's what pidfd_send_signal
> > > >does,
> > > >> > and it's a good start on the rest of these operations.
> > > >>
> > > >> Agreed.
> > > >>
> > > >> > 5) Given a pidfd in NS1, get a pidfd in NS2. That's what
> > > >translate_pid
> > > >> > is for. My preferred signature for this routine is
> > > >translate_pid(int
> > > >> > pidfd, int nsfd) -> pidfd. We don't need two namespace arguments.
> > > >Why
> > > >> > not? Because the pidfd *already* names a single process, uniquely!
> > > >>
> > > >> Given that people are interested in pids we can't just always return
> > > >a
> > > >> pidfd. That would mean a user would need to do get the pidfd read
> > > >from
> > > >> <pidfd>/stat and then close the pidfd. If you do that for a 100 pids
> > > >or
> > > >> more you end up allocating and closing file descriptors constantly
> > > >for
> > > >> no reason. We can't just debate pids away. So it will also need to be
> > > >> able to yield pids e.g. through a flag argument.
> > > >
> > > >Sure, but that's still not a reason that we should care about pidfds
> > > >working separately from procfs..
> >
> > That's unrelated to the point made in the above paragraph.
> > Please note, I said that the pidfd api should work when proc is not
> > available not that they can't be dirfds.
> 
> What do you mean by "not available"? CONFIG_PROCFS=n? If pidfds

I'm talking about the ability to clone processes and get fd handles on
them via pidfd_clone() or CLONE_NEWFD.

> 
> > translate_pid() should just return you a pidfd. Having it return a pidfd
> > and a status fd feels like stuffing too much functionality in there. If
> > you're fine with it I'll finish prototyping what I had in mind. As I
> > said in previous mails I'm already working on this.
> 
> translate_pid also needs to *accept* pidfds, at least optionally.
> Unless you have a function from pidfd to pidfd, you race.

You're misunderstanding. Again, I said in my previous mails it should
accept pidfds optionally as arguments, yes. But I don't want it to
return the status fds that you previously wanted pidfd_wait() to return.
I really want to see Joel's pidfd_wait() patchset and have more people
review the actual code.

