Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 922BDC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:11:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D57120850
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:11:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="Wo8Thlm5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D57120850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB9E66B0003; Wed, 20 Mar 2019 15:11:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C42386B0006; Wed, 20 Mar 2019 15:11:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE2D86B0007; Wed, 20 Mar 2019 15:11:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8202A6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:11:57 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id f89so3559940qtb.4
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 12:11:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=T3v6cngzSTNsn8JWqBXhJFmbZpKUUvu9y1fz3VFVogQ=;
        b=Vrvjb0Mgzc4MBELBdnzvpBVI4Xyv2UxFu2JiL0O6yceJlYT8ea+62Yqj+D+Z0zWGD4
         +AJHsnmyKvT0gkBPH/zQnucdJW7Rc4TzGMstTnMkVAO9ILgAdoEvJsS2nnOmXa95ghke
         PLJZWqNf1q/WmLml6BLrtI+TThy2ayi96yGUxlzF9tfMbo+0KOFX7E7CJQB6y7OHVkhE
         aiAb/n1eKpCC7Dq7rlCPxTrTjkcjU2roHi00AzFrgNYrjtDTTR3PkDcEWkiJoNmuMi3P
         OGKfDGNFoLnbesr4Nqwta3d0kuozqalAH+kPODaYGFdnIVENr2hOvizUNbCQ8YsR+I73
         8HNg==
X-Gm-Message-State: APjAAAVwQYNVVwORoWs7OkpZ9xfR9JJTj5hFe3L7goVYkPqwvUQqIXJi
	yUPyIWRwQXCE31PJt5BweALuyAn7PdbUyQo34orhAjVGHw+2icz70KolxzR4BeaFRHaeRs66j73
	x8txQ+hwnb9142KwPYJgjudPU1oD8uKs/JLJXC53tfUMu4o4Ebc6ZqxUzupPqn15BxA==
X-Received: by 2002:ac8:27a6:: with SMTP id w35mr8442665qtw.157.1553109117208;
        Wed, 20 Mar 2019 12:11:57 -0700 (PDT)
X-Received: by 2002:ac8:27a6:: with SMTP id w35mr8442591qtw.157.1553109116315;
        Wed, 20 Mar 2019 12:11:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553109116; cv=none;
        d=google.com; s=arc-20160816;
        b=QPN1dCeQqarczcTP0Q8LhblLqXfqPtLgcNb/D0KYB9PUObRvXJX7zcChs7E9MamzCD
         Vln7TquESbSE57wdvn5kMLjuTCMJm7gH1jkgDQjN5RxMP3g+g5yazr8dThfGjVOoaWjw
         qB3JhXBeg8nJTAPxYyBV4EV2MrkiYZhCX6P9l4KjoC9dkaLbEa8PxwFHVnqviDsQcViY
         uQSSepsUu6c19iTRbQCKo2IofaqPEpd5HHA8e3ddtf2H/nQ+MvEy56eDGX0654ueCK42
         B05YCd2AlzKWae0P+9HT0e2bTVy4DUfQq5g1vzoL0L9xKXI836x88oXe2FuFtXauB093
         9KPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=T3v6cngzSTNsn8JWqBXhJFmbZpKUUvu9y1fz3VFVogQ=;
        b=UTnS6BcjJqgpkTvbyZH7UzBVuFU697J8sfdTF6gj8SktfcgXNPix4ZVvXXjeHNXJb7
         wmyetnfAZsunSvyFHE3TUT3+99WTOndPNRS81X4Wmp7rYcEg9IoIswuknXDRoP/vUrSQ
         Ry+Bb2o0YASQSvS8fEnYFAt3ItFkabGanMRmIlhgrWyaeJhzDm0EdUEC96GXtZzQXZbd
         zB22DTU/NjFj+bzfei2lzO+vf3Wrz+ffn8JAhF6AoCFjOAB+2KQhSsD2InqRTHh00ULA
         b++ZsdKF5/MLgstAUitCLo2rQI5Wvw8oko0Cm4a2t+7+DEP9BRt45wVfsUdU7/ILqMU1
         Gb0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=Wo8Thlm5;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t29sor3620272qve.54.2019.03.20.12.11.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 12:11:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=Wo8Thlm5;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=T3v6cngzSTNsn8JWqBXhJFmbZpKUUvu9y1fz3VFVogQ=;
        b=Wo8Thlm5mkrPj7z6qHCnFi5t+y9+HMHs9kz02t7qC6kxehEb3BoMtYkvoSqroRlynd
         QPTbpy2BNI8ptMcfoRheWqMORJgB5DkD/ivJvrBkaWDSHv6PpP9b/eX+06tUOv3hh/Qb
         SbWedVPzqat04VYk94AmVRYP1FZ53s3H6v0eQ=
X-Google-Smtp-Source: APXvYqyTvqIVIfV8hefD5S6kSyaYCWdHgJQSVwkpzU6dQZyKbKYCvAgY7rPviENuxxezlWk4GjZKJg==
X-Received: by 2002:a0c:c784:: with SMTP id k4mr8044586qvj.90.1553109115827;
        Wed, 20 Mar 2019 12:11:55 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id t73sm1992691qki.49.2019.03.20.12.11.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 12:11:54 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:11:53 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Christian Brauner <christian@brauner.io>
Cc: Daniel Colascione <dancol@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
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
Message-ID: <20190320191153.GA76715@google.com>
References: <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io>
 <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org>
 <20190320182649.spryp5uaeiaxijum@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320182649.spryp5uaeiaxijum@brauner.io>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 07:26:50PM +0100, Christian Brauner wrote:
> On Wed, Mar 20, 2019 at 07:33:51AM -0400, Joel Fernandes wrote:
> > 
> > 
> > On March 20, 2019 3:02:32 AM EDT, Daniel Colascione <dancol@google.com> wrote:
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
> > >> > > > > > api is "complete" you should be able to set CONFIG_PROCFS=N
> > >- even
> > >> > > > > > though that's crazy - and still be able to use pidfds. This
> > >is also a
> > >> > > > > > point akpm asked about when I did the pidfd_send_signal
> > >work.
> > >> > > > >
> > >> > > > > I agree that you shouldn't need CONFIG_PROCFS=Y to use
> > >pidfds. One
> > >> > > > > crazy idea that I was discussing with Joel the other day is
> > >to just
> > >> > > > > make CONFIG_PROCFS=Y mandatory and provide a new
> > >get_procfs_root()
> > >> > > > > system call that returned, out of thin air and independent of
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
> > >> > > > (I do see the point of making CONFIG_PROCFS=y the default btw.)
> > >> >
> > >> > I'm not proposing that we make CONFIG_PROCFS=y the default. I'm
> > >> > proposing that we *hardwire* it as the default and just declare
> > >that
> > >> > it's not possible to build a Linux kernel that doesn't include
> > >procfs.
> > >> > Why do we even have that button?
> > >> >
> > >> > > I think his point here was that he wanted a handle to procfs no
> > >matter where
> > >> > > it was mounted and then can later use openat on that. Agreed that
> > >it may be
> > >> > > unnecessary unless there is a usecase for it, and especially if
> > >the /proc
> > >> > > directory being the defacto mountpoint for procfs is a universal
> > >convention.
> > >> >
> > >> > If it's a universal convention and, in practice, everyone needs
> > >proc
> > >> > mounted anyway, so what's the harm in hardwiring CONFIG_PROCFS=y?
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
> > >> > > > Inode allocation from the procfs mount for the file descriptors
> > >Joel
> > >> > > > wants is not correct. Their not really procfs file descriptors
> > >so this
> > >> > > > is a nack. We can't just hook into proc that way.
> > >> > >
> > >> > > I was not particular about using procfs mount for the FDs but
> > >that's the only
> > >> > > way I knew how to do it until you pointed out anon_inode (my grep
> > >skills
> > >> > > missed that), so thank you!
> > >> > >
> > >> > > > > C'mon: /proc is used by everyone today and almost every
> > >program breaks
> > >> > > > > if it's not around. The string "/proc" is already de facto
> > >kernel ABI.
> > >> > > > > Let's just drop the pretense of /proc being optional and bake
> > >it into
> > >> > > > > the kernel proper, then give programs a way to get to /proc
> > >that isn't
> > >> > > > > tied to any particular mount configuration. This way, we
> > >don't need a
> > >> > > > > translate_pid(), since callers can just use procfs to do the
> > >same
> > >> > > > > thing. (That is, if I understand correctly what translate_pid
> > >does.)
> > >> > > >
> > >> > > > I'm not sure what you think translate_pid() is doing since
> > >you're not
> > >> > > > saying what you think it does.
> > >> > > > Examples from the old patchset:
> > >> > > > translate_pid(pid, ns, -1)      - get pid in our pid namespace
> > >> >
> > >> > Ah, it's a bit different from what I had in mind. It's fair to want
> > >to
> > >> > translate PIDs between namespaces, but the only way to make the
> > >> > translate_pid under discussion robust is to have it accept and
> > >produce
> > >> > pidfds. (At that point, you might as well call it translate_pidfd.)
> > >We
> > >> > should not be adding new APIs to the kernel that accept numeric
> > >PIDs:
> > >>
> > >> The traditional pid-based api is not going away. There are users that
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
> > >> > 1) Given a numeric PID, give me a pidfd: that works today: you just
> > >> > open /proc/<pid>
> > >>
> > >> Agreed.
> > >>
> > >> >
> > >> > 2) Given a pidfd, give me a numeric PID: that works today: you just
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
> > >> no reason. We can't just debate pids away. So it will also need to be
> > >> able to yield pids e.g. through a flag argument.
> > >
> > >Sure, but that's still not a reason that we should care about pidfds
> > >working separately from procfs..
> 
> That's unrelated to the point made in the above paragraph.
> Please note, I said that the pidfd api should work when proc is not
> available not that they can't be dirfds.
> 
> > 
> > Agreed. I can't imagine pidfd being anything but a proc pid directory handle. So I am confused what Christian meant. Pidfd *is* a procfs directory fid  always. That's what I gathered from his pidfd_send_signal patch but let me know if I'm way off in the woods.
> 
> (K9 Mail still hasn't learned to wrap lines at 80 it seems. :))

Indeed, or I misconfigured it :) Just set it up recently so I'm still messing
with it.

The other issue is it does wrapping on quoted lines too, and there's a bug
filed somewhere for that.

> Again, I never said that pidfds should be a directory handle.
> (Though I would like to point out that one of the original ideas I
> discussed at LPC was to have something like this to get regular file
> descriptors instead of dirfds:
> https://gist.github.com/brauner/59eec91550c5624c9999eaebd95a70df)

Ok. I was just going by this code in your send_signal patch where you error
out if the pidfd is not a directory.
 
+struct pid *tgid_pidfd_to_pid(const struct file *file)
+{
+	if (!d_is_dir(file->f_path.dentry) ||
+	    (file->f_op != &proc_tgid_base_operations))
+		return ERR_PTR(-EBADF);

> > For my next revision, I am thinking of adding the flag argument Christian mentioned to make translate_pid return an anon_inode FD which can be used for death status, given a <pid>. Since it is thought that translate_pid can be made to return a pid FD, I think it is ok to have it return a pid status FD for the purposes of the death status as well.
> 
> translate_pid() should just return you a pidfd. Having it return a pidfd
> and a status fd feels like stuffing too much functionality in there. If
> you're fine with it I'll finish prototyping what I had in mind. As I
> said in previous mails I'm already working on this.

Yes, please continue to work on it. No problem.

> Would you be ok with prototyping the pidfd_wait() syscall you had in
> mind?

Yes, Of course, I am working on it. No problem. It is still good to discuss
these ideas and to know what my direction should be, so I appreciate the
conversation here.

> Especially the wait_fd part that you want to have I would like to
> see how that is supposed to work, e.g. who is allowed to wait on the
> process and how notifications will work for non-parent processes and so
> on. I feel we won't get anywhere by talking in the abstrace and other
> people are far more likely to review/comment once there's actual code.

Got it. Lets chat more once I post something.

thanks,

 - Joel

