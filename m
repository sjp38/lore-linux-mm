Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CF6BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:46:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AC1A2147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:46:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="amrURANU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AC1A2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8ECE38E0003; Tue, 12 Mar 2019 09:46:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89CA28E0002; Tue, 12 Mar 2019 09:46:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78BC28E0003; Tue, 12 Mar 2019 09:46:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3B18E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:46:12 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id f67so3445645ywa.6
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 06:46:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Z9o+ZRkqKfziSen8lPKKS3g4b+sPcaG2W3T+6uzEH9g=;
        b=eZk6Ejo1CJ5+altOv0T3o0NqiK1xg96rGEJs/DDGThVGC5CR46jvOY+gTfWE7ZdowD
         ASVJLX2Q2rNMj06j3W0ojUiyRHK5N3DOU5BAm7n8R5A5t1/tVGqU2uBNBPhLvMcpqt9k
         lOFASr+0eiSP3hm8gqrE+ijkEi79VdJES87AG+xOr7YN7X6GZI+Z+XFUs4MFhdCuo+bi
         sJEskqlERhJuuqmDnGHlAdMmgnwBEqZP6WCPVPpPyGv8fQYo6hxDUeRwJXAmMW0xgl4n
         KjEPqNRaZhXCfueaktk3BoFlRzV08Ex7j8CAGQUR1sgAO6K03xdKztGEUI12SZNP+HZ3
         nv5g==
X-Gm-Message-State: APjAAAUxyFzgdu4A7OkETep4UfCcciAkV/mHlZkEC5zMmRsE4ZYJQRP6
	EvX/rnXclz4dBI4CuvZpyoEtDO1a160FE/auBblwOnYfG4yG5BdPORFcBri1wJnMcGPDvkPH7dj
	eYyBZjhkiI4ngQmBGHNN1FHhUJSaiaWHJNOhYmvpZiV2v95egTeH2/1EBodWU5u5k8OBNwzGh+W
	VmkgU75U5Tp19FU7yjlPeKIWzAJetEqXPTE3V7gCwq/Diujd1Rq4+TAFGnTSlpHdFyDtTtad3aL
	UB0Nn61Pi6xJojaZ4ZNBaLmMkSLWWjrxZco+ZBW0PA3pEklm48y+TvpDt0Y0IJGT340X4yshw8i
	b1k4zl6+K+WWsvCIUvBaO/SfqC7/NJlvwK3xPraNStb+HeUCUqCDPG7IW6QXSEYcwiNM7tkv+nr
	O
X-Received: by 2002:a81:1a03:: with SMTP id a3mr28998827ywa.429.1552398371933;
        Tue, 12 Mar 2019 06:46:11 -0700 (PDT)
X-Received: by 2002:a81:1a03:: with SMTP id a3mr28998762ywa.429.1552398370980;
        Tue, 12 Mar 2019 06:46:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552398370; cv=none;
        d=google.com; s=arc-20160816;
        b=qBD/X2UtBZDbLy6kWXXgyJBBlzS7vozTIck12oUrgp933Ecs62GUqAkd/hbDv9aRZw
         ID4rySBILwRcp81cfSibIVI2DtRl6yM5WYIvIl3+WIAsKmBZl2Ezj5UDSRhtRANdMDdK
         yUrcehKGLwvTTHJJXgZU3ig3C1M1SrQE8aKFJjlpu7QiI3TDUSniIG/lPaDWWDct87Tl
         AB2Au9RTi84tmvDtD8DUIvNPabXiWvWdxSrNRMpci4PQ5dtYWT9iKY79++lNd7QDMlyK
         MgG4y5qkQ73rS7Lx1wmd0hl9ogTdGTq5jjmrNq57Dw2wuJJiLUF7++fT4ZidTnEuT/8U
         01Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Z9o+ZRkqKfziSen8lPKKS3g4b+sPcaG2W3T+6uzEH9g=;
        b=SZtT8CgpIPNYTAHTyWqjiNZDbR0Lm6hiNm1wE7yZqcAL4OnqRgmMGYv8uv/YHwbgWh
         R5S0zY9znI2AESybPi1JSkLiqe34hVRRXJOzffcvpfD7OJuJqPbyB2RyS5nL7P/9RCDj
         dKQP6X5i9PBDNVIA5boVvyFNDctOuP44LCBPpwIT+n8Z4/v2HDCiWF/VzyhHJoNJ3Y8J
         FaCDWKMB++6mik0GB9VamLLLWERfdPhHu5CG8Jqu3QO6MPQqzUxzZp+r2atMF6nlgmSr
         QbkU0JWEa0lGJpfUhCKX8ulZByo6/YgMjWGz9dQAdn8qXjwke7Pujq6FkksFO0Ee9ekA
         On/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=amrURANU;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o19sor1168021ywo.66.2019.03.12.06.46.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 06:46:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=amrURANU;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Z9o+ZRkqKfziSen8lPKKS3g4b+sPcaG2W3T+6uzEH9g=;
        b=amrURANUVN08ADXnnxxWasXpOUxyxp5dMTdRZhdlsTUqBXurp0Ma56c+nJgxdfQT/n
         4ob3IR3dt/041CJFWuyoaA/uB8WxO80ry2YKSeP9161NGGaP4Wine1dexnni0CyVc/ni
         pTmH8h465/sg6DwmTjSlkCD7m//oju951OCmBnucU8KgD6sC/abyjeO1uFQhYlZ1HF8A
         54d2nDMKPt2BBatRrIcfjCVXYiW4DeBd1e2WhjcXKSvyihEhAAauyWtIFZo1Mb3IZKFp
         2r8dIFMD+e9GHO8RgMcSxc+x83llphU0mksSc97Sne5pyDxu9oqrsi2KHijTVx/pDlu3
         W3Gg==
X-Google-Smtp-Source: APXvYqxLVjwTbEkLiEnQqelf1e6ZM2Rq3Ip9doTY9hdELEmrtmkYxYbEwYx9rIiOkqWDr5yTI5jssibFJwLhnlXV4mE=
X-Received: by 2002:a81:a047:: with SMTP id x68mr29403501ywg.349.1552398370146;
 Tue, 12 Mar 2019 06:46:10 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000001fd5780583d1433f@google.com> <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
 <CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com>
 <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org> <CACT4Y+Y0JdB-=yLLchw8icokn11iH2-XYoLJEOFKm6F88fJ3WQ@mail.gmail.com>
In-Reply-To: <CACT4Y+Y0JdB-=yLLchw8icokn11iH2-XYoLJEOFKm6F88fJ3WQ@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 12 Mar 2019 06:45:59 -0700
Message-ID: <CALvZod6ADEHE4_gFpod-gmXz0h3WjoOZE+cN2BCG20ORb2V5Qg@mail.gmail.com>
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>, 
	Cgroups <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 1:33 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>
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

Should we add "Reported-by" for syzbot reports on linux-next patches
as well? Please note that these patches are in flux and might be
dropped or completely changed before merging into Linus tree.

Also should syzbot drop bug reports on older linux-next trees if it
can not be repro'ed in the latest linux-next tree? IMHO yes.

Shakeel

