Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42407C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 08:12:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E60DD2177E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 08:12:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RFneT7Ir"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E60DD2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 732EA8E0004; Wed, 13 Mar 2019 04:12:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E08A8E0001; Wed, 13 Mar 2019 04:12:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D1498E0004; Wed, 13 Mar 2019 04:12:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 367FB8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 04:12:48 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id r136so854143ith.3
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 01:12:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nOCnQSyICOjHIihXvleYcLez4NbqcA5J+kbiAScPb/M=;
        b=aDHK7lkHMI/zLB/AbSyu69fj00iLmAD0i6QLgF9dCp7Qg4E2r3/u6TVloukvqeIXmn
         yPy8MFEwanWPHjA8t1SRRt1XNnPIY2FrcAOW0yzCOJPFJ2tIPCtC4PJA+rr3NaS1AqW2
         X0nkBTrRhUh1mZZR6mypSb1jbRlqLdW3Idqi1ycLECisstRUQ5QekcL2VxYdC6PckUyh
         3oq/8qugOdTVpzTgL8BPwZ4EFP7bjR4+gyqf7/pb4ju/pr0m2X6G+dMid2GvsKkmRq/3
         a1GXqGLuyd0aaFo/PZwVTJkHDJM/lQuDf1sSOJ7Tz1Z90cWTgB4BxN4KBvtg+c/R9RZw
         Tlqw==
X-Gm-Message-State: APjAAAVwLODyBoOIdENDBrqb5uBDZgFx1cDjWMdt26c3uWvb88gOmVJ3
	Ih5iw0IiuM3H/7MgMXvlB02VevA2Tfq32mMK2ZOnibP14fO88niFrIL2rBYjH2gz1KlGHpwsmY5
	oRYB3UsO4h03++Q+Dz96Xrcj5CNmPjK/SzJBaBqPPVFFHG2vdA1q7uJ1Ab6hDTf4Rhw==
X-Received: by 2002:a24:2b4c:: with SMTP id h73mr1102684ita.159.1552464767954;
        Wed, 13 Mar 2019 01:12:47 -0700 (PDT)
X-Received: by 2002:a24:2b4c:: with SMTP id h73mr1102658ita.159.1552464767013;
        Wed, 13 Mar 2019 01:12:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552464767; cv=none;
        d=google.com; s=arc-20160816;
        b=f8/T5UfI7An6hnnCNV7TZNuqyUFM/OYOUt8z/dsKw1XprPDM8oVKE+lXBHAAa0SEyi
         IFcB6ZzG23uf2W+6W7lj325fpkZGxwpdrJ+LOBnXHpDum+dbZ2XbaGvztL1kO9L65Xpd
         nzEZk6AyPtF/4p2O5VM1RUtls2ajELI4JkrrP+kuhucnmIUKutqBAjNsIwy/X7YgrEg2
         kD8dsAQMGrBW0IcYVYuKXkoHPvA6WWoNJEWvgvk8+eZe525b1yKSxahVO2m8TOEhC9D/
         wI5bDiyjZrAPnJt3j+sr/aR1MGc++LQlIz1Ql2Dkzb8fIqu47OaD4TPupvuAGBCXJhR+
         XlrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nOCnQSyICOjHIihXvleYcLez4NbqcA5J+kbiAScPb/M=;
        b=vlauE4eEjWpR0+XtmfnHVKDmI0+Zq+kK7ftf1E47w0GEjMgsMxKVwuol9JC+2QItmW
         hLYrgvDrg70Ko2odQYlMd1YtKG7CDfOXe78rNAOaDmBt7Z0IFg9FFp5v3/gc3LpT2nKW
         7zcsUM8R8Tg1UZMW59rrNLUS4AFoN3L4xBztDl/PHCelVy+m5VVlj7WjGbObw6oBNpiY
         iCUbYg5fPuKxm0RVMeanqbZpUHyB6x2i86oVvntQvybAnBOtOn/fC4eCb0jsYpc9I+LT
         seiI37D2G6s8sdOErXhgYSbK0wqgmu5u0A7+37NiL33Tb8bAn9UIgdDftwRZx+wxT1Hv
         518w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RFneT7Ir;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 194sor1583711itu.23.2019.03.13.01.12.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 01:12:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RFneT7Ir;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nOCnQSyICOjHIihXvleYcLez4NbqcA5J+kbiAScPb/M=;
        b=RFneT7IrnqSQ/794rwi5hPOHqGioI+7ey0G8A02r6RcC7i9aIYhtEhAGpaaNrE0ttc
         lda7mY1auh22NsRyANoBbUghKtooMVLSzUsgr43kKmOV0IOlCqLI9yA3cbpMXOYNsVwe
         LtMOEYgYkJLoV4MHYxlT/w+KGkBvIkNBM6knHxBj/Qfy0r4CoC986CIJGkzczOnSij+w
         V+kVKRGxgQ0IBSS3n6mkcrG5oVy1eTItdf1BKftQRshc0RmZvAlQrtpRRWWTxYr4i/32
         NlSXIjErjgZtFbpaTAH/6aMoRJEukgapYYuY5YgInh6tud36xJZai97kRXJix59G9tI7
         v83g==
X-Google-Smtp-Source: APXvYqwQCCsPmmtbNRDn+twvOX+qtilAK7cV2LlBXM6Z1SYVMVSrBXys1elUlKnwoMFin2KjLABaTQL+B/C+uf5kIKY=
X-Received: by 2002:a05:660c:3d1:: with SMTP id c17mr949206itl.166.1552464766439;
 Wed, 13 Mar 2019 01:12:46 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000001fd5780583d1433f@google.com> <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
 <CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com>
 <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org>
 <20190312064300.GB9123@sol.localdomain> <CACT4Y+Z1rkS5bf3x9Y+0ke=zZ+mM2F5+vN-JtSQpjD09STRNdw@mail.gmail.com>
 <20190312223113.GA38846@gmail.com>
In-Reply-To: <20190312223113.GA38846@gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 13 Mar 2019 09:12:35 +0100
Message-ID: <CACT4Y+ZWGYuEu0b7t=stYzD2hmfe0E2m0-o0KURa7tDjP+r7UA@mail.gmail.com>
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
To: Eric Biggers <ebiggers@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>, 
	Cgroups <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Shakeel Butt <shakeelb@google.com>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 11:31 PM Eric Biggers <ebiggers@kernel.org> wrote:
>
> Hi Dmitry,
>
> On Tue, Mar 12, 2019 at 09:21:09AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> > On Tue, Mar 12, 2019 at 7:43 AM Eric Biggers <ebiggers@kernel.org> wrote:
> > >
> > > On Mon, Mar 11, 2019 at 11:25:41PM -0700, Andrew Morton wrote:
> > > > On Tue, 12 Mar 2019 07:08:38 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
> > > >
> > > > > On Tue, Mar 12, 2019 at 12:37 AM Andrew Morton
> > > > > <akpm@linux-foundation.org> wrote:
> > > > > >
> > > > > > On Mon, 11 Mar 2019 06:08:01 -0700 syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com> wrote:
> > > > > >
> > > > > > > syzbot has bisected this bug to:
> > > > > > >
> > > > > > > commit 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> > > > > > > Author: Shakeel Butt <shakeelb@google.com>
> > > > > > > Date:   Wed Jan 9 22:02:21 2019 +0000
> > > > > > >
> > > > > > >      memcg: schedule high reclaim for remote memcgs on high_work
> > > > > > >
> > > > > > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=155bf5db200000
> > > > > > > start commit:   29a4b8e2 memcg: schedule high reclaim for remote memcgs on..
> > > > > > > git tree:       linux-next
> > > > > > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=175bf5db200000
> > > > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=135bf5db200000
> > > > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
> > > > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > > > > > > userspace arch: amd64
> > > > > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
> > > > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000
> > > > > > >
> > > > > > > Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com
> > > > > > > Fixes: 29a4b8e2 ("memcg: schedule high reclaim for remote memcgs on
> > > > > > > high_work")
> > > > > >
> > > > > > The following patch
> > > > > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > > > > > might have fixed this.  Was it applied?
> > > > >
> > > > > Hi Andrew,
> > > > >
> > > > > You mean if the patch was applied during the bisection?
> > > > > No, it wasn't. Bisection is very specifically done on the same tree
> > > > > where the bug was hit. There are already too many factors that make
> > > > > the result flaky/wrong/inconclusive without changing the tree state.
> > > > > Now, if syzbot would know about any pending fix for this bug, then it
> > > > > would not do the bisection at all. But it have not seen any patch in
> > > > > upstream/linux-next with the Reported-by tag, nor it received any syz
> > > > > fix commands for this bugs. Should have been it aware of the fix? How?
> > > >
> > > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch was
> > > > added to linux-next on Jan 10.  I take it that this bug was hit when
> > > > testing the entire linux-next tree, so we can assume that
> > > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > > > does not fix it, correct?
> > > >
> > > > In which case, over to Shakeel!
> > > >
> > >
> > > I don't understand what happened here.  First, the syzbot report doesn't say
> > > which linux-next version was tested (which it should), but I get:
> > >
> > > $ git tag --contains 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> > > next-20190110
> > > next-20190111
> > > next-20190114
> > > next-20190115
> > > next-20190116
> > >
> > > That's almost 2 months old, yet this bug was just reported now.  Why?
> >
> > Hi Eric,
> >
> > This bug was reported on Jan 10:
> > https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > https://groups.google.com/forum/#!msg/syzkaller-bugs/5YkhNUg2PFY/4-B5M7bDCAAJ
> >
> > The start revision of the bisection process (provided) is the same
> > that was used to create the reproducer. The end revision and bisection
> > log are provided in the email.
> >
> > How can we improve the format to make it more clear?
> >
>
> syzbot started a new thread rather than sending the bisection result in the
> existing thread.  So I thought it was a new bug report, as did everyone else
> probably.

There were not In-reply-to headers in first few bisect reports. This
should be fixed now. E.g. this one should be properly threaded:
https://groups.google.com/forum/#!topic/syzkaller-bugs/r2t3i5E78Mw

