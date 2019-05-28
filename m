Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45F1CC072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:11:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 007042081C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:11:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="otVKalXO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 007042081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 939FA6B027A; Tue, 28 May 2019 08:11:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E9BF6B027C; Tue, 28 May 2019 08:11:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D8E76B027E; Tue, 28 May 2019 08:11:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41F5C6B027A
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:11:00 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b69so13245346plb.9
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:11:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bLLPV7eUO2o74o8LrbA0JPtEr1nRmqodWfzOijaU7Mk=;
        b=gw/v9bA4Lss4qjaQi04y6k/zeGy9f/h6dDiFZzu2/y050k+4tgvPyraFLliz5wU3Iq
         KG8Mut6Cbl6l+CTIZScl1QRdlApj3lqYwB0zoczxEKIPbHGgaracQzSGyIBHxOBkEwzy
         tjsqeyZIxJFMyKa3QxuTjtEvE0df1+zzTrcJEU2fERxZeEN8/GMr8unhsKMpOoXZUeaY
         CwuI7sZs/8AVG/RHqcxYhgs4E3SIBInIuqQ38v0aFQWyEPRu+B9ocAvl/OqYVm7iEggG
         v5rr+oUn3Z6dLfY21Bc3MnSQoW8v2Hsv9qvRykmq5UeOp06iaE5bcbWz/WX83R0tPeZZ
         9eBw==
X-Gm-Message-State: APjAAAVRCLYWRq5sHEt5lSoVF9YkUTzlb/zuFUZ08pWOg3eZcC8kv2Wo
	+6rONIcypXsa1bH+v1pfpW8mA0M1sRXvur7355fdOgRmHCYxPmX6jQ0IaEAYdMECkRLL0TvOxc5
	EMel0N2WSSFmyA5U20PnuCpwts/6XuI1pI3Y8EFfUn7grqQnMM5IDXL2TJ0et/Ys=
X-Received: by 2002:a17:90a:a10f:: with SMTP id s15mr5584858pjp.30.1559045459896;
        Tue, 28 May 2019 05:10:59 -0700 (PDT)
X-Received: by 2002:a17:90a:a10f:: with SMTP id s15mr5584749pjp.30.1559045459023;
        Tue, 28 May 2019 05:10:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559045459; cv=none;
        d=google.com; s=arc-20160816;
        b=bJ3PoHYeauDNDDv7YJlaCea68m2lKzeWO65eRh+KqklqqIvm2UjWfdr2zyQYAERCr+
         bZy2Fq9A1hJObKQ55Fvxx29YGfax4OFeC+Ns77YGjOdQavmrZEQwTaCQB4o/Avy8oYc2
         u3fBiuWn4jeVUHU7nWHFSWHlyo9O0FfS3CIPlUqbE7QxZwfq9oXYsUSMflOvCDt2CSi8
         nhG4ClK0M93gKc1SXvirQwW2TT2/wZ9NgLAWLUTFSO4Khy53rALee1RtxKzxK72+blq9
         x07I/Hc/XYS2BCvsx4O7aBnAii2DU/+NuYNfwk7xVXMjp8ycG7ie0Fs1O5/7eVEBcDYi
         /KZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=bLLPV7eUO2o74o8LrbA0JPtEr1nRmqodWfzOijaU7Mk=;
        b=earsNzmtqdpbiHBAk8cJCWMdgcczf9wo4fy3zouySPHNPWDOsKuPtZG6YXQX+3RjoU
         IqrpfpyV/Q7WxNjpD30552C1rAm9A9fgm0w0dIyRH+lkq3JWibyZYvdVGyrt5h63WtXr
         2XCGnc/uDrLowmRKg4hCtw0jO66F9dFUh6VwNSE02GuHFor+OERDx/6Ff6caS6ZeOliK
         Qyv7TchdD8P0iVYVGHjdCpgbY3agqMAsWu3nSUC11j7RQT3e4tMYI2ZYV2Ig+hQcKNuv
         sHtwBeBVAibQrgjEseYWUQ3idtn/wAUI2QW8yPvd8o24e+k0KuYou8ys9b7gaqUgRiJq
         2vjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=otVKalXO;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o5sor12720363pgo.4.2019.05.28.05.10.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 05:10:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=otVKalXO;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bLLPV7eUO2o74o8LrbA0JPtEr1nRmqodWfzOijaU7Mk=;
        b=otVKalXOYK/nl0zCxrG447epNj1oX5gR3f9V+FgwtTx23N8nFnQz5rEfq0ftxjYHVv
         7yhZLGKJphQ9eZGVV5INryPO/1cGHk8qRUu4I4W6okNsPJMeYQPQCQyIGdsATqyfWgj+
         IyfIvtcwVGkIU9V0SzJcZCI3tdGx90XfN0C0l6QQguyy6FsIs5zGJ3GwjOQ71QbaAR4h
         IZMO+Vzh2OSfElP2QnOCEsgHGiq0ht6fcuUk+23bwdpUMQYO5VW60f63cTXbmNna7X9i
         qnVeQkvm6g2+ZSsxMXWHTUnmNuYMWtfeYpTDz2zk212eHa0pevdsLlnDFCFE/s5m93mo
         VU7A==
X-Google-Smtp-Source: APXvYqzZu2DckSAfm6b7/skht70dageJqYdxnd3tnitDqNQYstXd5I6Z9o69tRtnlF0c9Z9C+Sqe0g==
X-Received: by 2002:a63:4104:: with SMTP id o4mr13313731pga.345.1559045458612;
        Tue, 28 May 2019 05:10:58 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id b18sm23588605pfp.32.2019.05.28.05.10.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 28 May 2019 05:10:57 -0700 (PDT)
Date: Tue, 28 May 2019 21:10:51 +0900
From: Minchan Kim <minchan@kernel.org>
To: Daniel Colascione <dancol@google.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190528121051.GC30365@google.com>
References: <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com>
 <20190528104117.GW1658@dhcp22.suse.cz>
 <20190528111208.GA30365@google.com>
 <20190528112840.GY1658@dhcp22.suse.cz>
 <CAKOZuesCSrE0esqDDbo8x5u5rM-Uv_81jjBt1QRXFKNOUJu0aw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuesCSrE0esqDDbo8x5u5rM-Uv_81jjBt1QRXFKNOUJu0aw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 04:42:47AM -0700, Daniel Colascione wrote:
> On Tue, May 28, 2019 at 4:28 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 28-05-19 20:12:08, Minchan Kim wrote:
> > > On Tue, May 28, 2019 at 12:41:17PM +0200, Michal Hocko wrote:
> > > > On Tue 28-05-19 19:32:56, Minchan Kim wrote:
> > > > > On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
> > > > > > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > > > > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > > > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > > > > > if we went with the per vma fd approach then you would get this
> > > > > > > > > > feature automatically because map_files would refer to file backed
> > > > > > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > > > > > >
> > > > > > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > > > > > so map_anon wouldn't be helpful.
> > > > > > > >
> > > > > > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > > > > > to suggest that providing an efficient binary interfaces for pulling
> > > > > > > > memory map information out of processes.  Some single-system-call
> > > > > > > > method for retrieving a binary snapshot of a process's address space
> > > > > > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > > > > > reduce complexity and increase performance in a variety of areas,
> > > > > > > > e.g., Android memory map debugging commands.
> > > > > > >
> > > > > > > I agree it's the best we can get *generally*.
> > > > > > > Michal, any opinion?
> > > > > >
> > > > > > I am not really sure this is directly related. I think the primary
> > > > > > question that we have to sort out first is whether we want to have
> > > > > > the remote madvise call process or vma fd based. This is an important
> > > > > > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > > > > > so far unfortunately.
> > > > >
> > > > > With current usecase, it's per-process API with distinguishable anon/file
> > > > > but thought it could be easily extended later for each address range
> > > > > operation as userspace getting smarter with more information.
> > > >
> > > > Never design user API based on a single usecase, please. The "easily
> > > > extended" part is by far not clear to me TBH. As I've already mentioned
> > > > several times, the synchronization model has to be thought through
> > > > carefuly before a remote process address range operation can be
> > > > implemented.
> > >
> > > I agree with you that we shouldn't design API on single usecase but what
> > > you are concerning is actually not our usecase because we are resilient
> > > with the race since MADV_COLD|PAGEOUT is not destruptive.
> > > Actually, many hints are already racy in that the upcoming pattern would
> > > be different with the behavior you thought at the moment.
> >
> > How come they are racy wrt address ranges? You would have to be in
> > multithreaded environment and then the onus of synchronization is on
> > threads. That model is quite clear. But we are talking about separate
> > processes and some of them might be even not aware of an external entity
> > tweaking their address space.
> 
> I don't think the difference between a thread and a process matters in
> this context. Threads race on address space operations all the time
> --- in the sense that multiple threads modify a process's address
> space without synchronization. The main reasons that these races
> hasn't been a problem are: 1) threads mostly "mind their own business"
> and modify different parts of the address space or use locks to ensure
> that they don't stop on each other (e.g., the malloc heap lock), and
> 2) POSIX mmap atomic-replacement semantics make certain classes of
> operation (like "magic ring buffer" setup) safe even in the presence
> of other threads stomping over an address space.
> 
> The thing that's new in this discussion from a synchronization point
> of view isn't that the VM operation we're talking about is coming from
> outside the process, but that we want to do a read-decide-modify-ish
> thing. We want to affect (using various hints) classes of pages like
> "all file pages" or "all anonymous pages" or "some pages referring to
> graphics buffers up to 100MB" (to pick an example off the top of my
> head of a policy that might make sense). From a synchronization point
> of view, it doesn't really matter whether it's a thread within the
> target process or a thread outside the target process that does the
> address space manipulation. What's new is the inspection of the
> address space before performing an operation.
> 
> Minchan started this thread by proposing some flags that would
> implement a few of the filtering policies I used as examples above.
> Personally, instead of providing a few pre-built policies as flags,
> I'd rather push the page manipulation policy to userspace as much as
> possible and just have the kernel provide a mechanism that *in
> general* makes these read-decide-modify operations efficient and
> robust. I still think there's way to achieve this goal very
> inexpensively without compromising on flexibility.

I'm looking forward to seeing the way. ;-)

