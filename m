Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C48DEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:33:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68B462175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:33:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="mRAEamYd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68B462175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B5966B0003; Wed, 20 Mar 2019 07:33:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 163756B0006; Wed, 20 Mar 2019 07:33:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 079016B0007; Wed, 20 Mar 2019 07:33:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA5846B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:33:56 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d8so20461877qkk.17
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:33:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:user-agent:in-reply-to
         :references:mime-version:content-transfer-encoding:subject:to:cc
         :from:message-id;
        bh=d4Z5Mqmi4LJpbgIxofUDgn3+z5lt3XVSz/v98zM6dGA=;
        b=r2oGO9JWIKD0/TsEWw14VDiJTo+zidhlMnp9i05RRcBw3bdTFPZeEaSsyFgWeLVwiA
         Izywh/XLaN6KvebkpvqfXIUvoM9hAr79GaTq+hcoHOhJ4mjhkckbpX3D0D4lzcW+t1Fm
         /UBWrfL3jcwvK1Wjsbnq5M6W46iAVCnuHYFs5eevRhmeXtG7ALnjPK34vbtMr1bwxymC
         9ux79SEVcDCoRNN6xsWIFEwuzlhw7WFuCXseGza3w91qkAvBFXNeD1ZL3FT8qii7/NzP
         hTb/nEd4NE63rxXujOFsijA4s8ocLTINNWSlNMAcEulNeEP8uUCgD8I9bbRaCjc39DVC
         MWdA==
X-Gm-Message-State: APjAAAVaRAOQhoO9gQJVCmxy3l3MYXzncRdgSsmx0NcoxA4HWa7dnufl
	BE45hdAXXwOdBVy2yNbI0wYVrHk/pXfWYxs93ymbDB17WTf7SrtXpaBScb9fgPHIxIRKKo1NCNs
	Hc1GPpXn+YN+bEhS0a1xZ0g/K89CaudKViqW5d4+zyBb813ebzK4m5WN/viLoVcUwFg==
X-Received: by 2002:ac8:3390:: with SMTP id c16mr6419865qtb.172.1553081636526;
        Wed, 20 Mar 2019 04:33:56 -0700 (PDT)
X-Received: by 2002:ac8:3390:: with SMTP id c16mr6419798qtb.172.1553081635621;
        Wed, 20 Mar 2019 04:33:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553081635; cv=none;
        d=google.com; s=arc-20160816;
        b=izmUGZhTjKr/taqKzYHnJNW2Vy5sFLqa946NxWzzaNsxbF0B+EDoKC/e2qCgWv5yjB
         YkKjVjp8lo1dgs81O3VdvV5xbFWwaf0igRnwwQozrmzg+LRwJedVphtZWTmZk6Jsltt2
         9UPpSTTEtPylhXJN0BQvScNkriMCkSM+iTyZIR8+emgQieijskn7qMnXVSP9E17XffmY
         zM/8rFDfTTZpQX+D4vqIC4GhAiNtid9wsacPgccR9ASCcizsyLze4ee/KK3mLgdoewH0
         fdhf83QBmqvok02uJnNxM7aNfHXfsMQ32dZECszDDj0rYcX9QPAgHTAZKBwlP4K3weJN
         OM0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:from:cc:to:subject:content-transfer-encoding
         :mime-version:references:in-reply-to:user-agent:date:dkim-signature;
        bh=d4Z5Mqmi4LJpbgIxofUDgn3+z5lt3XVSz/v98zM6dGA=;
        b=P7ftKVSh33AeibCG0b9wSxRsh3eJ7Wk93Gk7gBoHKLYZ2mN4Th1yC4UU6kRXhyHdIX
         23R1eDTlXC+qnuzibAgcYud6tz85t/y1UU6sEUqUyi/ImQa31ca2Vf7VewCXcEb1Wl18
         sr7XpKPm27CWsgfEs2vDJAsUVCeGO9RUyMkaPtRqDQFvR3R46NuAUXXkY3ff1lUY8bzN
         qFDPpG5MwjXkWsHHHx/NiGStUFnY4TgOyXostYvwwuFQRs4RwGsPTgEMkepAhnhopWWA
         ievv8GTZbM3hw8gQt/ZqUIgsA5vXavnXKgCtcZj+hez6t51kwTxviayuIG/Nem6MFToy
         kx6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=mRAEamYd;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i31sor2086862qvc.47.2019.03.20.04.33.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 04:33:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=mRAEamYd;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:user-agent:in-reply-to:references:mime-version
         :content-transfer-encoding:subject:to:cc:from:message-id;
        bh=d4Z5Mqmi4LJpbgIxofUDgn3+z5lt3XVSz/v98zM6dGA=;
        b=mRAEamYdksjPsuTT3gCoilF0nl1WVeaMZxrp1TGoeVeQ2DV/jRTfE84LyIcdoznqET
         1JMcsEKSvlvTNUOo4WathfgwTJMeKT2I7E8FU4K5gKtP7VYRExdXFSSyLq4DyQo4J9+0
         AWCC6EAjjQKAtdovCCY6NFWpZHC98Dq7Nlu3o=
X-Google-Smtp-Source: APXvYqzkMfTtf1uGPNkRoUzX4rFJebsuzIDcrB0bSeB6XFbGSXfe+v9DxOGTZ1whbs3Rlygi+TBr6w==
X-Received: by 2002:a0c:9e9a:: with SMTP id r26mr6005557qvd.57.1553081635138;
        Wed, 20 Mar 2019 04:33:55 -0700 (PDT)
Received: from [192.168.0.109] (c-73-216-90-110.hsd1.va.comcast.net. [73.216.90.110])
        by smtp.gmail.com with ESMTPSA id 91sm912671qtf.62.2019.03.20.04.33.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 04:33:54 -0700 (PDT)
Date: Wed, 20 Mar 2019 07:33:51 -0400
User-Agent: K-9 Mail for Android
In-Reply-To: <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
References: <20190317015306.GA167393@google.com> <20190317114238.ab6tvvovpkpozld5@brauner.io> <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com> <20190318002949.mqknisgt7cmjmt7n@brauner.io> <20190318235052.GA65315@google.com> <20190319221415.baov7x6zoz7hvsno@brauner.io> <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com> <20190319231020.tdcttojlbmx57gke@brauner.io> <20190320015249.GC129907@google.com> <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com> <20190320035953.mnhax3vd47ya4zzm@brauner.io> <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: pidfd design
To: Daniel Colascione <dancol@google.com>,Christian Brauner <christian@brauner.io>
CC: Suren Baghdasaryan <surenb@google.com>,Steven Rostedt <rostedt@goodmis.org>,Sultan Alsawaf <sultan@kerneltoast.com>,Tim Murray <timmurray@google.com>,Michal Hocko <mhocko@kernel.org>,Greg Kroah-Hartman <gregkh@linuxfoundation.org>,=?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve@android.com>,Todd Kjos <tkjos@android.com>,Martijn Coenen <maco@android.com>,Ingo Molnar <mingo@redhat.com>,Peter Zijlstra <peterz@infradead.org>,LKML <linux-kernel@vger.kernel.org>,"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,linux-mm <linux-mm@kvack.org>,kernel-team <kernel-team@android.com>,Oleg Nesterov <oleg@redhat.com>,Andy Lutomirski <luto@amacapital.net>,"Serge E. Hallyn" <serge@hallyn.com>,Kees Cook <keescook@chromium.org>
From: Joel Fernandes <joel@joelfernandes.org>
Message-ID: <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On March 20, 2019 3:02:32 AM EDT, Daniel Colascione <dancol@google=2Ecom> =
wrote:
>On Tue, Mar 19, 2019 at 8:59 PM Christian Brauner
><christian@brauner=2Eio> wrote:
>>
>> On Tue, Mar 19, 2019 at 07:42:52PM -0700, Daniel Colascione wrote:
>> > On Tue, Mar 19, 2019 at 6:52 PM Joel Fernandes
><joel@joelfernandes=2Eorg> wrote:
>> > >
>> > > On Wed, Mar 20, 2019 at 12:10:23AM +0100, Christian Brauner
>wrote:
>> > > > On Tue, Mar 19, 2019 at 03:48:32PM -0700, Daniel Colascione
>wrote:
>> > > > > On Tue, Mar 19, 2019 at 3:14 PM Christian Brauner
><christian@brauner=2Eio> wrote:
>> > > > > > So I dislike the idea of allocating new inodes from the
>procfs super
>> > > > > > block=2E I would like to avoid pinning the whole pidfd
>concept exclusively
>> > > > > > to proc=2E The idea is that the pidfd API will be useable
>through procfs
>> > > > > > via open("/proc/<pid>") because that is what users expect
>and really
>> > > > > > wanted to have for a long time=2E So it makes sense to have
>this working=2E
>> > > > > > But it should really be useable without it=2E That's why
>translate_pid()
>> > > > > > and pidfd_clone() are on the table=2E  What I'm saying is,
>once the pidfd
>> > > > > > api is "complete" you should be able to set CONFIG_PROCFS=3DN
>- even
>> > > > > > though that's crazy - and still be able to use pidfds=2E This
>is also a
>> > > > > > point akpm asked about when I did the pidfd_send_signal
>work=2E
>> > > > >
>> > > > > I agree that you shouldn't need CONFIG_PROCFS=3DY to use
>pidfds=2E One
>> > > > > crazy idea that I was discussing with Joel the other day is
>to just
>> > > > > make CONFIG_PROCFS=3DY mandatory and provide a new
>get_procfs_root()
>> > > > > system call that returned, out of thin air and independent of
>the
>> > > > > mount table, a procfs root directory file descriptor for the
>caller's
>> > > > > PID namspace and suitable for use with openat(2)=2E
>> > > >
>> > > > Even if this works I'm pretty sure that Al and a lot of others
>will not
>> > > > be happy about this=2E A syscall to get an fd to /proc?
>> >
>> > Why not? procfs provides access to a lot of core kernel
>functionality=2E
>> > Why should you need a mountpoint to get to it?
>> >
>> > > That's not going
>> > > > to happen and I don't see the need for a separate syscall just
>for that=2E
>> >
>> > We need a system call for the same reason we need a getrandom(2):
>you
>> > have to bootstrap somehow when you're in a minimal environment=2E
>> >
>> > > > (I do see the point of making CONFIG_PROCFS=3Dy the default btw=
=2E)
>> >
>> > I'm not proposing that we make CONFIG_PROCFS=3Dy the default=2E I'm
>> > proposing that we *hardwire* it as the default and just declare
>that
>> > it's not possible to build a Linux kernel that doesn't include
>procfs=2E
>> > Why do we even have that button?
>> >
>> > > I think his point here was that he wanted a handle to procfs no
>matter where
>> > > it was mounted and then can later use openat on that=2E Agreed that
>it may be
>> > > unnecessary unless there is a usecase for it, and especially if
>the /proc
>> > > directory being the defacto mountpoint for procfs is a universal
>convention=2E
>> >
>> > If it's a universal convention and, in practice, everyone needs
>proc
>> > mounted anyway, so what's the harm in hardwiring CONFIG_PROCFS=3Dy?
>If
>> > we advertise /proc as not merely some kind of optional debug
>interface
>> > but *the* way certain kernel features are exposed --- and there's
>> > nothing wrong with that --- then we should give programs access to
>> > these core kernel features in a way that doesn't depend on
>userspace
>> > kernel configuration, and you do that by either providing a
>> > procfs-root-getting system call or just hardwiring the "/proc/"
>prefix
>> > into VFS=2E
>> >
>> > > > Inode allocation from the procfs mount for the file descriptors
>Joel
>> > > > wants is not correct=2E Their not really procfs file descriptors
>so this
>> > > > is a nack=2E We can't just hook into proc that way=2E
>> > >
>> > > I was not particular about using procfs mount for the FDs but
>that's the only
>> > > way I knew how to do it until you pointed out anon_inode (my grep
>skills
>> > > missed that), so thank you!
>> > >
>> > > > > C'mon: /proc is used by everyone today and almost every
>program breaks
>> > > > > if it's not around=2E The string "/proc" is already de facto
>kernel ABI=2E
>> > > > > Let's just drop the pretense of /proc being optional and bake
>it into
>> > > > > the kernel proper, then give programs a way to get to /proc
>that isn't
>> > > > > tied to any particular mount configuration=2E This way, we
>don't need a
>> > > > > translate_pid(), since callers can just use procfs to do the
>same
>> > > > > thing=2E (That is, if I understand correctly what translate_pid
>does=2E)
>> > > >
>> > > > I'm not sure what you think translate_pid() is doing since
>you're not
>> > > > saying what you think it does=2E
>> > > > Examples from the old patchset:
>> > > > translate_pid(pid, ns, -1)      - get pid in our pid namespace
>> >
>> > Ah, it's a bit different from what I had in mind=2E It's fair to want
>to
>> > translate PIDs between namespaces, but the only way to make the
>> > translate_pid under discussion robust is to have it accept and
>produce
>> > pidfds=2E (At that point, you might as well call it translate_pidfd=
=2E)
>We
>> > should not be adding new APIs to the kernel that accept numeric
>PIDs:
>>
>> The traditional pid-based api is not going away=2E There are users that
>> have the requirement to translate pids between namespaces and also
>doing
>> introspection on these namespaces independent of pidfds=2E We will not
>> restrict the usefulness of this syscall by making it only work with
>> pidfds=2E
>>
>> > it's not possible to use these APIs correctly except under very
>> > limited circumstances --- mostly, talking about init or a parent
>>
>> The pid-based api is one of the most widely used apis of the kernel
>and
>> people have been using it quite successfully for a long time=2E Yes,
>it's
>> rac, but it's here to stay=2E
>>
>> > talking about its child=2E
>> >
>> > Really, we need a few related operations, and we shouldn't
>necessarily
>> > mingle them=2E
>>
>> Yes, we've established that previously=2E
>>
>> >
>> > 1) Given a numeric PID, give me a pidfd: that works today: you just
>> > open /proc/<pid>
>>
>> Agreed=2E
>>
>> >
>> > 2) Given a pidfd, give me a numeric PID: that works today: you just
>> > openat(pidfd, "stat", O_RDONLY) and read the first token (which is
>> > always the numeric PID)=2E
>>
>> Agreed=2E
>>
>> >
>> > 3) Given a pidfd, send a signal: that's what pidfd_send_signal
>does,
>> > and it's a good start on the rest of these operations=2E
>>
>> Agreed=2E
>>
>> > 5) Given a pidfd in NS1, get a pidfd in NS2=2E That's what
>translate_pid
>> > is for=2E My preferred signature for this routine is
>translate_pid(int
>> > pidfd, int nsfd) -> pidfd=2E We don't need two namespace arguments=2E
>Why
>> > not? Because the pidfd *already* names a single process, uniquely!
>>
>> Given that people are interested in pids we can't just always return
>a
>> pidfd=2E That would mean a user would need to do get the pidfd read
>from
>> <pidfd>/stat and then close the pidfd=2E If you do that for a 100 pids
>or
>> more you end up allocating and closing file descriptors constantly
>for
>> no reason=2E We can't just debate pids away=2E So it will also need to =
be
>> able to yield pids e=2Eg=2E through a flag argument=2E
>
>Sure, but that's still not a reason that we should care about pidfds
>working separately from procfs=2E=2E

Agreed=2E I can't imagine pidfd being anything but a proc pid directory ha=
ndle=2E So I am confused what Christian meant=2E Pidfd *is* a procfs direct=
ory fid  always=2E That's what I gathered from his pidfd_send_signal patch =
but let me know if I'm way off in the woods=2E

For my next revision, I am thinking of adding the flag argument Christian =
mentioned to make translate_pid return an anon_inode FD which can be used f=
or death status, given a <pid>=2E Since it is thought that translate_pid ca=
n be made to return a pid FD, I think it is ok to have it return a pid stat=
us FD for the purposes of the death status as well=2E

Joel Fernandes, Android kernel team
Sent from k9-mail on Android

