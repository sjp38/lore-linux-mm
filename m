Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47056C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 06:43:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBB352171F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 06:43:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AaclTBN2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBB352171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AEE88E0004; Tue, 12 Mar 2019 02:43:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 636B98E0002; Tue, 12 Mar 2019 02:43:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D77C8E0004; Tue, 12 Mar 2019 02:43:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05B0A8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 02:43:05 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u8so1941545pfm.6
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 23:43:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xoKTdDeoefPWLlK1k3iQAyj1U/2H8/k6tFhnehatSn4=;
        b=VuVSJsTbWXV7XP4cg681oGevpyAHAwnpl6OwrnU6UkobuuMNF3qMAQU8xbEbbCzeyn
         EexrRxK+taz8zxxiUCqNObNIjqGTKa9rOLRgHeefjOcyvpB0ufN1YAovvixKeGGsezsT
         rYnqUun90R4PEhU9rStpvd9XUsGPrlJaVZTw857JOM8AtAEvCOSsSGS5zau5BIjszUkd
         OciACXMgGXB03d4Cj4UmowAYGuH/KpDLBiOy14IcUPndKQDKhQuObFHVHgfmY/vMvWEi
         5lCqAB2FIs62yYI6lYedA/tcYXtinnto7REUlE6tHXRwWtAA1ebfTAnuingurUISStqJ
         lY6Q==
X-Gm-Message-State: APjAAAX61agMqzIqGEaUzdYQDSjWNL7dtmyeFpLKQclES9Q2U5yO3VDk
	RLWwdk56ODjPOJHi8LDiWMpP+ekmR6gi6ZZEOUTR1NLTc49op+b0yucTV5zb+Cvkq41R0gqhBw4
	QgmXAgZuwVHruxXav2uo69GwrhuM/xu6yrbOY0Xe8xJr1XCdcGjtHmySQt9m7OocQtQ==
X-Received: by 2002:a65:6299:: with SMTP id f25mr4803421pgv.376.1552372984577;
        Mon, 11 Mar 2019 23:43:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOHy+8d8XsCpcpoUq0YB0r4v5onTjSRiWs6SPHNotgt5/+RhaCjk2t+T1apEOO/CymM1Nn
X-Received: by 2002:a65:6299:: with SMTP id f25mr4803358pgv.376.1552372983417;
        Mon, 11 Mar 2019 23:43:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552372983; cv=none;
        d=google.com; s=arc-20160816;
        b=KH5+F5pf71bAgrCi6GjefKluH3p7bKmXcOVoLcsx3VzbHy7ZpQ/asfWpVbd4Ok6uKs
         pW3xlWQop1BaqNip/g1eCpYF0fx/8wDEt0BmXe6ZGnjxAqjLKFJgQWXh5qCtfOtNsr8F
         nN28ZNFE3WjSy3YyuCeJhoQfxnZ8ErLb4GcCgN70eQ0wMc/2/CoqI6XZilmmJ7RoemHq
         6oydFJB/PkLiAkSxP8SWTcR+ERbGirPrpp7dN1Q71ePoKVDm7N58fEg1vz+VNf4uw0TZ
         s0DFuHcssecCYz6Z3IJ3hRdC34AjWWJKfebtiXJX0Li0QmDdZcSlCgYq3NryxYTDgClO
         Pn2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xoKTdDeoefPWLlK1k3iQAyj1U/2H8/k6tFhnehatSn4=;
        b=BCm/qD07kpGWffNs3c/htOyIjF/9NhQxJrvxlj8eaLxqycSNsUPEXRSCouW38ReUbg
         puvSPAHn7v4CKm0T0F7YOOI/WCS12IQziNByIZwqfgiMay9Wp3t1xPAruLsgTq7rCdTS
         TCPQFrAukiAIheCAt3V3jaOG+IqaUZ7hPNW8Xe2DbMwQ2bSSnIDDutMC6PzHZZW9RKZG
         6FEpRBOaITfFY1K8CtDa8NpTdLCSYTNdgYO2Y9fRKFRa4IZ7cnUmshUh7EhQFxGPBdhE
         Lt5Qdi559+QCJwJE0Ouzz5se9mtn8LkFxIkqj+pXIjszV8P4v+zJEO4Fy3JQEzsIvcQX
         rW4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AaclTBN2;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z11si6829069pgu.306.2019.03.11.23.43.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 23:43:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AaclTBN2;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sol.localdomain (c-107-3-167-184.hsd1.ca.comcast.net [107.3.167.184])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7B0D52147C;
	Tue, 12 Mar 2019 06:43:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552372982;
	bh=jxAV6M9Y1tiLlySENmdFKTVIH3Zk5cbYOZ5tGGV6+Q0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=AaclTBN2B/9MbxUhA9MLSSCiEisYs+XLajEA/etj97TINtw4kykiOzEiY1EPoc8j6
	 wYBigPOZtOTpkJykEee/KzWHKpMreZoBTZJl50r+yN4fJllvh72LA/0yq2XMfaXkg9
	 /QxxS43KvUtxLh0rftYSHFeG4hFDgiHdrzYJOmJk=
Date: Mon, 11 Mar 2019 23:43:01 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>,
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Shakeel Butt <shakeelb@google.com>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
Message-ID: <20190312064300.GB9123@sol.localdomain>
References: <0000000000001fd5780583d1433f@google.com>
 <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
 <CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com>
 <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 11:25:41PM -0700, Andrew Morton wrote:
> On Tue, 12 Mar 2019 07:08:38 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
> 
> > On Tue, Mar 12, 2019 at 12:37 AM Andrew Morton
> > <akpm@linux-foundation.org> wrote:
> > >
> > > On Mon, 11 Mar 2019 06:08:01 -0700 syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com> wrote:
> > >
> > > > syzbot has bisected this bug to:
> > > >
> > > > commit 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> > > > Author: Shakeel Butt <shakeelb@google.com>
> > > > Date:   Wed Jan 9 22:02:21 2019 +0000
> > > >
> > > >      memcg: schedule high reclaim for remote memcgs on high_work
> > > >
> > > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=155bf5db200000
> > > > start commit:   29a4b8e2 memcg: schedule high reclaim for remote memcgs on..
> > > > git tree:       linux-next
> > > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=175bf5db200000
> > > > console output: https://syzkaller.appspot.com/x/log.txt?x=135bf5db200000
> > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
> > > > dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > > > userspace arch: amd64
> > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
> > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000
> > > >
> > > > Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com
> > > > Fixes: 29a4b8e2 ("memcg: schedule high reclaim for remote memcgs on
> > > > high_work")
> > >
> > > The following patch
> > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > > might have fixed this.  Was it applied?
> > 
> > Hi Andrew,
> > 
> > You mean if the patch was applied during the bisection?
> > No, it wasn't. Bisection is very specifically done on the same tree
> > where the bug was hit. There are already too many factors that make
> > the result flaky/wrong/inconclusive without changing the tree state.
> > Now, if syzbot would know about any pending fix for this bug, then it
> > would not do the bisection at all. But it have not seen any patch in
> > upstream/linux-next with the Reported-by tag, nor it received any syz
> > fix commands for this bugs. Should have been it aware of the fix? How?
> 
> memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch was
> added to linux-next on Jan 10.  I take it that this bug was hit when
> testing the entire linux-next tree, so we can assume that
> memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> does not fix it, correct?
> 
> In which case, over to Shakeel!
> 

I don't understand what happened here.  First, the syzbot report doesn't say
which linux-next version was tested (which it should), but I get:

$ git tag --contains 29a4b8e275d1f10c51c7891362877ef6cffae9e7
next-20190110
next-20190111
next-20190114
next-20190115
next-20190116

That's almost 2 months old, yet this bug was just reported now.  Why?

- Eric

