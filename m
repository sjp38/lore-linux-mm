Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3131C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:19:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D0FB208CB
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:19:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Yb4Ahbzv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D0FB208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3C996B027A; Tue, 28 May 2019 08:19:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D40626B027E; Tue, 28 May 2019 08:19:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCB776B027F; Tue, 28 May 2019 08:19:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8C96B027A
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:19:01 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id q6so3775133vsn.11
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:19:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ORqKaK5SbOOd3p03HTDtpxAB4e5t5rAZ59rsVeYfxoU=;
        b=lALN4yYsXX5I9quCk2mOXU965qNzWNvBQZB4EZTneb8K0jU7S8zt//ZiRDw6TuOUv3
         HB1+t+kL+Q8CjPuPr79lYrBUlnAzcWCaAzWGCfW8GmBvHToAhuxy2L5ipE5xpPVkOTSt
         rsZIf8fVTwRFJuCDu2dAsZ3BF1wp8H48Rcd8DcgiKdhgPbU6wyBfPzVB1Wjo3JYn/XHS
         +20WgNJxV8rX2rPivUxTkVFnpZFr55JUVuwz5UA701HKQtmkYbI05Q3+kr3mLx1tN5kV
         hkrOiiTVdrm0+BDUNo74vnyhNbRRrflIm3BMr9LrJWjOKnZ+spkp1c7xbaMAAE3QHJAB
         m1pQ==
X-Gm-Message-State: APjAAAWVMSJZ8JO87xwzZ9aO8ebnFv3xhwNNezYYyC802B3ZCTL+/pUm
	N1VyaCya/m7kWfsThjEzOKZGVCPgAxzu8uP7+I1rCMLOdHXiltHHacXDb6BX1aMUYukdRMDiLgV
	amLwPkd9SBIa4jbz5hkhGtH4HlgLn5yhLQw4Mi2bPj3B1Uf1v8OZ4noejoU4PO1x51A==
X-Received: by 2002:a1f:2915:: with SMTP id p21mr24795431vkp.52.1559045941245;
        Tue, 28 May 2019 05:19:01 -0700 (PDT)
X-Received: by 2002:a1f:2915:: with SMTP id p21mr24795368vkp.52.1559045940503;
        Tue, 28 May 2019 05:19:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559045940; cv=none;
        d=google.com; s=arc-20160816;
        b=zVEmdmEKOjWLbD9OThdPDakq+UwNZZ3bCdowJPT+7iCHzgF4uFw9I4Q1cxOymFn+9M
         6Pk4SSoFKQG5MADFP2etlLcdeu12NzTvqHM19iUy19rnBO3uyrjMNvgdTp+wHUEv+1jR
         cb2xx9TwLOUchO/jGHjQRuOmpCaezizJmdzVuKg3kLJ0CABWtkBeQ/9uQB3F3Ctf/eNj
         XiFIGiRMcQoYiNjoPFWOUdEe6bAu8WBGzMbcRx05XRDIekWPxh+vUQIFq6zaCuHVmVSE
         p9HMtIRxgbK4+v3AzsL+CiW+uTcnVORNqQsbCIyM40Oh1xVFWYTXoZavMjKDXPkgDSmE
         EQLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ORqKaK5SbOOd3p03HTDtpxAB4e5t5rAZ59rsVeYfxoU=;
        b=rwfATDWSxcJ82ieUNeMkTXOmCMlobgix8o4s5L7qcZaKTj4incWX5opJ2iGmsxyckY
         yma4OZzs+v0S/0HvWAwGQzwYwY+Bl+vV8o9pk+tVaINdTwaqYk8cV8jHPQVAH5raUsTh
         TANBiWci1+A5q2ILi4taacpUgFAqwC23WBD4gTuVsu1wlNEi040dnquTxdES43DBNgEs
         a7ePcqfnrfpnvxWPQWVA6kfIKma1QgfdizMX75WHnEVU4Q9nsTqQ2BmGMB4Ze+yiAspS
         nmL0oWcmWjUGgdNQw6afHKK7l6UuBXo8tbD/WB5JFG5hCtd1Z4ibgSwNi+o+GIgCmhU8
         TAjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Yb4Ahbzv;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9sor5513567vsn.33.2019.05.28.05.19.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 05:19:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Yb4Ahbzv;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ORqKaK5SbOOd3p03HTDtpxAB4e5t5rAZ59rsVeYfxoU=;
        b=Yb4AhbzvgeoA4phjVOJgz3SL60IuOMa8e9QKY6JUgxCC+BPSNxincUqUTNCFIwB4Vt
         Q9VI3sCNMb+8I72kXpXELXcJuvXW8CKb0j8Ivk8/6SLj0VKc8wKKe/higTt79ys6xeZd
         dW5DnxVyyT3tsWYFyB9nxe8Mq+2NPwe56EL4eZNi0jw5O/LW+2Pg0NIyfld2HFZ7oswO
         kKLQeRwXVV1Yw2f3Qzri/8ET09sAEj9LkrIVGq6mN5NimUXB+Fnd3bMWoU39ncUZ6BI3
         1aL8SxpujBgTVax7pnOd2dbf7pM+dB/cjo8UxoCwXmSyi+fw2Pyh/ji6TmJgsqU90nbi
         yfkQ==
X-Google-Smtp-Source: APXvYqwHGdwWWRLMzJZmDcCG1KolSprsOID74iOH6L9dNX3JnKLeaXSRpvZuXPWdpupjhSWyj0fwrcEZakU/8Ak5rzw=
X-Received: by 2002:a67:1485:: with SMTP id 127mr43484532vsu.77.1559045939780;
 Tue, 28 May 2019 05:18:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190528062947.GL1658@dhcp22.suse.cz> <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com> <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com> <20190528104117.GW1658@dhcp22.suse.cz>
 <20190528111208.GA30365@google.com> <20190528112840.GY1658@dhcp22.suse.cz>
 <CAKOZuesCSrE0esqDDbo8x5u5rM-Uv_81jjBt1QRXFKNOUJu0aw@mail.gmail.com> <20190528115609.GA1658@dhcp22.suse.cz>
In-Reply-To: <20190528115609.GA1658@dhcp22.suse.cz>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 28 May 2019 05:18:48 -0700
Message-ID: <CAKOZuesnXGAsQgkB45n=jqwDRQ4_aoPiydmZxfxPmzO2p=cTow@mail.gmail.com>
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

On Tue, May 28, 2019 at 4:56 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 28-05-19 04:42:47, Daniel Colascione wrote:
> > On Tue, May 28, 2019 at 4:28 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Tue 28-05-19 20:12:08, Minchan Kim wrote:
> > > > On Tue, May 28, 2019 at 12:41:17PM +0200, Michal Hocko wrote:
> > > > > On Tue 28-05-19 19:32:56, Minchan Kim wrote:
> > > > > > On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
> > > > > > > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > > > > > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > > > > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > > > > > > if we went with the per vma fd approach then you would get this
> > > > > > > > > > > feature automatically because map_files would refer to file backed
> > > > > > > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > > > > > > >
> > > > > > > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > > > > > > so map_anon wouldn't be helpful.
> > > > > > > > >
> > > > > > > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > > > > > > to suggest that providing an efficient binary interfaces for pulling
> > > > > > > > > memory map information out of processes.  Some single-system-call
> > > > > > > > > method for retrieving a binary snapshot of a process's address space
> > > > > > > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > > > > > > reduce complexity and increase performance in a variety of areas,
> > > > > > > > > e.g., Android memory map debugging commands.
> > > > > > > >
> > > > > > > > I agree it's the best we can get *generally*.
> > > > > > > > Michal, any opinion?
> > > > > > >
> > > > > > > I am not really sure this is directly related. I think the primary
> > > > > > > question that we have to sort out first is whether we want to have
> > > > > > > the remote madvise call process or vma fd based. This is an important
> > > > > > > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > > > > > > so far unfortunately.
> > > > > >
> > > > > > With current usecase, it's per-process API with distinguishable anon/file
> > > > > > but thought it could be easily extended later for each address range
> > > > > > operation as userspace getting smarter with more information.
> > > > >
> > > > > Never design user API based on a single usecase, please. The "easily
> > > > > extended" part is by far not clear to me TBH. As I've already mentioned
> > > > > several times, the synchronization model has to be thought through
> > > > > carefuly before a remote process address range operation can be
> > > > > implemented.
> > > >
> > > > I agree with you that we shouldn't design API on single usecase but what
> > > > you are concerning is actually not our usecase because we are resilient
> > > > with the race since MADV_COLD|PAGEOUT is not destruptive.
> > > > Actually, many hints are already racy in that the upcoming pattern would
> > > > be different with the behavior you thought at the moment.
> > >
> > > How come they are racy wrt address ranges? You would have to be in
> > > multithreaded environment and then the onus of synchronization is on
> > > threads. That model is quite clear. But we are talking about separate
> > > processes and some of them might be even not aware of an external entity
> > > tweaking their address space.
> >
> > I don't think the difference between a thread and a process matters in
> > this context. Threads race on address space operations all the time
> > --- in the sense that multiple threads modify a process's address
> > space without synchronization.
>
> I would disagree. They do have in-kernel synchronization as long as they
> do not use MAP_FIXED. If they do want to use MAP_FIXED then they better
> synchronize or the result is undefined.

Right. It's because the kernel hands off different regions to
different non-MAP_FIXED mmap callers that it's pretty easy for threads
to mind their own business, but they're all still using the same
address space.

> > From a synchronization point
> > of view, it doesn't really matter whether it's a thread within the
> > target process or a thread outside the target process that does the
> > address space manipulation. What's new is the inspection of the
> > address space before performing an operation.
>
> The fundamental difference is that if you want to achieve the same
> inside the process then your application is inherenly aware of the
> operation and use whatever synchronization is needed to achieve a
> consistency. As soon as you allow the same from outside you either
> have to have an aware target application as well or you need a mechanism
> to find out that your decision has been invalidated by a later
> unsynchronized action.

I thought of this objection immediately after I hit send. :-)

I still don't think the intra- vs inter-process difference matters.
It's true that threads can synchronize with each other, but different
processes can synchronize with each other too. I mean, you *could* use
sem_open(3) for your heap lock and open the semaphore from two
different processes. That's silly, but it'd work.

The important requirement, I think, is that we need to support
managing "memory-naive" uncooperative tasks (perhaps legacy ones
written before cross-process memory management even became possible),
and I think that the cooperative-vs-uncooperative distinction matters
a lot more than the tgid of the thread doing the memory manipulation.
(Although in our case, we really do need a separate tgid. :-))

