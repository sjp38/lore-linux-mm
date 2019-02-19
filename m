Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C175C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:35:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEC5221900
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:35:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="B6KS//TJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEC5221900
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DE3F8E0002; Mon, 18 Feb 2019 22:35:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68DB28E0003; Mon, 18 Feb 2019 22:35:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55DD28E0002; Mon, 18 Feb 2019 22:35:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1D48E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 22:35:19 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id e25so16905893otp.0
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 19:35:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=jJIO6ipBnRf7waV81bq0g+qJLPR9ysxJNKdrTgFNYtw=;
        b=cfqdKcAKxpkIhyyeSIzzN6B2MnwCDbJuZWSZfTXEeIKNnmPeptm1RmOShv1JYQECMl
         hu/rMFqdgrX/KtZgMGaMM+MI7oHnqwFFJKWCz7dBXKs+6aC9sRJfX36YXg4z3qLTbDfu
         qLT1Jt7+TWnnunjKgrGja2F8QQhvhSxjc3T06+qPlhQ/ZvgkiZSsxSGdG8c+JlZap1+W
         h7CjWev4uag6Znfq2dMdhW9Xdm99yvNMGdD6+PSh8ZXCBD9usIyXJRBqiuSZIKFeHcdl
         JAt9bYltn699qfYruHlj/mBav+DwU0VPuEW7zcYgLjtOKr3EQF/EhJQ+/hJgRw4rj72f
         rDoQ==
X-Gm-Message-State: AHQUAuauDQ9PsqS3585Yw8XwMEn0DEXw5/Ga5D1V5IvLciLGCkhoSBTf
	7jU5qhvpViFZvkCLMCZ6x6q2/pQwk3chO56vtQKzUw4p4NiAGZguuTknXWWF7jv6fOj5mP0fobz
	ENB2yFjQgr2i/IZqUKADC8hqpudxjtnA4oGlekTDkZZcnCV3WVugLGPCCPfMX3x/vK8THAcIasr
	WB6hQMNcGgJEXeAHbnXdnR5pOF6jlxVi2xWxDeD9kedLsWcjYrYoA4UWN8hSOdT4+7jDQEMOCwS
	+uz/jVE4Y1APsGI5wwAce9wGBbmalU9ZqD+9+xItm1sED52tkeqFZc8xHKqinO0LMQ4TOf1Y1w7
	IwcOjaoGg46omCBgZLyJDRLBlmHHvxB4aiO7fGTgLObehvZZuityTBNk8zz/RSTXIS+KLIvyw5s
	f
X-Received: by 2002:a9d:4595:: with SMTP id x21mr16548741ote.234.1550547318809;
        Mon, 18 Feb 2019 19:35:18 -0800 (PST)
X-Received: by 2002:a9d:4595:: with SMTP id x21mr16548709ote.234.1550547317861;
        Mon, 18 Feb 2019 19:35:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550547317; cv=none;
        d=google.com; s=arc-20160816;
        b=einRxwfcKuCT3Qju/0LqDYHFQ2tHA8v+lTivWr0vujW2yaOeg6k6b6zbjg4/JGWlN2
         Sytp7tsQs5fzyX5MRgUpC7xM0w0qkqzb/xUTLeWbHUwBvR7RrYnlXEaq5dCPfBZUBVj5
         R7drhCh4zsFL+wBhQzvpJD6jwAOT0pTz1lJqJ/1cAVxQpuOlG0HPJh/1Uvg6J41FT4qf
         2Ge6PYGebVAUnZDAHqYq+g567EjrhgUXdWDs0lnTuSry421jG3yKGxK285X8/2lfuMMO
         V8Mz9PjZPbavMlvQPwrEu3VT/otkMNNoiFQKTz3qm2ZH2OYXHqGNWfTlCflcris6tI9v
         gMhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=jJIO6ipBnRf7waV81bq0g+qJLPR9ysxJNKdrTgFNYtw=;
        b=wGAR4lWL+VaxExPB4PGIr5NB7s9k3SWFNBvfQNgKUNBZWsodwU8yf7qkVnsyvfOAIw
         er79OMZ7stCKxYStzMV5wPyRxji3nhx33Pqmk8kDDStsIE/9/54h4XoTUjqt9mTHld20
         2gAZbAt3a6SmHZesgva9A+hoIBHNg+i8ZckCIgGhybNB+r0j9Af7RYagGr2C+tzj5lNB
         L0y4ZWGk24ONVFpcrHKNMkzAPNTwEfU+t5Qpbmqj4ZSt8jHGfwB9ybMAa77TC57Qn5si
         9nvZPs31C8gtOO362FoDXiZK0kqn4WPH9KKpkQ9ldHpXEPkF84YOagV5bGqHsFs1E9/O
         cuAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="B6KS//TJ";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h23sor7951704oih.156.2019.02.18.19.35.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 19:35:17 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="B6KS//TJ";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=jJIO6ipBnRf7waV81bq0g+qJLPR9ysxJNKdrTgFNYtw=;
        b=B6KS//TJwDmwuEw0K4e/k3E2q7t7VSY1zByvf0YGmx88CU5vsP6UQ9tbEIJgpQszrV
         23N+LgLbOd4yEQ2SX2iSwT4Z77yRnoEUIcHF+fgTM+iMDbrvL8Q6WgAR+gvOmbTigin5
         u9oWAy/55QGYBwDSbt3qzx+n/mXrywUFN12gYEd0RcosSahAHbkd/GwEIUuz3689vif0
         t+aYWCjwSt0SnkSQ//nPn3X48MdL2HX7f5TgxmygWJ7najfICtAoZ/zQJNU9/FtzIOz6
         Qwkvluky9N6QXT5M9WtDzKGabq3dkNEMj53uHqhIpyNbRgwAK8UrREJbEeaHXhK9P7m3
         +2FA==
X-Google-Smtp-Source: AHgI3IZJpWGb5zOx79xPQtdpGb4coWlX3oA5sEu1ukMlZ3VOG+XteTdr7nLYNWY5n15dC6McUOXWVA==
X-Received: by 2002:aca:a847:: with SMTP id r68mr1247233oie.175.1550547317092;
        Mon, 18 Feb 2019 19:35:17 -0800 (PST)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id 30sm7236581ots.52.2019.02.18.19.35.15
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Feb 2019 19:35:16 -0800 (PST)
Date: Mon, 18 Feb 2019 19:35:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Adam Borowski <kilobyte@angband.pl>
cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, 
    Hugh Dickins <hughd@google.com>, Marcin Slusarz <marcin.slusarz@intel.com>
Subject: Re: tmpfs fails fallocate(more than DRAM)
In-Reply-To: <20190218202534.btgdyr5p3rxoqot7@angband.pl>
Message-ID: <alpine.LSU.2.11.1902181745010.1241@eggly.anvils>
References: <20190218133423.tdzawczn4yjdzjqf@angband.pl> <20190218202534.btgdyr5p3rxoqot7@angband.pl>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-716188691-1550547315=:1241"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-716188691-1550547315=:1241
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 18 Feb 2019, Adam Borowski wrote:

> Hi Hugh, it turns out this problem is caused by your commit
> 1aac1400319d30786f32b9290e9cc923937b3d57:

Yes, part of the series which first enabled fallocate() on tmpfs.
You probably read most of them already, but if not, please do read
through those v3.5 commit comments on

e2d12e22c59c tmpfs: support fallocate preallocation
1635f6a74152 tmpfs: undo fallocation on failure
1aac1400319d tmpfs: quit when fallocate fills memory

where I said more about the awkward compromises made
than I would be able to bring back to mind today.

>=20
> On Mon, Feb 18, 2019 at 02:34:23PM +0100, Adam Borowski wrote:
> > There's something that looks like a bug in tmpfs' implementation of
> > fallocate.  If you try to fallocate more than the available DRAM (yet
> > with plenty of swap space), it will evict everything swappable out
> > then fail, undoing all the work done so far first.
> >=20
> > The returned error is ENOMEM rather than POSIX mandated ENOSPC (for
> > posix_allocate(), but our documentation doesn't mention ENOMEM for
> > Linux-specific fallocate() either).

I can't speak for UNIX and its other relations, but it's well established
on Linux that the absence of a listed errno from the POSIX manpage or our
own manpage is no guarantee that that errno will not be returned by the
system call in question.  Those lists are really helpful for documenting
a variety of special meanings, but don't expect them to cover everything.

(Though I see that I was relieved to find EINTR given in the manpage.)

And as Matthew already said, ENOMEM is one that can very easily come back
from many system calls.  Though I disagree that it's wrong here: ENOSPC
is the errno you get when your fallocate() reaches the block limit (if
any) of the filesystem, ENOMEM is one you may hit earlier if it's unable
to complete the fallocate() successfully with the memory currently
available.

Fallocate is not the only place where tmpfs has to make that distinction:
ENOSPC for the filesystem constraint, ENOMEM for running out of memory
(itself ambiguous: physical memory available? swap included? memcg limit?
memory overcommit limitation?).

> >=20
> > Doing the same allocation in multiple calls -- be it via non-overlappin=
g
> > calls or even with same offset but increasing len -- works as expected.

Its indeterminacy is the worst thing about it, I think. I suppose that
procedure will often work, because of each attempt pushing more out to
swap.  But I certainly agree that it's all an unsatisfactory compromise.

As I remark in one of those commit messages, I very much wish that
fallocate(2) had been defined to return a positive count on success,
to allow for partial success like write(2); but too late to change by
the time I came along.

>=20
> I don't quite understand your logic there -- it seems to be done on purpo=
se?
>=20
> #   tmpfs: quit when fallocate fills memory
> #  =20
> #   As it stands, a large fallocate() on tmpfs is liable to fill memory w=
ith
> #   pages, freed on failure except when they run into swap, at which poin=
t
> #   they become fixed into the file despite the failure.  That feels quit=
e
> #   wrong, to be consuming resources precisely when they're in short supp=
ly.
>=20
> The page cache is just a cache, and thus running out of DRAM is in no way=
 a
> failure (as long as there's enough underlying storage).  Like any other
> filesystem, once DRAM is full, tmpfs is supposed to start writeout.  A sm=
art
> filesystem can mark zero pages as SWAP_MAP_FALLOC to avoid physically
> writing them out but doing so the naive hard way is at least correct.

I suggest below that we have different perceptions of tmpfs:
I see it as a RAM-based filesystem, with swap overflow; you see it
as a swap-based filesystem, caching in RAM.  I think that if it were
the latter, we'd have spent a lot more time designing its swap layout.

>    =20
> #   Go the other way instead: shmem_fallocate() indicate the range it has
> #   fallocated to shmem_writepage(), keeping count of pages it's allocati=
ng;
> #   shmem_writepage() reactivate instead of swapping out pages fallocated=
 by
> #   this syscall (but happily swap out those from earlier occasions), kee=
ping
> #   count; shmem_fallocate() compare counts and give up once the reactiva=
ted
> #   pages have started to coming back to writepage (approximately: some z=
ones
> #   would in fact recycle faster than others).
>=20
> It's a weird inconsistency: why should space allocated in a previous call
> act any different from that we allocate right now?

"weird" I'll agree with (and you're not the first person to use the word
"weird" of tmpfs in the last week!) but "inconsistency", in that context,
no.  Space allocated in a previous call has been guaranteed to the caller,
and that guarantee is a likely to be what they wanted fallocate() for in
the first place.  Space allocated right now, before we return success or
failure from the system call, is still revocable.

>    =20
> #   This is a little unusual, but works well: although we could consider =
the
> #   failure to swap as a bug, and fix it later with SWAP_MAP_FALLOC handl=
ing
> #   added in swapfile.c and memcontrol.c, I doubt that we shall ever want=
 to.
>=20
> It breaks use of tmpfs as a regular filesystem.  In particular, you don't
> know that a program someone uses won't try to create a big file.  For
> example, Debian buildds (where I first hit this problem) have setups such
> as:
> < jcristau> kilobyte: fwiw x86-csail-01.d.o has 75g /srv/buildd tmpfs, 8g=
 ram, 89g swap
>=20
> Using tmpfs this way is reasonable: traditional filesystems spend a lot o=
f
> effort to ensure crash consistency, and even if you disable journaling an=
d
> barriers, they will pointlessly write out the files.  Most builds can
> succeed in far less than 8GB, not touching the disk even once.

Yes, unsatisfactory: I tried for the best compromise I could imagine.
fallocate() on tmpfs remains useful in most circumstances, but with
this peculiar failure mode once going beyond RAM and well into swap.

With that 8G/89G split, I think you perceive tmpfs as a swap-based
filesystem, whereas I perceive it as a RAM-based filesystem which uses
swap for overflow; so made compromises appropriate to that view.

>=20
> [...]
>=20
> > This raises multiple questions:
> > * why would fallocate bother to prefault the memory instead of just
> >   reserving it?  We want to kill overcommit, but reserving swap is as g=
ood
> >   -- if there's memory pressure, our big allocation will be evicted any=
way.

The only way I know of to reserve memory, respecting all the different
limiting mechanisms imposed (memcg limits, filesystem limits, zone
watermarks, ...), is to allocate it (not sure what you mean by prefault).
hugetlbfs does have a reservation system, and its very own pool of memory,
but that's not tmpfs.

>=20
> I see that this particular feature is not coded yet for swap.

I expect you're right, but I don't see what you're referring to there:
ah, probably the SWAP_MAP_FALLOC mentioned above, from a comment in
shmem_writepage().  Yes, not implemented: it would handle a rare case
more efficiently, but I don't think it would change the fundamentals
at all.  Or maybe it's too long since I thought through this area,
and it really would make a real difference - dunno.

>=20
> > * why does it insist on doing everything in one piece?  Biggest chunk I
> >   see to be beneficial is 1G (for hugepages).

It insists on attempting to do what you ask: if you ask for one big piece,
that's what it tries for.

>=20
> At the moment, a big fallocate evicts all other swappable pages.  Doing i=
t
> piece by piece would at least allow swapping out memory it just allocated
> (if we don't yet have a way to mark it up without physically writing
> zeroes).
>=20
> > * when it fails, why does it undo the work done so far?  This can matte=
r
> >   for other reasons, such as EINTR -- and fallocate isn't expected to b=
e
> >   atomic anyway.
>=20
> I searched a bit for references that would suggest failed fallocates need=
 to
> be undone, and I can't seem to find any.  Neither POSIX nor our man pages
> say a word about semantics of interrupted fallocate, and both glibc's and
> FreeBSD's fallback emulation don't rollback.

To me it was self-evident: with a few awkward exceptions (awkward because
they would have a difficult job to undo, and awkward because they argue
against me!), a system call either succeeds or fails, or reports partial
success.  If fallocate() says it failed (and is not allowed to report
partial success), then it should not have allocated.  Especially in the
case of RAM, when filling it up makes it rather hard to unfill (another
persistent problem with tmpfs is the way it can occupy all of memory,
and the OOM killer go about killing a thousand processes, but none of
them help because the memory is occupied by a tmpfs, not by a process).

Now that you question it (did I not do so at the time? I thought I did),
I try fallocate() on btrfs and ext4 and xfs.  btrfs and xfs behave as I
expect above, failing outright with ENOSPC if it will not fit; whereas
ext4 proceeds to fill up the filesystem, leaving it full when it says
that it failed.  Looks like I had a choice of models to follow: the
ext4 model would have been easier to follow, but risked OOM.

>=20
> But, as my understanding seems to go nearly the opposite way as your comm=
it
> message, am I getting it wrong?  It's you not me who's a mm regular...
>=20
>=20
> Meow!
> --=20
> =E2=A2=80=E2=A3=B4=E2=A0=BE=E2=A0=BB=E2=A2=B6=E2=A3=A6=E2=A0=80
> =E2=A3=BE=E2=A0=81=E2=A2=A0=E2=A0=92=E2=A0=80=E2=A3=BF=E2=A1=81
> =E2=A2=BF=E2=A1=84=E2=A0=98=E2=A0=B7=E2=A0=9A=E2=A0=8B=E2=A0=80 Have you =
accepted Khorne as your lord and saviour?

Actually, no.  Would s/he have a useful insight to share on fallocate()?

Hugh
--0-716188691-1550547315=:1241--

