Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D592AC072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:43:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F96820989
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:43:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hlDW9jPS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F96820989
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4945B6B026E; Tue, 28 May 2019 07:43:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 445446B026F; Tue, 28 May 2019 07:43:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 335336B0272; Tue, 28 May 2019 07:43:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10D916B026E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:43:01 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id b135so8320306vkd.3
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:43:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gmF/MjZR30MUZnp5xpEZAXbIkiTvDuZ5uonAoWGSVI0=;
        b=ds+9CLRnEgkxQApuEVL7XnpMCG0JKcKD3eErjWz8/lq5TDeOdL2FBayNmBcNn4PZJo
         8CEKJEjs//Kgi1u32fZVnhw4I8BSJhdC3v8D1oAgT8BuvytIsECcMICuiNVVp5YPho6r
         9udcux8gLjS04i/IzG0gumBbCcqZtTmsQqmp3Y6cqN3eeYuBjspNVwdyWFaOTQ+iJMUj
         +cnljVVujdelMVNUsWomcsxXL3Jin4BC6y4AF4tNe17vQry//ZHnQDYfk1QzVI9hH7kD
         3b3Fbhjvh99byhAVeclWClyXeDqveoYAIhxn9smpW2+t3uqGxBkyzhzsItxqOj5FhQ6H
         BlrA==
X-Gm-Message-State: APjAAAVjRrUz96yzO5cZdfncjyOqO66GEBILNwoGB2/oAQF62Y8kj6aW
	A4KtBj9HNn6zUPckQMaURBogpMPPvu/TSnCfEGZMnjhlm/F/Bh7k1ozjCN6Nb0ILdsZf6GeWLch
	CtiF4FqPMYp91ZGVEHxH8XZvZNSmL0TWsz7nnQrEXDGzhCOpobdEgA9j+Qvl+UGoyQg==
X-Received: by 2002:a1f:3692:: with SMTP id d140mr25305170vka.70.1559043780675;
        Tue, 28 May 2019 04:43:00 -0700 (PDT)
X-Received: by 2002:a1f:3692:: with SMTP id d140mr25305152vka.70.1559043779969;
        Tue, 28 May 2019 04:42:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559043779; cv=none;
        d=google.com; s=arc-20160816;
        b=RvBtLzwuBN5yEWZWtqduu+azi7glnHbpsiF9ggR3oHDQjJjDWsnquI6A4g0gY2GsCV
         Jmi1Ap9eizjCuP1Sjj9kunulXPywOUVwWWz4FzhReNJacAOAXagvqmxFfuAdiOAS6nAp
         zMibiPS/RSP5oD8Ruy7Zapt52cPowVfgHhxDOAgcOUHmYzUYAgNXR+PQBDGd4RGx/SsU
         oxzRJIt9isxZzBE9ijA+5vcA4PkqoKeZF5erT39RJZENjPk+eA96VJjX7nEyco0IvdP3
         aD/MzoyCgvwXUjawRV+kZ2FS7od/+IVkxOBXx4hZHcQB1LqUnOB/RTukcFa9Fe81j5mC
         RiwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gmF/MjZR30MUZnp5xpEZAXbIkiTvDuZ5uonAoWGSVI0=;
        b=TDn0M8d3U9pYcgcO+EfxPSdZai3Al1PqYKOH4WADrleYmcutawWQLkjOwqTDk2h57b
         hupsgQDppHWAl8oLleYnCa/FNI7b9yAbGBFKq2DuXqXnjuLJ9RkADcLcfG1TMvrycycd
         h2w0UOpKCJhIgoEwX/ndPcBeY9OJgUOcL5DsRWE8tlZvqjOuix9XBr4NHG5eVN3r7brZ
         jF2BvThdb518okpeTuiBf3U6+UkMUxPwsq28UjAQQT7hA10kLwx8Oxy9k5oogVV52swm
         sbPLtHas5QOgpHQee8JxQw4PEFifi7zWWHBGS8uur3FM1NXO3VNYZn+q3tKIoTnCIUz3
         6qgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hlDW9jPS;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j18sor5656707uan.31.2019.05.28.04.42.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 04:42:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hlDW9jPS;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gmF/MjZR30MUZnp5xpEZAXbIkiTvDuZ5uonAoWGSVI0=;
        b=hlDW9jPSp+Zbp5gHMYiybd+exCPEPCxNejShzWmQtQboUqXn2NyzXiKthdzcnC/KGv
         NC+lMlsvUobu5t8d92IzghMfsBLj4J9wEvm2lJNgh7U0f25F8QH1ktixuiqijW+nyb+1
         9A1qxf5vlCfNwqhErg/re/ZoKu6xzxdcM2/a73qTvu+MpL2E/QRt1iy1KoddOjj85Q5J
         YIDmDuYb3+tsCmvCUWoVk93+zXRkWy+rIr2TtUBpSMmgo3JGmcrzeF/C5dZq3YaFUcGl
         75Hud1H9paC2qUBkzZ/DKOjMh+Y4Lx+PxJglgVpehWRLTUO5y9+r4cSKvheGlpWNduOP
         3bKg==
X-Google-Smtp-Source: APXvYqyiNr7P2DjlbLU9A4NNhpmBOKWSjQk2Y7tSLL6dWBbAVxeNAYgXEWOY1g8aEtm+2Vm9om7Y96HxIiS3+0AuAA0=
X-Received: by 2002:ab0:1407:: with SMTP id b7mr41595946uae.112.1559043779267;
 Tue, 28 May 2019 04:42:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190527124411.GC1658@dhcp22.suse.cz> <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz> <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com> <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com> <20190528104117.GW1658@dhcp22.suse.cz>
 <20190528111208.GA30365@google.com> <20190528112840.GY1658@dhcp22.suse.cz>
In-Reply-To: <20190528112840.GY1658@dhcp22.suse.cz>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 28 May 2019 04:42:47 -0700
Message-ID: <CAKOZuesCSrE0esqDDbo8x5u5rM-Uv_81jjBt1QRXFKNOUJu0aw@mail.gmail.com>
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

On Tue, May 28, 2019 at 4:28 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 28-05-19 20:12:08, Minchan Kim wrote:
> > On Tue, May 28, 2019 at 12:41:17PM +0200, Michal Hocko wrote:
> > > On Tue 28-05-19 19:32:56, Minchan Kim wrote:
> > > > On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
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
> > > > With current usecase, it's per-process API with distinguishable anon/file
> > > > but thought it could be easily extended later for each address range
> > > > operation as userspace getting smarter with more information.
> > >
> > > Never design user API based on a single usecase, please. The "easily
> > > extended" part is by far not clear to me TBH. As I've already mentioned
> > > several times, the synchronization model has to be thought through
> > > carefuly before a remote process address range operation can be
> > > implemented.
> >
> > I agree with you that we shouldn't design API on single usecase but what
> > you are concerning is actually not our usecase because we are resilient
> > with the race since MADV_COLD|PAGEOUT is not destruptive.
> > Actually, many hints are already racy in that the upcoming pattern would
> > be different with the behavior you thought at the moment.
>
> How come they are racy wrt address ranges? You would have to be in
> multithreaded environment and then the onus of synchronization is on
> threads. That model is quite clear. But we are talking about separate
> processes and some of them might be even not aware of an external entity
> tweaking their address space.

I don't think the difference between a thread and a process matters in
this context. Threads race on address space operations all the time
--- in the sense that multiple threads modify a process's address
space without synchronization. The main reasons that these races
hasn't been a problem are: 1) threads mostly "mind their own business"
and modify different parts of the address space or use locks to ensure
that they don't stop on each other (e.g., the malloc heap lock), and
2) POSIX mmap atomic-replacement semantics make certain classes of
operation (like "magic ring buffer" setup) safe even in the presence
of other threads stomping over an address space.

The thing that's new in this discussion from a synchronization point
of view isn't that the VM operation we're talking about is coming from
outside the process, but that we want to do a read-decide-modify-ish
thing. We want to affect (using various hints) classes of pages like
"all file pages" or "all anonymous pages" or "some pages referring to
graphics buffers up to 100MB" (to pick an example off the top of my
head of a policy that might make sense). From a synchronization point
of view, it doesn't really matter whether it's a thread within the
target process or a thread outside the target process that does the
address space manipulation. What's new is the inspection of the
address space before performing an operation.

Minchan started this thread by proposing some flags that would
implement a few of the filtering policies I used as examples above.
Personally, instead of providing a few pre-built policies as flags,
I'd rather push the page manipulation policy to userspace as much as
possible and just have the kernel provide a mechanism that *in
general* makes these read-decide-modify operations efficient and
robust. I still think there's way to achieve this goal very
inexpensively without compromising on flexibility.

