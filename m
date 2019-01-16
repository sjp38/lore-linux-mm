Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9CDDC43444
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 05:00:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74FD920840
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 05:00:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="AoIGPgeI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74FD920840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 123438E0005; Wed, 16 Jan 2019 00:00:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D2648E0002; Wed, 16 Jan 2019 00:00:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F296B8E0005; Wed, 16 Jan 2019 00:00:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 829318E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 00:00:47 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id t7-v6so1288122ljg.9
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:00:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MyahoR9gA3cZPmJ4fRmUUg2fkKftA4/cTtIIntxPKm0=;
        b=LcaPET9JoHjf/0fM5So2zxMbiqqPYsulbdGC6rqPbJ04kWIkbkJ66ZoYn3JApQTJOP
         xY1u52yEf/OngEhb1kk0MhYqc0ZO5LkgtWdwwd5S9hmkGufTgxvZ52Ryrzq8RNmp21ux
         BerSLEuHmBesq2knUMaGe0VnuOMCn7JswSewvNZWsooGcg20nzQnyQ+xqF6UyrgH0g67
         PlgRe1tpZS30/jlhsuQMFGoeNLJ0PZqH4jfC5LJlXo8TbKjO3nheWI8eRqu/uVrTDzo8
         gkiSV5nL9LtfvYHoFgqKcB0smp+yw/qczAj6rK2WDImXz+4Z4FaVzP2MA/TtcK1esoFr
         PSdQ==
X-Gm-Message-State: AJcUuke69nyYnfUpRI6KvBbmcfGjQkejy+fcEti14/TdP7fRJAHji3jF
	aXlvQUBoREU3Eed1nTYG64y5AviPcqhMHbCb/EFkPQ5LINcRwFomf49mcehk9FNY3PFIG51rYaS
	wJ5C2NKyzjsBXgMH7Sh2540wVZ1sBND0UrK7Txo1XyIOgjzzCQ0YqvXHhyLrarL5j7Gb93++2iC
	LCNHH3xRHNfy1nF9BsslhTNRDlP/PnVdMbky9oSLgTFyhFW8j1tSrg8lypCU18lkvVPtDf8yb8Y
	8srtFn2PRRmL5piEaDsU2KIdAOdQ0ohrehvN9uF81f3Vs9crgxMYz/YBr09iNbw2nM7q+/dRmFj
	tOiEv4daiyHK+6eFxa8sGp9y1A4sEYyw2Hp9CHb6nEKADnTDGHbLaFch5QC5Z4DpabLnBE/nOmr
	X
X-Received: by 2002:a19:a104:: with SMTP id k4mr5416009lfe.36.1547614846817;
        Tue, 15 Jan 2019 21:00:46 -0800 (PST)
X-Received: by 2002:a19:a104:: with SMTP id k4mr5415931lfe.36.1547614845400;
        Tue, 15 Jan 2019 21:00:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547614845; cv=none;
        d=google.com; s=arc-20160816;
        b=XIqKrpP3Fur0Lq58/SF0SSUh7F5FHCFkdH+lzj6GCr+Hw4DtQMxgApbVlAaQKSzjwo
         jpZhmO2QhXRAqy907e0ZAZ8tCtThPYN0WoW5VM+9t6hGPhyrFB5Gwy1qHADUqw1dUp+g
         TgpwFuoOHDfaW9KpGUZTSFSWQM7TbGm07GnYPRmC1rkgqGj2NUgiCPaMN7d/lCL20Yy+
         Uk+QpDQ+eICBjDXiDscNiJvRSEky+dS/scCvSX7kimGwQFwAJxWz3wYoPnH0StrQbQgY
         Pu397bysgkKy4oPm9TJKP+Tr+EsoaXXSEmapP//UhPtgF6IJ4fosFiBRvBZ+DdULdRw/
         GKDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MyahoR9gA3cZPmJ4fRmUUg2fkKftA4/cTtIIntxPKm0=;
        b=kFyUzPe51LxB9DXMflQtjGKMJPeYcGi9ZBe/I78hXkUNUEk8aAzeZijtAypHrX0njJ
         t1b+ti/H31mtMl3xr+u39gwQiSCNxuxShb9OQSjVGQcW7gZejRoNY4oHGojEXGvld2QL
         /vsSjf2+lZuuXMRK0fsa2SDWoLAlVXI0fk/UU5LCrmkky7rNquLKo0Ozz8vHC/xwF2Ui
         oG4N6EzJlR2DOHdgFgm8UwQyYymUJLB3p4AALd4bf+JytsyxxLeB5dFA4EyrY88Rq20b
         bgLXtq0z1pMvhUVS9exYaBfgzy1zMzD/Mu05Y8CUs8mPgERxRNCs0SQ1vOEGx1Ou34k2
         HmUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=AoIGPgeI;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1-v6sor3887548ljj.2.2019.01.15.21.00.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 21:00:45 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=AoIGPgeI;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MyahoR9gA3cZPmJ4fRmUUg2fkKftA4/cTtIIntxPKm0=;
        b=AoIGPgeIUOnsX1DPPQIz4mINWsh4eAVO7IZuYdn9y4NELoNnTOraTGcibFzGsdnWQu
         kZll5DLe2ClnMoYrsv4IXeCv2kriiDIwHXaVU6mcbZKXlqLHoeZXdJtz+8Islp9hHoGC
         sy7X+9W6kpegaZwAxwmWrxB6j8+30F1v7C9/U=
X-Google-Smtp-Source: ALg8bN6WeKy4U2Emlw1FxxuCmCZ71brJ0j1n9fVzoYiOKuI4CxipIxesnEmly71OuF4mqNsAscaLQA==
X-Received: by 2002:a2e:1603:: with SMTP id w3-v6mr5159282ljd.33.1547614844236;
        Tue, 15 Jan 2019 21:00:44 -0800 (PST)
Received: from mail-lf1-f41.google.com (mail-lf1-f41.google.com. [209.85.167.41])
        by smtp.gmail.com with ESMTPSA id f1sm972363lfm.22.2019.01.15.21.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 21:00:43 -0800 (PST)
Received: by mail-lf1-f41.google.com with SMTP id l10so3828407lfh.9
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:00:42 -0800 (PST)
X-Received: by 2002:a19:c014:: with SMTP id q20mr5034140lff.16.1547614842100;
 Tue, 15 Jan 2019 21:00:42 -0800 (PST)
MIME-Version: 1.0
References: <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com>
In-Reply-To: <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Jan 2019 17:00:25 +1200
X-Gmail-Original-Message-ID: <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
Message-ID:
 <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Josh Snyder <joshs@netflix.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Dave Chinner <david@fromorbit.com>, 
	Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116050025.o2T9xY0viSUp26dUgn1eGiIfChP_HvZSJ7dinVpWGJU@z>

On Wed, Jan 16, 2019 at 12:42 PM Josh Snyder <joshs@netflix.com> wrote:
>
> For Netflix, losing accurate information from the mincore syscall would
> lengthen database cluster maintenance operations from days to months.  We
> rely on cross-process mincore to migrate the contents of a page cache from
> machine to machine, and across reboots.

Ok, this is the kind of feedback we need, and means I guess we can't
just use the mapping existence for mincore.

The two other ways that we considered were:

 (a) owner of the file gets to know cache information for that file.

 (b) having the fd opened *writably* gets you cache residency information.

Sadly, taking a look at happycache, you open the file read-only, so
(b) doesn't work.

Judging just from the source code, I can't tell how the user ownership
works. Any input on that?

And if you're not the owner of the file, do you have another
suggestion for that "Yes, I have the right to see what's in-core for
this file". Because the problem is literally that if it's some random
read-only system file, the kernel shouldn't leak access patterns to
it..

                     Linus

