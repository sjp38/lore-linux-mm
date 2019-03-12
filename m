Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9654FC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 08:21:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C00221734
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 08:21:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="p75wBFIH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C00221734
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBD458E0003; Tue, 12 Mar 2019 04:21:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6AA98E0002; Tue, 12 Mar 2019 04:21:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A59B38E0003; Tue, 12 Mar 2019 04:21:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6808E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 04:21:23 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id v12so1538234itv.9
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 01:21:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vY+3ao+y9L7nD7alFgZQuTM3dt7AhOxf+8CD5umNl0c=;
        b=tsYDKIQmM6HBB98qwRtLBP7SsOp6SVKgoXqclNVtNnIHUy9Z0JOR//dexbEPUonz68
         33j/Wq30J36C3wf33rSeYb9J3zzor2SvYzV7f5B0gyBTe4OY52BR+FeDm04HzFs/1gWF
         VfZMpjv8EzLXk3T5oic8KdpK5jfG96Fnu6VJfWG+gGhOGARQ6JrK5GzaYSX/tXj24bWu
         hhvN5VVhGGbzfOsxPvVKK7ccST1OyWiHWBlXFh0/JBI/dW+G67EdjdlSlVzta0o9sSdy
         pLXQIxZCIe08q5RNeKCSbghpWX8OfdBSJwJFJq0ZinH8jVQ2U4roWtQ7tGTdFUIT8xFr
         M+lA==
X-Gm-Message-State: APjAAAVq5kT0ouZrkWKHIL/paIk7KxpuOUiEBevTVwMWJaG7Sb+SBVbM
	E9arA4hsof4Bgwg5/rGXjOUKmz3tYTnzZ5bDQopj00d3RHhfD2j94MStEWQhaZ+Ub5P0PBByYsK
	WTnYKtJdOCZP99cXqCo9beHjtzXnGWF3oO0iTk9zsU+LjXg8TFpTY2u5E9Qi1Lo2RxPild9QOdZ
	jCE4CuAXUdxo1CPob2dVS3efT1/xXRLWFokA1GpOdDQFB81MO7lbdvJmd4hb/cltwmSSp9a+79T
	TmtHadXh0ULvbfwuDmF/YhPVfHN1kLcQB82kBVkwYArz2PW7DPw0u2znZ+vxC1IC/+i5tly3Gp8
	8VXKJEYJL92z+ARvBAo9toVWgTiFonyQNn3K7Q5d/XZDyrxQ7zrr7xGvP3ibPVPGHbxgEomud/L
	u
X-Received: by 2002:a02:cd29:: with SMTP id h9mr13102066jaq.17.1552378883187;
        Tue, 12 Mar 2019 01:21:23 -0700 (PDT)
X-Received: by 2002:a02:cd29:: with SMTP id h9mr13102037jaq.17.1552378882294;
        Tue, 12 Mar 2019 01:21:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552378882; cv=none;
        d=google.com; s=arc-20160816;
        b=xfJNa9M+pj+IbA37vCdk/zB6F2TTBM44L8AFjew09xrJFRIKtHFrv2d+FRwXug7TSX
         EhHHFuHEgofpmZeBdaIJrfJbjeasZiZk4yolW5oZz4zwAnVgJj3Rx7qJgyEDx8/NZ9XD
         Q8qI9lOs4QPmgHpVwJlA/JyGpP/NJMQdsJ4XitUiJU5Px6/hL4i3Z9HDXYgLmYvduXaH
         /yAJcyVk0nj+3Y9DFsdQc4a0S6+XJg77dJcTREStLGqbgr5x/p37L1G/PEibb+C2mZfo
         QSN1icxeAVPF2XuNPNg1uJMFT+raFSZBCBIEaGkmGe1WbuZuNiIl882H85dnWM+0nzum
         AbzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vY+3ao+y9L7nD7alFgZQuTM3dt7AhOxf+8CD5umNl0c=;
        b=BjQP3u+BXLR9drquBxUtv7zpGc6mBvswaTAktFjMxI8fBc3+QqGRVv459yEsUS5Kv1
         2BDspuBu7UwCb/IFy5u04dd5s5x4iUqLeHJtmwrTBOSWWuiIzrnkaKLiP8CAtL4H7u+r
         OJWLBeaXBUnKaFOlDDJpfMm9nlpclaHWHL8x7LHvkhp/j7vIKJrjuHIMhYDZCZkb32J3
         mJUSywq3eWuuhI9e/w/g2UYwybIo58giv1lpcFH8o9aa+ycleyRsvK3I4fJC6KZmwT/4
         ZGm1gwC1xMt1NrHTWJeiCJ6RCeKNGLGGgmo3G3+ICe4jfIbK5M46hNmsrnJdAgBCpu/E
         MNuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p75wBFIH;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c26sor3013787ioa.5.2019.03.12.01.21.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 01:21:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p75wBFIH;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vY+3ao+y9L7nD7alFgZQuTM3dt7AhOxf+8CD5umNl0c=;
        b=p75wBFIHduU46nnfX3PfWxgXHU2UczcSHLsci5PTd8pJOinphS+mafVJFXZFS8m/Ru
         zZwI/MP8R/Fwi6XB98c0v5dyaJu+rcRcd0kc6v3a+uvdxjp6TlYZEW4q5Vp1NaNQWu9s
         C/0UzZqn/Ho8FLMWRcOY6fX07N7kO932r37SZHcPEUf+/v6q/6vBhoSJMDl9VEOy9A/t
         sWer/CTS/NWUv7+1NArnXf1IxjP7yE6iUt19VkzghtAOTwgM/9fzrF5u/9UyWWWv+528
         9Lg9zIx+2v07rQ3oHt2yEkcagd2WRmXaCEW+lT0fUDE4x7Bi5K/DcbS8WdKyYFFUTyKE
         GyYQ==
X-Google-Smtp-Source: APXvYqzAI+mcRf6cMfD+a+5cYvDqkAxUok6YQaU5YwpY3W70rbzad3FzsvWAXwjPwuejuQ76x1M4ZAckN9dTUbr+ksk=
X-Received: by 2002:a6b:3709:: with SMTP id e9mr9896355ioa.282.1552378881687;
 Tue, 12 Mar 2019 01:21:21 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000001fd5780583d1433f@google.com> <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
 <CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com>
 <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org> <20190312064300.GB9123@sol.localdomain>
In-Reply-To: <20190312064300.GB9123@sol.localdomain>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 12 Mar 2019 09:21:09 +0100
Message-ID: <CACT4Y+Z1rkS5bf3x9Y+0ke=zZ+mM2F5+vN-JtSQpjD09STRNdw@mail.gmail.com>
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
To: Eric Biggers <ebiggers@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>, 
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, 
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

On Tue, Mar 12, 2019 at 7:43 AM Eric Biggers <ebiggers@kernel.org> wrote:
>
> On Mon, Mar 11, 2019 at 11:25:41PM -0700, Andrew Morton wrote:
> > On Tue, 12 Mar 2019 07:08:38 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
> >
> > > On Tue, Mar 12, 2019 at 12:37 AM Andrew Morton
> > > <akpm@linux-foundation.org> wrote:
> > > >
> > > > On Mon, 11 Mar 2019 06:08:01 -0700 syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com> wrote:
> > > >
> > > > > syzbot has bisected this bug to:
> > > > >
> > > > > commit 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> > > > > Author: Shakeel Butt <shakeelb@google.com>
> > > > > Date:   Wed Jan 9 22:02:21 2019 +0000
> > > > >
> > > > >      memcg: schedule high reclaim for remote memcgs on high_work
> > > > >
> > > > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=155bf5db200000
> > > > > start commit:   29a4b8e2 memcg: schedule high reclaim for remote memcgs on..
> > > > > git tree:       linux-next
> > > > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=175bf5db200000
> > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=135bf5db200000
> > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
> > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > > > > userspace arch: amd64
> > > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
> > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000
> > > > >
> > > > > Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com
> > > > > Fixes: 29a4b8e2 ("memcg: schedule high reclaim for remote memcgs on
> > > > > high_work")
> > > >
> > > > The following patch
> > > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > > > might have fixed this.  Was it applied?
> > >
> > > Hi Andrew,
> > >
> > > You mean if the patch was applied during the bisection?
> > > No, it wasn't. Bisection is very specifically done on the same tree
> > > where the bug was hit. There are already too many factors that make
> > > the result flaky/wrong/inconclusive without changing the tree state.
> > > Now, if syzbot would know about any pending fix for this bug, then it
> > > would not do the bisection at all. But it have not seen any patch in
> > > upstream/linux-next with the Reported-by tag, nor it received any syz
> > > fix commands for this bugs. Should have been it aware of the fix? How?
> >
> > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch was
> > added to linux-next on Jan 10.  I take it that this bug was hit when
> > testing the entire linux-next tree, so we can assume that
> > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > does not fix it, correct?
> >
> > In which case, over to Shakeel!
> >
>
> I don't understand what happened here.  First, the syzbot report doesn't say
> which linux-next version was tested (which it should), but I get:
>
> $ git tag --contains 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> next-20190110
> next-20190111
> next-20190114
> next-20190115
> next-20190116
>
> That's almost 2 months old, yet this bug was just reported now.  Why?

Hi Eric,

This bug was reported on Jan 10:
https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
https://groups.google.com/forum/#!msg/syzkaller-bugs/5YkhNUg2PFY/4-B5M7bDCAAJ

The start revision of the bisection process (provided) is the same
that was used to create the reproducer. The end revision and bisection
log are provided in the email.

How can we improve the format to make it more clear?

