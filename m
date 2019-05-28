Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43342C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:11:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E448C208CB
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:11:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="i80p6wNe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E448C208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C7A46B027E; Tue, 28 May 2019 08:11:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 679426B027F; Tue, 28 May 2019 08:11:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 568A56B0281; Tue, 28 May 2019 08:11:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 30B036B027E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:11:31 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id c2so3780598vsm.9
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:11:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=U7wnhTi1uQo6V/xpqUaVr0hP2X6g+jWpW5AQ/F6tDws=;
        b=IXt+HtBWVmXEyk5PLhv2XZhJSPg3sbYWbTSLAHZkpc3h6BXY/UnxLxCc+zJiWX5Y58
         ts9XMcoTP7m9DBaJocMB00p8Tg23oiTJhyFCrRJ/Pp9VHJw3I9BjfGVr4NXFrGRf/rA5
         jV11z1UrAzmqn5KdL6lBbfYXna69Oj0m2TlG6+oHGqxNeOgV0jfJoJqCnhaWpr2zHxnV
         WXqK+9cpFJCx2Bh9dChPIOJi9jUUu89kRHztelAp/ecxSauvsWnZbWvL80g+NGGALdy6
         TQ+Z++4CRZC+9CtcbtJ7kDcWxfJqaWIRyndi8OWPQs0VFfBv9A8/qqdaLhPlfyXQnFuq
         w39A==
X-Gm-Message-State: APjAAAXHhbjhlg/txjf1vDKt1brlj9ahMu8Jf9lhqCOPRslOnJLWKoBc
	brXGxxotFH2H8uQ9NHZAVKSSFzFpAIzPfjgjI4kB3997iS5XvuKWkXSwJiwumoo2W4pHmDl/D5K
	cBn/9cyB1VHxXhcTwdo7HpxJYvU1nqbOueTOhEcLt1QeXv5WeaD/wdEytmqJURlamFg==
X-Received: by 2002:ab0:4147:: with SMTP id j65mr24325554uad.142.1559045490762;
        Tue, 28 May 2019 05:11:30 -0700 (PDT)
X-Received: by 2002:ab0:4147:: with SMTP id j65mr24325451uad.142.1559045489697;
        Tue, 28 May 2019 05:11:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559045489; cv=none;
        d=google.com; s=arc-20160816;
        b=pdn5tjwceX6gfWkllulYFVSrxLG58coqkpUmpnD4939eyaZAKqxC9bYKxlvfOo0/xD
         Ozi0RkCl9LCgdB65//qwKkdWyizFrXo7leFwPV1WaQfuAltIB1f3cbg6ydoybkOPzbzd
         1iO82CT+SMEi8bDGUu3Qa8LNh+UxFhVGenJR7Z8PZOkBKpYEZqKtHXAevFZnVnqi7zXn
         nI0i9rbcq/Ih8OUijVtoXcnGltS6KfEbT/ZuRoa7VVbb1oD4jPliArAwwrXTiwQb2Pl4
         Y01WQv1qi0GktCF2dUzi5m/4bfySOla/jTQ+Le2xXMS6d4CsyimTUACeizhiaGc+lNMn
         8E3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=U7wnhTi1uQo6V/xpqUaVr0hP2X6g+jWpW5AQ/F6tDws=;
        b=fnO1GFeontv1/OcW6Q/eqwXPVuVTvDphkgbOC4LegT4cnpQc1VtMSbe7LMJp3hMZen
         i0HpcXAApFNQh0GtXa8jzwEwnx0MNOxtUNQ81k5Yzdjb2MM6b42359FFqMR52fShVilJ
         VpJSkvwVVNlreU0tJLEsnP0AOVxzN7P7hcHq/qdj1a6XsL2gB6KwKCXR7hXvurtLarL9
         sf1bWkl8ndVcnDt428tzhVCfjGFK02gk7aBlVC7TXcDUxEKEC2M+y5cpkik5fatyOyOC
         Z7p9uv4nreVRxPPDUnmP82qrU9zAQQd9A8INpSUYlXi+EXOS0MrQcE9NpxY7YHdfht75
         mWHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=i80p6wNe;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 18sor5642259uah.51.2019.05.28.05.11.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 05:11:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=i80p6wNe;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=U7wnhTi1uQo6V/xpqUaVr0hP2X6g+jWpW5AQ/F6tDws=;
        b=i80p6wNeevbxzibgjJlQSdFx55pjq29/WrRd24oogoTWyGwx0a7ddWM7vYDcYd2cVj
         yK2syANq10bctqTpD289h+qBiNBJIYBnv8GsHEV/j3VNNkcYDKiDI+AxoVNhhTRSLQ6g
         41oLTGoEsC/MbE5ddRVlXatJ1g+Qw8Oi3X1J9eRxN898G0W0Yv5meexAoitpeWb22sOs
         LxviRM4yobOz209myGmMdqEagjAvxPcKsodHfj56GK02GGAcyXofC1knuaT4nflh0MUD
         mq+k+VqZClnjjU8kJv8thzl+fgaTNjKYkx4OHabMx42oSVbZThKtPNr73nxOHhGblt2e
         NPLA==
X-Google-Smtp-Source: APXvYqxRhcclx4/30SOtZbPyI8AVq9UpcnBdM/JhlqSxn6KB80PXZVG6k3oRp1sa+ZytSp/rM4r2T+UH8y7BdJP+5O0=
X-Received: by 2002:ab0:1407:: with SMTP id b7mr41670622uae.112.1559045488662;
 Tue, 28 May 2019 05:11:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190527124411.GC1658@dhcp22.suse.cz> <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz> <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com> <20190528090821.GU1658@dhcp22.suse.cz>
 <CAKOZueux3T4_dMOUK6R=ZHhCFaSSstOCPh_KSwSMCW_yp=jdSg@mail.gmail.com>
 <20190528103312.GV1658@dhcp22.suse.cz> <CAKOZueuRAtps+YZ1g2SOevBrDwE6tWsTuONJu1NLgvW7cpA-ug@mail.gmail.com>
 <20190528114923.GZ1658@dhcp22.suse.cz>
In-Reply-To: <20190528114923.GZ1658@dhcp22.suse.cz>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 28 May 2019 05:11:16 -0700
Message-ID: <CAKOZueuerHTCPbQqowSxi-_sRsqxYQQqgyi1UOh7EkZcS3DCnA@mail.gmail.com>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 4:49 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 28-05-19 04:21:44, Daniel Colascione wrote:
> > On Tue, May 28, 2019 at 3:33 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Tue 28-05-19 02:39:03, Daniel Colascione wrote:
> > > > On Tue, May 28, 2019 at 2:08 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > > > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > > > > if we went with the per vma fd approach then you would get this
> > > > > > > > > feature automatically because map_files would refer to file backed
> > > > > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > > > > >
> > > > > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > > > > so map_anon wouldn't be helpful.
> > > > > > >
> > > > > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > > > > to suggest that providing an efficient binary interfaces for pulling
> > > > > > > memory map information out of processes.  Some single-system-call
> > > > > > > method for retrieving a binary snapshot of a process's address space
> > > > > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > > > > reduce complexity and increase performance in a variety of areas,
> > > > > > > e.g., Android memory map debugging commands.
> > > > > >
> > > > > > I agree it's the best we can get *generally*.
> > > > > > Michal, any opinion?
> > > > >
> > > > > I am not really sure this is directly related. I think the primary
> > > > > question that we have to sort out first is whether we want to have
> > > > > the remote madvise call process or vma fd based. This is an important
> > > > > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > > > > so far unfortunately.
> > > >
> > > > I don't think the vma fd approach is viable. We have some processes
> > > > with a *lot* of VMAs --- system_server had 4204 when I checked just
> > > > now (and that's typical) --- and an FD operation per VMA would be
> > > > excessive.
> > >
> > > What do you mean by excessive here? Do you expect the process to have
> > > them open all at once?
> >
> > Minchan's already done timing. More broadly, in an era with various
> > speculative execution mitigations, making a system call is pretty
> > expensive.
>
> This is a completely separate discussion. This could be argued about
> many other syscalls.

Yes, it can be. That's why we have scatter-gather IO system calls in
the first place.

> Let's make the semantic correct first before we
> even start thinking about mutliplexing. It is easier to multiplex on an
> existing and sane interface.

I don't think of it as "multiplexing" yet, not in the fundamental unit
of operation is the address range.

> Btw. Minchan concluded that multiplexing is not really all that
> important based on his numbers http://lkml.kernel.org/r/20190527074940.GB6879@google.com
>
> [...]
>
> > > Is this really too much different from /proc/<pid>/map_files?
> >
> > It's very different. See below.
> >
> > > > > An interface to query address range information is a separate but
> > > > > although a related topic. We have /proc/<pid>/[s]maps for that right
> > > > > now and I understand it is not a general win for all usecases because
> > > > > it tends to be slow for some. I can see how /proc/<pid>/map_anons could
> > > > > provide per vma information in a binary form via a fd based interface.
> > > > > But I would rather not conflate those two discussions much - well except
> > > > > if it could give one of the approaches more justification but let's
> > > > > focus on the madvise part first.
> > > >
> > > > I don't think it's a good idea to focus on one feature in a
> > > > multi-feature change when the interactions between features can be
> > > > very important for overall design of the multi-feature system and the
> > > > design of each feature.
> > > >
> > > > Here's my thinking on the high-level design:
> > > >
> > > > I'm imagining an address-range system that would work like this: we'd
> > > > create some kind of process_vm_getinfo(2) system call [1] that would
> > > > accept a statx-like attribute map and a pid/fd parameter as input and
> > > > return, on output, two things: 1) an array [2] of VMA descriptors
> > > > containing the requested information, and 2) a VMA configuration
> > > > sequence number. We'd then have process_madvise() and other
> > > > cross-process VM interfaces accept both address ranges and this
> > > > sequence number; they'd succeed only if the VMA configuration sequence
> > > > number is still current, i.e., the target process hasn't changed its
> > > > VMA configuration (implicitly or explicitly) since the call to
> > > > process_vm_getinfo().
> > >
> > > The sequence number is essentially a cookie that is transparent to the
> > > userspace right? If yes, how does it differ from a fd (returned from
> > > /proc/<pid>/map_{anons,files}/range) which is a cookie itself and it can
> >
> > If you want to operate on N VMAs simultaneously under an FD-per-VMA
> > model, you'd need to have those N FDs all open at the same time *and*
> > add some kind of system call that accepted those N FDs and an
> > operation to perform. The sequence number I'm proposing also applies
> > to the whole address space, not just one VMA. Even if you did have
> > these N FDs open all at once and supplied them all to some batch
> > operation, you couldn't guarantee via the FD mechanism that some *new*
> > VMA didn't appear in the address range you want to manipulate. A
> > global sequence number would catch this case. I still think supplying
> > a list of address ranges (like we already do for scatter-gather IO) is
> > less error-prone, less resource-intensive, more consistent with
> > existing practice, and equally flexible, especially if we start
> > supporting destructive cross-process memory operations, which may be
> > useful for things like checkpointing and optimizing process startup.
>
> I have a strong feeling you are over optimizing here. We are talking
> about a pro-active memory management and so far I haven't heard any
> usecase where all this would happen in the fast path. There are
> essentially two usecases I have heard so far. Age/Reclaim the whole
> process (with anon/fs preferency) and do the same on a particular
> and well specified range (e.g. a garbage collector or an inactive large
> image in browsert etc...). The former doesn't really care about parallel
> address range manipulations because it can tolerate them. The later is a
> completely different story.
>
> Are there any others where saving few ms matter so much?

Saving ms matters quite a bit. We may want to perform some of this
eager memory management in response to user activity, e.g.,
application switch, and even if that work isn't quite synchronous,
every cycle the system spends on management overhead is a cycle it
can't spend on rendering frames. Overhead means jank. Additionally,
we're on battery-operated devices. Milliseconds of CPU overhead
accumulated over a long time is a real energy sink.

> > Besides: process_vm_readv and process_vm_writev already work on
> > address ranges. Why should other cross-process memory APIs use a very
> > different model for naming memory regions?
>
> I would consider those APIs not a great example. They are racy on
> more levels (pid reuse and address space modification), and require a
> non-trivial synchronization. Do you want something similar for madvise
> on a non-cooperating remote application?
>
> > > be used to revalidate when the operation is requested and fail if
> > > something has changed. Moreover we already do have a fd based madvise
> > > syscall so there shouldn't be really a large need to add a new set of
> > > syscalls.
> >
> > We have various system calls that provide hints for open files, but
> > the memory operations are distinct. Modeling anonymous memory as a
> > kind of file-backed memory for purposes of VMA manipulation would also
> > be a departure from existing practice. Can you help me understand why
> > you seem to favor the FD-per-VMA approach so heavily? I don't see any
> > arguments *for* an FD-per-VMA model for remove memory manipulation and
> > I see a lot of arguments against it. Is there some compelling
> > advantage I'm missing?
>
> First and foremost it provides an easy cookie to the userspace to
> guarantee time-to-check-time-to-use consistency.

But only for one VMA at a time.

> It also naturally
> extend an existing fadvise interface that achieves madvise semantic on
> files.

There are lots of things that madvise can do that fadvise can't and
that don't even really make sense for fadvise, e.g., MADV_FREE. It
seems odd to me to duplicate much of the madvise interface into
fadvise so that we can use file APIs to give madvise hints. It seems
simpler to me to just provide a mechanism to put the madvise hints
where they're needed.

> I am not really pushing hard for this particular API but I really
> do care about a programming model that would be sane.

You've used "sane" twice so far in this message. Can you specify more
precisely what you mean by that word? I agree that there needs to be
some defense against TOCTOU races when doing remote memory management,
but I don't think providing this robustness via a file descriptor is
any more sane than alternative approaches. A file descriptor comes
with a lot of other features --- e.g., SCM_RIGHTS, fstat, and a
concept of owning a resource --- that aren't needed to achieve
robustness.

Normally, a file descriptor refers to some resource that the kernel
holds as long as the file descriptor (well, the open file description
or struct file) lives -- things like graphics buffers, files, and
sockets. If we're using an FD *just* as a cookie and not a resource,
I'd rather just expose the cookie directly.

> If we have a
> different means to achieve the same then all fine by me but so far I
> haven't heard any sound arguments to invent something completely new
> when we have established APIs to use.

Doesn't the next sentence describe something profoundly new? :-)

> Exporting anonymous mappings via
> proc the same way we do for file mappings doesn't seem to be stepping
> outside of the current practice way too much.

It seems like a radical departure from existing practice to provide
filesystem interfaces to anonymous memory regions, e.g., anon_vma.
You've never been able to refer to those memory regions with file
descriptors.

All I'm suggesting is that we take the existing madvise mechanism,
make it work cross-process, and make it robust against TOCTOU
problems, all one step at a time. Maybe my sense of API "size" is
miscalibrated, but adding a new type of FD to refer to anonymous VMA
regions feels like a bigger departure and so requires stronger
justification, especially if the result of the FD approach is probably
something less efficient than a cookie-based one.

> and we should focus on discussing whether this is a
> sane model. And I think it would be much better to discuss that under
> the respective patch which introduces that API rather than here.

I think it's important to discuss what that API should look like. :-)

