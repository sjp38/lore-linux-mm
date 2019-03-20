Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F08CC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:59:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3E2E2184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:59:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="N342nwjK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3E2E2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 516A16B0003; Wed, 20 Mar 2019 09:59:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49DBA6B0006; Wed, 20 Mar 2019 09:59:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38BB66B0007; Wed, 20 Mar 2019 09:59:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 109416B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 09:59:32 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id h82so880378ita.7
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 06:59:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RmyQwrFyANnSrcI13I0okPnI4JkfyNY2bxu3oBrzm78=;
        b=kVbj/zZtrecxDJk9M3TX8wiJZtOlfPMoB1N+yolIhVQvyqHSaIDiV1bZzPRfkKnX0w
         r6YR/r1gvEb3fnQA2ZnZV1ggohZLwCyJHIZOANfeXapHln0DccfOMms+r74Oqtj6Bh7i
         GFL00/8NbD7T32ThZ/qXSdjsXX7mUwYpX9SEYvk3kGEu6ODhQ+KYPGFQLqbHbW/trSvm
         UOn4Rj6VhRleA+5LPXHjPyYeWxjqkzajwN10Th/0Dx8jWPokyjnRdkqjO3Kp3mIYFKn3
         YYXsXJTUI3nJNg6KVtkA2pOQM6fHYgRG91aFATsTnyiUDKgo8/El7BNHNM7wsDakDfyr
         5EPQ==
X-Gm-Message-State: APjAAAXP4UgUh8cH+xGn4zHtvPyeohWqybMsPGKA62RB+05UHSZHoGfG
	Hvzr3nrUngv6iVaI0NJqE6dZR04p5F7ptrzFRIXm9PAE6h4jL38b/HdFdghx5TQ0xOdTFdZFc0r
	KK1Pba0PYucLEEtmq1Tn/67g0OiDYT+NOkZ2pMQfvc2pQkFKBzMGX+BZAe1XzzkBzPQ==
X-Received: by 2002:a5d:9b01:: with SMTP id y1mr5273527ion.167.1553090371880;
        Wed, 20 Mar 2019 06:59:31 -0700 (PDT)
X-Received: by 2002:a5d:9b01:: with SMTP id y1mr5273500ion.167.1553090371245;
        Wed, 20 Mar 2019 06:59:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553090371; cv=none;
        d=google.com; s=arc-20160816;
        b=itax8VX4uMxEJ2Obdkyo6MVvvo7quhpwkCbq3mvXoU87ngjvzKFthpU38P52PICBi8
         50QRo19jVvtAvgSx8qrNriyG8zz+yciFeT8IXhh/pVstgiJfxLAr7gb8NbLZGI5kQDwq
         qMc7oxLEBH4H1X8SkA8WMc+p/l6hPQuZAfWHKng+HkYsR3gnKDwL+A/QdRU8UDMgDgO4
         p7mq76GeE3xXbdxIdCVbITh/E2zMXwFtO0DlwHz07dNxn+AnYDXGwM64nPhBWC3m7jtz
         JtUF+/jZ2BA3HZCCCFZoMgoKm1DaNnAUeTbu3XxV2HuUAFgx/Y0naSLXGn+7chaa8GqQ
         oqng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RmyQwrFyANnSrcI13I0okPnI4JkfyNY2bxu3oBrzm78=;
        b=mX/P+rt7IBUWB3NwdXPlHIKQWWa1MgBAjQTwDy8KZOy3+jHYwA/f2mn6rym5G7VFKA
         iiXcK8AXfx1nVSLflIiraJBsv4OmM/3dRsiG7HjJZvV6y1pk6GpjjHCDrvap0xXz9aAD
         Ovj0NwVM8ixwsfTMSp35ANIoSiBuiqMrEZJMSC6UTK/A83cXRIV64qMDHn4BNkmjhLVI
         WfolGsDjHDK5gLoxzXS10Kl76UcTzULY4o7m6H7PCZyK+Io20MZYW9c/mueOtznhJBoK
         l/gM3X9DQ+9lYPT1T3l0wJ6ozTjzVmLLVoSFzNMTCYkX+ieEueEKPuRBLnt+sRNeLVzZ
         5cdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=N342nwjK;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor4184680itl.35.2019.03.20.06.59.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 06:59:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=N342nwjK;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RmyQwrFyANnSrcI13I0okPnI4JkfyNY2bxu3oBrzm78=;
        b=N342nwjKC9kyYqwey8dFejLjpIkuXozr0myM+P8RkqmPaV7dCdfBDx2pJgzdacZXYh
         sdRgK9YZNmvOf0NM8s5KID3i1mF06uQS/AZ/mijuKM0nDEc39KKyK2nHX7eo0QhLu20N
         N0LtP3Ph+8fa3PcMZ+s3o8yZnOf03A0ZHVSy1XkYyvnsQLNhqCE7ue0fbROaiFJ4tEpM
         Zdqwkxs4WvURgbd+NdTmakQwU/g3XSnti2C1Vrz8RL1uoPz0qxBId4DyRRcyokopoAVY
         Lyy+dmy6ZHP7719ZexaUn+i9Lc3QUi+utZIWGGhoEPdPrb2usUFyYbs5oqgq3dFtokXz
         vkHA==
X-Google-Smtp-Source: APXvYqzmn4bsPUjYN021O9lPARoRSqq2hf2Uw0i66O47FvP6bUygASSf2713Fh5nTZ9abgbg96YVy3cVWltNfiB6YZA=
X-Received: by 2002:a24:3281:: with SMTP id j123mr1444952ita.166.1553090370724;
 Wed, 20 Mar 2019 06:59:30 -0700 (PDT)
MIME-Version: 1.0
References: <000000000000db3d130584506672@google.com> <d9e4e36d-1e7a-caaf-f96e-b05592405b5f@virtuozzo.com>
 <CACT4Y+Zj=35t2djhKoq+e1SH3Zu3389Pns7xX6MiMWZ=PFpShA@mail.gmail.com>
 <426293c3-bf63-88ad-06fb-83927ab0d7c0@I-love.SAKURA.ne.jp>
 <CACT4Y+Zh8eA50egLquE4LPffTCmF+30QR0pKTpuz_FpzsXVmZg@mail.gmail.com>
 <CACT4Y+Z2FL=t8cHceXMGvG2QfChKdJYprVvBonu9X+jJaL0HMQ@mail.gmail.com> <a06830e7-e396-6dd5-d9d5-2a7b1df9efc1@i-love.sakura.ne.jp>
In-Reply-To: <a06830e7-e396-6dd5-d9d5-2a7b1df9efc1@i-love.sakura.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 20 Mar 2019 14:59:19 +0100
Message-ID: <CACT4Y+b-VNeKwgP9-x2YZJ08v0f=2C2SujVkgEmcQ+B-ZmmCLQ@mail.gmail.com>
Subject: Re: kernel panic: corrupted stack end in wb_workfn
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Qian Cai <cai@lca.pw>, 
	David Miller <davem@davemloft.net>, guro@fb.com, Johannes Weiner <hannes@cmpxchg.org>, 
	Josef Bacik <jbacik@fb.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-sctp@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, 
	Michal Hocko <mhocko@suse.com>, netdev <netdev@vger.kernel.org>, 
	Neil Horman <nhorman@tuxdriver.com>, Shakeel Butt <shakeelb@google.com>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	Vladislav Yasevich <vyasevich@gmail.com>, Matthew Wilcox <willy@infradead.org>, 
	Xin Long <lucien.xin@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 11:59 AM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/03/20 19:42, Dmitry Vyukov wrote:
> >> I mean, yes, I agree, kernel bug bisection won't be perfect. But do
> >> you see anything actionable here?
>
> Allow users to manually tell bisection range when
> automatic bisection found a wrong commit.
>
> Also, allow users to specify reproducer program
> when automatic bisection found a wrong commit.
>
> Yes, this is anti automation. But since automation can't become perfect,
> I'm suggesting manual adjustment. Even if we involve manual adjustment,
> the syzbot's plenty CPU resources for building/testing kernels is highly
> appreciated (compared to doing manual bisection by building/testing kernels
> on personal PC environments).

FTR: provided an extended answer here:
https://groups.google.com/d/msg/syzkaller-bugs/1BSkmb_fawo/DOcDxv_KAgAJ


> > I see the larger long term bisection quality improvement (for syzbot
> > and for everybody else) in doing some actual testing for each kernel
> > commit before it's being merged into any kernel tree, so that we have
> > less of these a single program triggers 3 different bugs, stray
> > unrelated bugs, broken release boots, etc. I don't see how reliable
> > bisection is possible without that.
> >
>
> syzbot currently cannot test kernels with custom patches (unless "#syz test:" requests).
> Are you saying that syzbot will become be able to test kernels with custom patches?

I mean if we start improving kernel quality over time so that we have
less of these a single program triggers 3 different bugs, stray
unrelated bugs, broken release boots, etc, it will improve bisection
quality for everybody (beside being hugely useful in itself).

