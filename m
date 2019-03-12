Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7AC4C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 06:25:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6290A214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 06:25:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6290A214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 002D18E0003; Tue, 12 Mar 2019 02:25:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF51E8E0002; Tue, 12 Mar 2019 02:25:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBEB98E0003; Tue, 12 Mar 2019 02:25:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 95A578E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 02:25:46 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p9so1896180pfn.9
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 23:25:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pr7iF7Z3mbzuavO3NWhe6jyYOPO4Th/QcLpOpa3l9dc=;
        b=V/CUoeEbFKZpdBjyll3OkSu6DxycLUvGHhXdiKYQgjICIcePGW+gNTyN0Oz60dTfOs
         1xcwM8FIa5O8K44KmhNM2KcUYt06A8M8IlxKTAfPV2fx/MqyXobKRaekFT5eNrXPiiRH
         h31LfVV0uisiBNWgiUYSP51rQzwOWcDxJ/Rq8A9ppZNAD4MI8r67TIhWqVbpRP5z2l6D
         Ul9Ex3E02MKqL/qEpb2mEFOX950gH5k2PQrS4XPUjMvfJEor28t06StcK7E55ERj03iJ
         bIXop5EYh4ruF7NuXRnYfxfnrh9AIf/R1o0B7ioWWQHdZwKGZddkUiIMXw/7AaOccJER
         vgeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAU0prNKjBq3zO82FPx+k+RePJK3v9cQDs1Tj9KT3jNhYptibSuI
	0sNTt4mUMcnI4ruYjldR+xF5kYlGm2Z4OLlgeRrU6IlFmu+3nlk161+iE5T1e/1ez7Oy4hmDMwX
	090CJBHAZuYYnM+W/DWKHvWtJYZJ+b+FCA+SUTjlrrl8hnzKKdsjAstVGyCHMs44k8Q==
X-Received: by 2002:a17:902:7b90:: with SMTP id w16mr38864449pll.228.1552371946196;
        Mon, 11 Mar 2019 23:25:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwmE4360GjMOxnnWoXv8Ysic8YTQRQ9HHN1OB3Tle1VkmArdnVCFzzu9fXDHbkcwXmF14u
X-Received: by 2002:a17:902:7b90:: with SMTP id w16mr38864399pll.228.1552371945231;
        Mon, 11 Mar 2019 23:25:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552371945; cv=none;
        d=google.com; s=arc-20160816;
        b=UsBLzsoZNT9S0EqBkSWPjvQh2uxRRaJJ2K7b6N382h9d8WJP71Su2JvA3vkcwcHGHt
         NMpU60vdev+Xv75dMmBrUPohsqHZ1E3UWSBKiiiBcPS1HTiX9zaR8efUAhitsP3ynEli
         C+qqxjbMSSxSEtrl3wlLPBOpozNMEvMY9JCi7rWgQp7jepZ7uYP4c7S+mm05qp7g+T23
         THFf2BbZhJVexB2qzAfSoBsXPwlJ3FIMUgRvYur6b7xg6Kx8UqbneNI1H0br4kFziCeP
         LxO5fBBwGvKn/98lJYHTaPz0isZEWKuJfzrVqCnkQQK9BNgKv2kh65AeWYcwBCcP8ENl
         kwIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=pr7iF7Z3mbzuavO3NWhe6jyYOPO4Th/QcLpOpa3l9dc=;
        b=u/bbGohLkaPfTG751LJnDpsJrNv2vL6aeEu9qP+gNLBS2CXwkblxiRE+ucVAbkJlVi
         hWsCfubzLFxPZE7e5gbXSFmA+SWArcCKl7SUJaL/nWoocNk0I4hngbr9txbyjmq85inv
         Hgcz1f94qb2BCGT72FPRVeNTKURWwQnx9vUf9kpLPnQ/IMbBND9XJf/a2ocQ+p9ADlYB
         jKLlP855VeAu561slwOyn3M0ClpjZ5XEtnTJXVJ2RX9DRMsz5tv7fFSOyTuPo104sglY
         44nt3f9n/Imz61pSkLEj7Kb881tsifVaIhdx4rx4SLFXqH1CPPJq55K3PqFAbYnvY9/i
         /jNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k3si7352359pfb.100.2019.03.11.23.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 23:25:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 60EA2B1F;
	Tue, 12 Mar 2019 06:25:44 +0000 (UTC)
Date: Mon, 11 Mar 2019 23:25:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>,
 cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML
 <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko
 <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Stephen Rothwell
 <sfr@canb.auug.org.au>, Shakeel Butt <shakeelb@google.com>, syzkaller-bugs
 <syzkaller-bugs@googlegroups.com>, Vladimir Davydov
 <vdavydov.dev@gmail.com>
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
Message-Id: <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org>
In-Reply-To: <CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com>
References: <0000000000001fd5780583d1433f@google.com>
	<20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
	<CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Mar 2019 07:08:38 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:

> On Tue, Mar 12, 2019 at 12:37 AM Andrew Morton
> <akpm@linux-foundation.org> wrote:
> >
> > On Mon, 11 Mar 2019 06:08:01 -0700 syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com> wrote:
> >
> > > syzbot has bisected this bug to:
> > >
> > > commit 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> > > Author: Shakeel Butt <shakeelb@google.com>
> > > Date:   Wed Jan 9 22:02:21 2019 +0000
> > >
> > >      memcg: schedule high reclaim for remote memcgs on high_work
> > >
> > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=155bf5db200000
> > > start commit:   29a4b8e2 memcg: schedule high reclaim for remote memcgs on..
> > > git tree:       linux-next
> > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=175bf5db200000
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=135bf5db200000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > > userspace arch: amd64
> > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
> > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000
> > >
> > > Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com
> > > Fixes: 29a4b8e2 ("memcg: schedule high reclaim for remote memcgs on
> > > high_work")
> >
> > The following patch
> > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > might have fixed this.  Was it applied?
> 
> Hi Andrew,
> 
> You mean if the patch was applied during the bisection?
> No, it wasn't. Bisection is very specifically done on the same tree
> where the bug was hit. There are already too many factors that make
> the result flaky/wrong/inconclusive without changing the tree state.
> Now, if syzbot would know about any pending fix for this bug, then it
> would not do the bisection at all. But it have not seen any patch in
> upstream/linux-next with the Reported-by tag, nor it received any syz
> fix commands for this bugs. Should have been it aware of the fix? How?

memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch was
added to linux-next on Jan 10.  I take it that this bug was hit when
testing the entire linux-next tree, so we can assume that
memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
does not fix it, correct?

In which case, over to Shakeel!

