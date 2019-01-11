Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0BADC43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 02:18:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EC4120879
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 02:18:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="JYnWAo/N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EC4120879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17B828E0005; Thu, 10 Jan 2019 21:18:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12BE78E0001; Thu, 10 Jan 2019 21:18:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01AB88E0005; Thu, 10 Jan 2019 21:18:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 858068E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:18:38 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id z5-v6so3289799ljb.13
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:18:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IwEmlRGwHdJ7O3lGFYJW+jg6ng3jN91JyPi2+zBjdEs=;
        b=HA+IaR2nRmJK5cJJIDnWBuLE3sxnsSNYXZGuGh1sRGZp1tXMs8rmziqyUVk5CJuu5n
         0GDF509mg9aLwCWmJZdXcP/Fu3EIQB/Ku2IgV/jFP6lWVX5dt4SPAZ3FeWMke0Qf6pg7
         oZz5YKvPA1u5u63MzDMzaVAwCVWZpH7BsEudFr0WST75swgQRQS6rRNdBcE1upwrLGOT
         t2LnHvEj3Ntic/Cm/qPWO/koyP/FnZ65GPXJzLLifAa/BuAsXm7AhOIEBRG3pirM/BNg
         p8AUoVX2tHDt8WzsFNBl1/eNnSxDgd5qTHKvuhE40scrMsFb+tq3g3sWtNnVCjeNvgVM
         ZYgg==
X-Gm-Message-State: AJcUukelM0v3Ay78Frh+eNcHm060fZa7jmhtCdJdvbtx7TIWlLL6Ca5J
	FqdaEtoiW2DQ1qFvR1Bipnwr9MGQVSb9F2ptNrCkY4v+ziRMaFiiIhXnaq6zVOngsttjMpP1db8
	7XSh205CdH+N3lOersLXpUVOvsNwu7RQ5oAUZYgytobVR1LGCYNzOIW6Zubfba7IrA5W+Eivfgw
	1snLYTPDCJTUqUV1EKpC5D1gzpXqUs4w3MOh0Z7mvxGZrSuGnlNBynq7phsefdS3dXEIWpuo+cS
	0j4Y0GIxluzAnbyr8zIzBOoRI/5QZ6k4G8QPfWO5ad4cP+UVBKJoJ51CSYo4DlylrSwjzVNxqJD
	RwdetLXoicufxHBjibX1BiS4VsZGV+hPVrl/x6JfJs4G80gjYSdKy7kJo06A5gg51tgPmtFhlqz
	/
X-Received: by 2002:a2e:97d7:: with SMTP id m23-v6mr8036178ljj.18.1547173117745;
        Thu, 10 Jan 2019 18:18:37 -0800 (PST)
X-Received: by 2002:a2e:97d7:: with SMTP id m23-v6mr8036160ljj.18.1547173116749;
        Thu, 10 Jan 2019 18:18:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547173116; cv=none;
        d=google.com; s=arc-20160816;
        b=LO8CFg19NbYuednUeC2Rka5WJ9cSaUG+UBquA87KO6kCrVSAgA7y1pZloEnQZdq8Ij
         BS3le3B3V8UPtvT0Kc3Qb4sFPyjVhPVoBw+725bGyiOiDDBCG3DD6xSW+YZp6lwRcmSZ
         kDJH+2O6lUHLSA8SXER1XdS1f0usY4Tsp8i0azceuk8sCeKghLbQ+1F5l8CzFw1oinhJ
         kmg/w6PP6W+taZcwv4+jk6EiQDZQ5ongagqOQOqFjN5itbEdraGZpqercxl9NqiZ9NvL
         +uv431boCsMmlCGZz0wVu7BE4i3L9e0F+Fs6xGCuzFf98zq92I+zCldLXRODCSckCjxh
         ohUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IwEmlRGwHdJ7O3lGFYJW+jg6ng3jN91JyPi2+zBjdEs=;
        b=GvRxiQpQLUcdt1mhyKrF/vUh6Evgy1bGNPxRvwm3gCWKDncnmi+8eWv7ltH8bjqjMH
         0PElP+UpbvV0gV3FVkj+mVsTzHodZq3atUZbxGWwJduSdlahBSa+a3ljKnO9lV46vbqf
         5ib6NTbl+wMAxxqHqKw3V8QBqlBdiMdMThaKlDxaWaRb6SBrBMKdXPRfVu4BSmon3la6
         qEkPuwjgdczGW/9acF25ZOZ3irAhrReBJpgSe/ieIfPVt9/t6KsADTexs51CucDjTvju
         F0Xq9H81zsw0WqyighyYIaOCxi/aktHx+EggaPbvC1pbM4cL0gp5VeYNghK/W90OAU1N
         +SqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="JYnWAo/N";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z26sor19803458lfe.67.2019.01.10.18.18.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 18:18:36 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="JYnWAo/N";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IwEmlRGwHdJ7O3lGFYJW+jg6ng3jN91JyPi2+zBjdEs=;
        b=JYnWAo/Ni7M01k1aLsyCYKOAVaGuikAGimbR96ifjilXyAixrlW/S6dIFIVldFUuB7
         P+oQbm8rz/de5ONsQm0c9mbnLfseb9TIku0uKKxLtZSkOBWe884bL5INJqxLEYT4fa70
         wA3/Al5RSSgoTSyRpLPgS0Qum1NPASPXYVyls=
X-Google-Smtp-Source: ALg8bN6DDfBqAw4wEKHByt1RbtMG//r3vbURSlH7WtA1rzoXIhlyjFJZ0lJfJzdLTfb0JdxLAU4zSQ==
X-Received: by 2002:a19:59c2:: with SMTP id n185mr6709296lfb.118.1547173115578;
        Thu, 10 Jan 2019 18:18:35 -0800 (PST)
Received: from mail-lf1-f49.google.com (mail-lf1-f49.google.com. [209.85.167.49])
        by smtp.gmail.com with ESMTPSA id c2-v6sm15484755ljj.41.2019.01.10.18.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 18:18:33 -0800 (PST)
Received: by mail-lf1-f49.google.com with SMTP id y14so9711860lfg.13
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:18:33 -0800 (PST)
X-Received: by 2002:a19:6e0b:: with SMTP id j11mr7540441lfc.124.1547173113051;
 Thu, 10 Jan 2019 18:18:33 -0800 (PST)
MIME-Version: 1.0
References: <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard>
In-Reply-To: <20190111020340.GM27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Jan 2019 18:18:16 -0800
X-Gmail-Original-Message-ID: <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
Message-ID:
 <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dave Chinner <david@fromorbit.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, 
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
Message-ID: <20190111021816.7ktUwYG_a4PXwr8hFkTfsW-qIVW6zmfVk9C9xmrOHd4@z>

On Thu, Jan 10, 2019 at 6:03 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Thu, Jan 10, 2019 at 02:11:01PM -0800, Linus Torvalds wrote:
> > And we *can* do sane things about RWF_NOWAIT. For example, we could
> > start async IO on RWF_NOWAIT, and suddenly it would go from "probe the
> > page cache" to "probe and fill", and be much harder to use as an
> > attack vector..
>
> We can only do that if the application submits the read via AIO and
> has an async IO completion reporting mechanism.

Oh, no, you misunderstand.

RWF_NOWAIT has a lot of situations where it will potentially return
early (the DAX and direct IO ones have their own), but I was thinking
of the one in generic_file_buffered_read(), which triggers when you
don't find a page mapping. That looks like the obvious "probe page
cache" case.

But we could literally move that test down just a few lines. Let it
start read-ahead.

.. and then it will actually trigger on the *second* case instead, where we have

                if (!PageUptodate(page)) {
                        if (iocb->ki_flags & IOCB_NOWAIT) {
                                put_page(page);
                                goto would_block;
                        }

and that's where RWF_MNOWAIT would act.

It would still return EAGAIN.

But it would have started filling the page cache. So now the act of
probing would fill the page cache, and the attacker would be left high
and dry - the fact that the page cache now exists is because of the
attack, not because of whatever it was trying to measure.

See?

But obviously this kind of change only matters if we also have
mincore() not returning the probe data. mincore() obviously can't do
the same kind of read-ahead to defeat things.

              Linus

