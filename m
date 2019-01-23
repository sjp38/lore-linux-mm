Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90912C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:33:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D05E2184C
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:33:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="g7TozyAr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D05E2184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE1818E001A; Wed, 23 Jan 2019 15:33:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB6DB8E0047; Wed, 23 Jan 2019 15:33:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65F38E001A; Wed, 23 Jan 2019 15:33:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 547888E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:33:37 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id j8so263514lfb.14
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:33:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SDfZ035GKrH1GIAaUIA14ZhvfHWjaHvHCf05UvEOp58=;
        b=hgAEKfMI3z64T/peKfQD92cu7noHDGRXsr6316eTviRJ7REYqblA3MPMJa2pvUxAlT
         7RuihSF8ri8IBb01uiA+QkTPZ6P4DalPUPKZq+BcIZAWOqV8wFhBE/Ogc9ZLNfsNykhO
         u335LRnauYBgPDkjch04pfxyS/AyOAJ0fCD0H+NRp3qpHAG5T5FyMXOxaEO9pqkgFb85
         lTDdMX2Ov/Co8/gTJnCXttdBf+FE4jH/nrE74wxzHwjDbuSzb7UcyPoWoKmghjAodxnL
         mTKj5hvTHhDcq5ksLXrKG7naJvQXVgc4Nbk/a78IW8UEKL+3F0c//QfMNR6uQhWUlmyc
         o+/A==
X-Gm-Message-State: AJcUukdJ3uuG+6Ng7Jo/wvBSORRaKgPuiBAiK7fZrGCIlmblNWrAvrOG
	8tbxwASdULVf4S8LK+U5G79mPHIUj0GmzfUGWQx5YOXoZe9q7YQRnu0/VOpS3YCibui5PJQJH1t
	urYth/Q07mkDnnAgAJOlqUtG6ZW1DGFHEUxsM5yaL97nZYnZlqnCGs8MCi4Mrx6cllf0ir7rgZR
	Z5U9TaHtwK+vVpwy0nUV+uKj/PXH5upy3BY6Zm/XiQbcUvF7sQ0BVqwL79XO1Yh+BdG/KDL9Dsh
	R/3C4HoD6uaKGYwFqpOeJSot3q6yX7g5tH+6s/KOTe+2Q7+JqMYjbKb3kiebCMxeqsWc+7TjKG1
	WlgMzMxewQtZna8yKFmk1KStkpA+zwr9lyZK2Pm5PsmipLivmwe1dAU12Y2cl43DYsf6vwXjk19
	r
X-Received: by 2002:a19:7dc2:: with SMTP id y185mr3119826lfc.27.1548275616258;
        Wed, 23 Jan 2019 12:33:36 -0800 (PST)
X-Received: by 2002:a19:7dc2:: with SMTP id y185mr3119784lfc.27.1548275615193;
        Wed, 23 Jan 2019 12:33:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548275615; cv=none;
        d=google.com; s=arc-20160816;
        b=r1o9Ijp9k2vjXvhN7W3w6xqkbmaYEKUBomYYI4VFh+L9sNZ4rwQKWfZdDfIf3/HHql
         Omjt9t6LsHcxVPQ5fybx1gl7J27MKId+NokAS5PO80n/hebzlwptd5uKDWP3gD4KJrOy
         2ddK3XQXdEmDjWwvWHxzsuK8RWyVy12VlAoeBKvtBLdgLrNTQl4LLSIObXPz5Er+d198
         6iPwP78g0kElGYAWYouBAChHAZe9LGERuowiOyHgq3wn/LpmGbGDeDKx2vrp2esWT50A
         5bJ858/Jm2hM/xJoAfHSF+iSUESdy2ObakNvscBSl62Vu2HSMBFCpCS8bu3FAEYyJM0S
         Pk0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SDfZ035GKrH1GIAaUIA14ZhvfHWjaHvHCf05UvEOp58=;
        b=lHEQQtCDnkfnVwIATkb88C2O0atl7uaua9KTqSPkGBGXV2Zo/P0ZMTIoo/FpHM6aQF
         fMhGk6zDWIRTEsMjFkimLOsp+sZmNJYN2Q2jjND46K34So0ztiicf8CpFf1emZZ3gK37
         8YIqUf4nH51CbfyEGMYw4d5dqVuv+XGCLKMgE3JMrmD2YH+uXuShbAGCdH3MUEnc7UOB
         dy7+sp0NC56scgZYBdsvKRB19WjjiAmgUK5NICdMZkciMMSNtDU2kyw9LRchW3fRq693
         YA7IGmWueIsmlGNXsFsu7RADIuIycs1gJNYRjvRYhX7/4BLmO13CV5shBqkRNZr7hcCT
         sxPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=g7TozyAr;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z22-v6sor3164504ljb.22.2019.01.23.12.33.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 12:33:35 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=g7TozyAr;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SDfZ035GKrH1GIAaUIA14ZhvfHWjaHvHCf05UvEOp58=;
        b=g7TozyAr/TjlyP/pj0UDRVzDDsvR3kAUFSxxPmVW5Kf+mSJT0VpQZ2TFgJ0xW0gsNh
         JeEA2KmzeYsEySIspPK22HdB9Dx9Fo7UXTKXBgFtm/fQBocUpVYGoSXmaEqGv1nLKa70
         wpaoxnVihOxqnAcYAIt6fmk0R5xaGGxsN83rE=
X-Google-Smtp-Source: ALg8bN5TMLydeOOr3gVPRXb1l0xU6QEn8ErqPKrLIs5EEUqP/QX5Boi5fy9qDXCTY3aCtgu5BuMo7Q==
X-Received: by 2002:a2e:5816:: with SMTP id m22-v6mr3034193ljb.177.1548275614153;
        Wed, 23 Jan 2019 12:33:34 -0800 (PST)
Received: from mail-lj1-f173.google.com (mail-lj1-f173.google.com. [209.85.208.173])
        by smtp.gmail.com with ESMTPSA id x16sm636728lff.26.2019.01.23.12.33.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:33:33 -0800 (PST)
Received: by mail-lj1-f173.google.com with SMTP id k19-v6so3152600lji.11
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:33:33 -0800 (PST)
X-Received: by 2002:a2e:9e16:: with SMTP id e22-v6mr3213844ljk.4.1548275258095;
 Wed, 23 Jan 2019 12:27:38 -0800 (PST)
MIME-Version: 1.0
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm> <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
 <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Jan 2019 09:27:21 +1300
X-Gmail-Original-Message-ID: <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
Message-ID:
 <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jiri Kosina <jikos@kernel.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, 
	Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, 
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123202721.-_fyy1BBw01cofQCleAxkNugTVXX0tzpiFtOxWHXZkM@z>

On Thu, Jan 17, 2019 at 9:23 AM Jiri Kosina <jikos@kernel.org> wrote:
>
> So I've done some basic smoke testing (~2 hours of LTP+xfstests) on the
> kernel with the three topmost patches from
>
>         https://git.kernel.org/pub/scm/linux/kernel/git/jikos/jikos.git/log/?h=pagecache-sidechannel
>
> applied (also attaching to this mail), and no obvious breakage popped up.
>
> So if noone sees any principal problem there, I'll happily submit it with
> proper attribution etc.

So this seems to have died down, and a week later we seem to not have
a lot of noise here any more. I think it means people either weren't
testing it, or just didn't find any real problems.

I've reverted the 'let's try to just remove the code' part in my tree.
But I didn't apply the two other patches yet. Any final comments
before that should happen?

                     Linus

