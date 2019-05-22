Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D94F3C18E7C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 08:22:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EEB021019
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 08:22:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="KMEggWfK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EEB021019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12E3F6B0003; Wed, 22 May 2019 04:22:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DF9F6B0006; Wed, 22 May 2019 04:22:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEB2F6B0007; Wed, 22 May 2019 04:22:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 834576B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 04:22:53 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id v5so354496lfi.13
        for <linux-mm@kvack.org>; Wed, 22 May 2019 01:22:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=m4JEalCIglmSi8asd0GswElo01+07VAIE94yc//5CSY=;
        b=iCZ99yH63AfALbIiAb0T6aNQXKKt7JIXJ0E9JrrsQhjtL8rR+wSulD7b8c8ixXhtFC
         +Eke8UHWV1Ry4ObfV1daS38Uwfyi7Ak6hT9fOrHFgeGZhSZnJZHcH7HrMJm6XdwUlqDw
         0Bsil5Q0sxAftzceQuyPYtwvjb4t8XHvdXI87qiM1mXuZciWVYPBQoxOdwuZCU8RZaI9
         dFDe7cmQW9CmSUGe5MNBzz18Q0dVleZFJ7T1w3sT+u7b7l46+ORMCsqiRFAJdZQUhNSj
         fF3ZP+Wfn/AhTGsnushL621Tg8We4Sa/Kecc5cSPdyRwKvkyFumJ2n5upAmHxvbmi4BX
         C4CA==
X-Gm-Message-State: APjAAAUK02znVxDE2/WLNxM7bfO5fJXDwqv64da9OFlfBcsP9o0ZymNl
	RSG/uUgOlWzVPdRcFyA90kQuW3+oxlGadYM7FIqdlMkak9wd1IJhNAlz3sPs4jfvRuk5JEB7aTM
	eRls42JR3Wdv5gFMr2S/0i9qZidFGd8zjzgEgjIOZrjCXxIsaR6r91zNpi/hykDtR/A==
X-Received: by 2002:ac2:59c7:: with SMTP id x7mr5252990lfn.75.1558513372570;
        Wed, 22 May 2019 01:22:52 -0700 (PDT)
X-Received: by 2002:ac2:59c7:: with SMTP id x7mr5252923lfn.75.1558513371215;
        Wed, 22 May 2019 01:22:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558513371; cv=none;
        d=google.com; s=arc-20160816;
        b=NRiNmmXabM/D577UI99dX/J2ltxWCDmNwJ5PbnnfwXoylLC87REJsXzCCONw2Xvz+8
         xFW5VZYAPDfg71Ot0OxnuIpVrBWHe5hYoQisteASoXDdl/ep0XVL7c20tKg1RsilKcAt
         pLPB8tvHkTWmQ+8Q5EmvTMFrNmnj4qo19EHr5seieihwj8fJl6RMau5fIE/0eE2TAKy9
         RwEOujHA4M0HHf1zK7nf4ymFNpSat1jfb3UUh8AnqBDnjJv77c8blWn/O7I8e1PyXRjL
         LQMcUJhNzhJ+/d6MIOL7RAMOK0GFQ/ttYwGB/UpqxsGnd9m1ZdtEtY7X1wbScOH3hWM1
         G8VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=m4JEalCIglmSi8asd0GswElo01+07VAIE94yc//5CSY=;
        b=PdvXk27TXjbrlW6LeseJ1nx6YNoCNz1RcY8CrzwV+Pd03yqYpjZhiUiBK1Pw7FkWmq
         quYIRstB7JQ2Yf3bM+XAB52IFjlR5fXuC1h2rchXVmACFAJ+2Zxq5ftRR5Z4L6TQu68j
         7jlcESgdJOGbiU5CYXow95d8KHeCfzXPrvTcleAYrufsgwZM87NaSfG6zxS5GUbfLVY9
         fCgut3wAi61UfhHwUIWbkt0ExUnvwY9d5+dKJ6QZ8SO3nyfJC0M4Dp2KsQtZTrH7s6RH
         U5K5xhQujTJ+5efITLyWhPEmQVOHZZruF8RU1nXcEyketZgv/aifAz6lO4kPlAj83jx7
         w7+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=KMEggWfK;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h127sor6716946lfh.12.2019.05.22.01.22.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 01:22:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=KMEggWfK;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=m4JEalCIglmSi8asd0GswElo01+07VAIE94yc//5CSY=;
        b=KMEggWfKkR3sBMob8FbBK3AkPY0Qn4wLBU1yAM0kOqN5gKbp7l4OR3rxcZCe1Ov1Ye
         uED7haoNqzLbV39Qaj2z/pOqC3lVob2FBEWPQyBmcQJX1WVPrnZqCGBi//2l7ms8rLXv
         +0+tBjPhna2s7pUUqEpZfT71jdxWJ8iPP3fJhloXDk+nX0Ufjanfb3bbxhnJW/jGf07H
         3UWg0mYN+wHNOckgclt+Yj6aG3vssyp7F86XCh/IySq5+IYFBEJzZAQ6dVsQdei2r5EE
         mvEQPxdad4w3p93NQApykF9saCcvOzUKnpwqj3xC6v7ijNc3aJVs7zN9kuqnXuBzBxu1
         y5yw==
X-Google-Smtp-Source: APXvYqw9OPOwrmLIkGIU0Xy3co7TwRd7WwgYVENZTQrjpSNRDD9FLuWiCbXB17r/o1f6TgOoNhgJ68m6pD96JCSigLo=
X-Received: by 2002:ac2:5606:: with SMTP id v6mr5522539lfd.129.1558513370602;
 Wed, 22 May 2019 01:22:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190520035254.57579-1-minchan@kernel.org> <20190521084158.s5wwjgewexjzrsm6@brauner.io>
 <20190521110552.GG219653@google.com> <20190521113029.76iopljdicymghvq@brauner.io>
 <20190521113911.2rypoh7uniuri2bj@brauner.io> <CAKOZuesjDcD3EM4PS7aO7yTa3KZ=FEzMP63MR0aEph4iW1NCYQ@mail.gmail.com>
In-Reply-To: <CAKOZuesjDcD3EM4PS7aO7yTa3KZ=FEzMP63MR0aEph4iW1NCYQ@mail.gmail.com>
From: Christian Brauner <christian@brauner.io>
Date: Wed, 22 May 2019 10:22:39 +0200
Message-ID: <CAHrFyr6iuoZ-r6e57zp1rz7b=Ee0Vko+syuUKW2an+TkAEz_iA@mail.gmail.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Daniel Colascione <dancol@google.com>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 7:12 AM Daniel Colascione <dancol@google.com> wrote=
:
>
> On Tue, May 21, 2019 at 4:39 AM Christian Brauner <christian@brauner.io> =
wrote:
> >
> > On Tue, May 21, 2019 at 01:30:29PM +0200, Christian Brauner wrote:
> > > On Tue, May 21, 2019 at 08:05:52PM +0900, Minchan Kim wrote:
> > > > On Tue, May 21, 2019 at 10:42:00AM +0200, Christian Brauner wrote:
> > > > > On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> > > > > > - Background
> > > > > >
> > > > > > The Android terminology used for forking a new process and star=
ting an app
> > > > > > from scratch is a cold start, while resuming an existing app is=
 a hot start.
> > > > > > While we continually try to improve the performance of cold sta=
rts, hot
> > > > > > starts will always be significantly less power hungry as well a=
s faster so
> > > > > > we are trying to make hot start more likely than cold start.
> > > > > >
> > > > > > To increase hot start, Android userspace manages the order that=
 apps should
> > > > > > be killed in a process called ActivityManagerService. ActivityM=
anagerService
> > > > > > tracks every Android app or service that the user could be inte=
racting with
> > > > > > at any time and translates that into a ranked list for lmkd(low=
 memory
> > > > > > killer daemon). They are likely to be killed by lmkd if the sys=
tem has to
> > > > > > reclaim memory. In that sense they are similar to entries in an=
y other cache.
> > > > > > Those apps are kept alive for opportunistic performance improve=
ments but
> > > > > > those performance improvements will vary based on the memory re=
quirements of
> > > > > > individual workloads.
> > > > > >
> > > > > > - Problem
> > > > > >
> > > > > > Naturally, cached apps were dominant consumers of memory on the=
 system.
> > > > > > However, they were not significant consumers of swap even thoug=
h they are
> > > > > > good candidate for swap. Under investigation, swapping out only=
 begins
> > > > > > once the low zone watermark is hit and kswapd wakes up, but the=
 overall
> > > > > > allocation rate in the system might trip lmkd thresholds and ca=
use a cached
> > > > > > process to be killed(we measured performance swapping out vs. z=
apping the
> > > > > > memory by killing a process. Unsurprisingly, zapping is 10x tim=
es faster
> > > > > > even though we use zram which is much faster than real storage)=
 so kill
> > > > > > from lmkd will often satisfy the high zone watermark, resulting=
 in very
> > > > > > few pages actually being moved to swap.
> > > > > >
> > > > > > - Approach
> > > > > >
> > > > > > The approach we chose was to use a new interface to allow users=
pace to
> > > > > > proactively reclaim entire processes by leveraging platform inf=
ormation.
> > > > > > This allowed us to bypass the inaccuracy of the kernel=E2=80=99=
s LRUs for pages
> > > > > > that are known to be cold from userspace and to avoid races wit=
h lmkd
> > > > > > by reclaiming apps as soon as they entered the cached state. Ad=
ditionally,
> > > > > > it could provide many chances for platform to use much informat=
ion to
> > > > > > optimize memory efficiency.
> > > > > >
> > > > > > IMHO we should spell it out that this patchset complements MADV=
_WONTNEED
> > > > > > and MADV_FREE by adding non-destructive ways to gain some free =
memory
> > > > > > space. MADV_COLD is similar to MADV_WONTNEED in a way that it h=
ints the
> > > > > > kernel that memory region is not currently needed and should be=
 reclaimed
> > > > > > immediately; MADV_COOL is similar to MADV_FREE in a way that it=
 hints the
> > > > > > kernel that memory region is not currently needed and should be=
 reclaimed
> > > > > > when memory pressure rises.
> > > > > >
> > > > > > To achieve the goal, the patchset introduce two new options for=
 madvise.
> > > > > > One is MADV_COOL which will deactive activated pages and the ot=
her is
> > > > > > MADV_COLD which will reclaim private pages instantly. These new=
 options
> > > > > > complement MADV_DONTNEED and MADV_FREE by adding non-destructiv=
e ways to
> > > > > > gain some free memory space. MADV_COLD is similar to MADV_DONTN=
EED in a way
> > > > > > that it hints the kernel that memory region is not currently ne=
eded and
> > > > > > should be reclaimed immediately; MADV_COOL is similar to MADV_F=
REE in a way
> > > > > > that it hints the kernel that memory region is not currently ne=
eded and
> > > > > > should be reclaimed when memory pressure rises.
> > > > > >
> > > > > > This approach is similar in spirit to madvise(MADV_WONTNEED), b=
ut the
> > > > > > information required to make the reclaim decision is not known =
to the app.
> > > > > > Instead, it is known to a centralized userspace daemon, and tha=
t daemon
> > > > > > must be able to initiate reclaim on its own without any app inv=
olvement.
> > > > > > To solve the concern, this patch introduces new syscall -
> > > > > >
> > > > > >         struct pr_madvise_param {
> > > > > >                 int size;
> > > > > >                 const struct iovec *vec;
> > > > > >         }
> > > > > >
> > > > > >         int process_madvise(int pidfd, ssize_t nr_elem, int *be=
havior,
> > > > > >                                 struct pr_madvise_param *restul=
s,
> > > > > >                                 struct pr_madvise_param *ranges=
,
> > > > > >                                 unsigned long flags);
> > > > > >
> > > > > > The syscall get pidfd to give hints to external process and pro=
vides
> > > > > > pair of result/ranges vector arguments so that it could give se=
veral
> > > > > > hints to each address range all at once.
> > > > > >
> > > > > > I guess others have different ideas about the naming of syscall=
 and options
> > > > > > so feel free to suggest better naming.
> > > > >
> > > > > Yes, all new syscalls making use of pidfds should be named
> > > > > pidfd_<action>. So please make this pidfd_madvise.
> > > >
> > > > I don't have any particular preference but just wondering why pidfd=
 is
> > > > so special to have it as prefix of system call name.
> > >
> > > It's a whole new API to address processes. We already have
> > > clone(CLONE_PIDFD) and pidfd_send_signal() as you have seen since you
> > > exported pidfd_to_pid(). And we're going to have pidfd_open(). Your
> > > syscall works only with pidfds so it's tied to this api as well so it
> > > should follow the naming scheme. This also makes life easier for
> > > userspace and is consistent.
> >
> > This is at least my reasoning. I'm not going to make this a whole big
> > pedantic argument. If people have really strong feelings about not usin=
g
> > this prefix then fine. But if syscalls can be grouped together and have
> > consistent naming this is always a big plus.
>
> My hope has been that pidfd use becomes normalized enough that
> prefixing "pidfd_" to pidfd-accepting system calls becomes redundant.
> We write write(), not fd_write(), right? :-) pidfd_open() makes sense
> because the primary purpose of this system call is to operate on a
> pidfd, but I think process_madvise() is fine.

This madvise syscall just operates on pidfds. It would make sense to
name it process_madvise() if were to operate both on pid_t and int pidfd.
Giving specific names to system calls won't stop it from becoming
normalized. The fact that people built other system calls around it
is enough proof of that. :)
For userspace pidfd_madvise is nicer and it clearly expresses
that it only accepts pidfds.
So please, Minchan make it pidfd_madvise() in the next version. :)

Christian

