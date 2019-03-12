Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1446FC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:50:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8F3E217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:50:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="WI75ufy1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8F3E217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 361F98E0006; Tue, 12 Mar 2019 18:50:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E80F8E0004; Tue, 12 Mar 2019 18:50:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 189F98E0006; Tue, 12 Mar 2019 18:50:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C45CB8E0004
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:50:48 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o24so4301875pgh.5
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:50:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/J5pv/PXUZKO2DfzJMVDk64qpeQyxFR3lWRXS9vvA1A=;
        b=AEIffX4zBn8jchABhZfO2cbGHp7bIvNeUZwIHdm9yI3PtDekGo3QFQkfY1YliTGBns
         VFw73446CQpsL3g/myzwmISrwWKKmDsIG8zCJECNcio1T4h+s2BNHCbOBEvR+5pRA8H4
         Gg7ZOPAcGqjf2Ar5mocoMgq+kSF+WoWSSO4Z67ELxzlw6nlBqIF4ERsqubuQRMoD7Yr8
         XiJjm9RAQKJRIC46IdZh2Li3oRlQh1e4MUkTjpHayfioW+hiNuj1S471S1lfQw0QIL0B
         ocquRoxLJw7QcC8uNVQA0d4kfDZ3/GRMzmWOn576qmiVkk1cTK9oo6tQJWiACYdoRaGt
         YA8A==
X-Gm-Message-State: APjAAAVCwDVWjpzXGhxmMElKXnqaWZwsVZphpDnpFotJ9aggc3SYL+r/
	JzjX8MszhCAdLVIjLKqhoeMa1iIo3cZ+ct6QPC2XgGWA0dz68AkIucKkL8hT1oPGI0/MoAS97EP
	fK+SZMzhMo7I4QZtVsLIoi+3o3y1bkxNlBaym9sQZlanMDLB5kSS4Fvd19d5o7wpQow==
X-Received: by 2002:a65:6259:: with SMTP id q25mr37528217pgv.235.1552431048462;
        Tue, 12 Mar 2019 15:50:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRHH519oKBoC7KQ/cQ/Ru0IA5yhmUNl1XxStUuuOTYZmht4CgpGsW0XH/R+GQLCscrrK1r
X-Received: by 2002:a65:6259:: with SMTP id q25mr37528169pgv.235.1552431047318;
        Tue, 12 Mar 2019 15:50:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552431047; cv=none;
        d=google.com; s=arc-20160816;
        b=Vp6HKCQGvb5SQZp66yb1BPfLchuwmvIb3hhpleBGEHitJQobZ2CrNWqJfxumZenWP2
         HzzshK+2S5R0K+gYb21iG7Sk5NZGoDCT4zaDv0DFif6kS5On8WC64czZHh4ahlE27i5p
         4z1azh/Y6J8b5i3iyFZrbttr9nsAYTLxOM73Byfadhvfc4VgYKQ/H9qwzmsIh36tu1/2
         DDz0LIKzcaXjstb4y8lapvVlUFTjpgRjDxgC6xsLqLtK8jRIvmtkj9Qmic/JpJO9BuFx
         wxGBWafGwwe/Lz7sL2D9mC8DZxkEcpqpBCvPoaevXLvW8nH4gu+2dZmVzw4N0lqYcXLD
         E37w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/J5pv/PXUZKO2DfzJMVDk64qpeQyxFR3lWRXS9vvA1A=;
        b=HwbpvsYWTXmXQp9Pd8FMn1RK5JFrP6jrI+jbjezVzsE5EZkBIViHG9/sgQ9cUq17c7
         EDFNwaTtebJfDuPJscrTZw28Q8xGPjr1Mjc9M0B8XD8Z22E7LpCiaAMlT2HfkS1uU6As
         9iljUOhFBXFYEJstYQFbL8ix7IciLdg0lL1MkCgsYk1lsOXBJwPVXgV3GRjtpr0Er+PO
         CSb6ci2hObot+mKCdK5UpIwVyeszv5x+wJvFNQKpXKRjb5AIhkzct5ZS3NNDhzdHzJTb
         gwUeAODdKbFeDPijaCcivl/th45Cx20lljgc6swYlymzR/HC8Ouu08Cnz3c6Wam0FvNh
         TbCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=WI75ufy1;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q189si8937985pgq.240.2019.03.12.15.50.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:50:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=WI75ufy1;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from gmail.com (unknown [104.132.1.77])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 969802173C;
	Tue, 12 Mar 2019 22:50:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552431047;
	bh=H2SqJeE+y1P2YXu+7abpBuG3U7knmwVGClUEEzGKm3w=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=WI75ufy1hZo+4KK7O8P0jt7seWlKSWrjoWTa/uQQECh43hQ3PzVLjza0hvUrQebQu
	 XRNMnsoy68/EmZrCMF2SsthxKPeD/Yl1Yz+Z2hRZIB/IH9h6AeFFj8izhMtJcB3Kif
	 sWHWpH8IIEJzqJWyT3UDqaKTUCsfrR69lil9LQLA=
Date: Tue, 12 Mar 2019 15:50:45 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>,
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Shakeel Butt <shakeelb@google.com>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
Message-ID: <20190312225044.GB38846@gmail.com>
References: <0000000000001fd5780583d1433f@google.com>
 <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
 <CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com>
 <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org>
 <CACT4Y+Y0JdB-=yLLchw8icokn11iH2-XYoLJEOFKm6F88fJ3WQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Y0JdB-=yLLchw8icokn11iH2-XYoLJEOFKm6F88fJ3WQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 09:33:44AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> On Tue, Mar 12, 2019 at 7:25 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
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
> > In which case, over to Shakeel!
> 
> Jan 10 is exactly when this bug was reported:
> https://groups.google.com/forum/#!msg/syzkaller-bugs/5YkhNUg2PFY/4-B5M7bDCAAJ
> https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> 
> We don't know if that patch fixed the bug or not because nobody tested
> the reproducer with that patch.
> 
> It seems that the problem here is that nobody associated the fix with
> the bug report. So people looking at open bug reports will spend time
> again and again debugging this just to find that this was fixed months
> ago. syzbot also doesn't have a chance to realize that this is fixed
> and bisection is not necessary anymore. It also won't confirm/disprove
> that the fix actually fixes the bug because even if the crash will
> continue to happen it will look like the old crash just continues to
> happen, so nothing to notify about.
> 
> Associating fixes with bug reports solves all these problems for
> humans and bots.
> 

I think syzbot needs to be more aggressive about invalidating old bug reports on
linux-next, e.g. automatically invalidate linux-next bugs that no longer occur
after a few weeks even if there is a reproducer.  Patches get added, changed,
and removed in linux-next every day.  Bugs that syzbot runs into on linux-next
are often obvious enough that they get reported by other people too, resulting
in bugs being fixed or dropped without people ever seeing the syzbot report.
How do you propose that people associate fixes with syzbot reports when they
never saw the syzbot report in the first place?

This is a problem on mainline too, of course.  But we *know* it's a more severe
problem on linux-next, and that a bug like this that only ever happened on
linux-next and stopped happening 2 months ago, is much less likely to be
relevant than a bug in mainline.  Kernel developers don't have time to examine
every single syzbot report so you need to help them out by reducing the noise.

- Eric

