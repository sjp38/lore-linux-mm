Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F553C43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 22:11:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 466592177B
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 22:11:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="KhRR3r7/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 466592177B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6A408E0002; Thu, 10 Jan 2019 17:11:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1A568E0001; Thu, 10 Jan 2019 17:11:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0A558E0002; Thu, 10 Jan 2019 17:11:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60FDA8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 17:11:23 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id s64-v6so3133151lje.19
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:11:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KdjYJOzVCfeCe7Ioc9Rew5+ItUP7VYboNciWI+K3Sds=;
        b=WjV/9bhGi6jznXUxbQdRS5v8eV2voIOxEd6VuR4fSqgKcR5Wm/xU3Rmz/RWhObNIQ9
         DfWaAHll01DJjsHjERRJtoM++3gY+pC1I72L7IPuwfAu7n7LIS5Y3oPeXc7DrMJNqdUD
         IV2w82RFkbL2rkPYvdYyLe9IEwQQQIikK4/vNE2hMonvYIwM6Cs/+0K2hg8vZG1J3jHK
         tttpnmFVKO/xN920lYyG/BfV+zzVBebRbs4LW6qze4g8A9vC8128zFgObDwmZrSNbRr6
         ajNEiLB9OPZL07gmLuP+Z7tjC01g53ANoLgxuS4RPhxAkRFEkir2LkV/VPKIQqQ5Uc/1
         1lgA==
X-Gm-Message-State: AJcUukfsP01yd7Q5pn5HwtqFY/EkeBq5GkHkY+S4y0IUiAlDla7bKw7n
	tZYZ361JLR/375ggA/U2Yx56PaHb0zB3rBq9ppB8SjsIortsupPyzQTP/x9Pgv4yw9YMOsSEQHP
	+ns7eOk9RDJ35KGyiFkDa78pzW9YMt0Jgp+WaqPrH2GN2XeL/bJDDaNJ8SqEKghVxP6Lf35Fb+q
	iZ27M06DsNtEsGEGBymdVlxWfK2aph5OWKIVvl+tV+zMfCaYW9lf2ggvxcH0awXL/rkR+GW15iz
	zRngAy+PdULCFRAKGnkwTDRnwUPDi/5NcDyvS28leLa7sBweMFPhDn4Y7ubNfVqjTLEA+efgylg
	q9Mo23Kz4W5uiWwGltqbLta6ermebTa2AQAl5UG5tSnzCE58hVWIx4M9bA3HTQnxOlaBXuAfZsy
	p
X-Received: by 2002:a2e:45d:: with SMTP id 90-v6mr7020860lje.110.1547158282754;
        Thu, 10 Jan 2019 14:11:22 -0800 (PST)
X-Received: by 2002:a2e:45d:: with SMTP id 90-v6mr7020847lje.110.1547158281847;
        Thu, 10 Jan 2019 14:11:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547158281; cv=none;
        d=google.com; s=arc-20160816;
        b=IzAMvxLCX7HkUBtGpDT10o84O0oNR2bA+Dm8vRx1yju3BDd4tzovMEjU0cfr0ZHhWp
         TCz5ESuoKmDLxN0Os5C1zkVaYjB56GgJcXkQVQlUNVu/OGJ6UOydTN+zgSNE8HUG4YdF
         PfKRN8qxGMGYWMVDtaNXSM1+MVa0P2JJkbrnBc18zhWuyzWbCgvEYkZbzHJ+YEuu16Mm
         /vUhkmfDpzCmlJ8p8BaF3fJ/BYpHFt4p4hMar6SOqoLK/mK+cXsNe9ITgu3H9DjUHC/D
         8t72WLRRJQ1/zvfyBpSvqBtACENTy5MpP46ivpKpsMOsOpY0vJJ7AcRg1+O2g5WrHOY5
         OiUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KdjYJOzVCfeCe7Ioc9Rew5+ItUP7VYboNciWI+K3Sds=;
        b=ctlYUdhTNS5hyefDmpg9m5x5ODGJFsOeqnAGxbdDLwLkunDOU73FZt5O2gc1vBtLjL
         Yexp2PI+P9DAD9QQhRH3UgiFYTHwDhS7UXCKbutKJu33PyrpevH3R3Jrc1j5pzF6HaX9
         JJdN+xygjF/XgH/doLhsEv/cTbnkOww61Iaei7fIdrjz2mCcJiuPkVMLF8cI1JwGQY7y
         2IyXhLzFhdSP4HNAPo+I+ytxnunSoYyVXJfaZm/QUjQHwtwgeYoe0vsDE/g1703yDSRX
         XiWpjW9Yp5cL3IREWdfxe/GUq5S5L16Ry7BtaWfY9l+HaSjc4Rj/9U8U3zfEHYqoT5yG
         xYbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="KhRR3r7/";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5-v6sor43236408lja.17.2019.01.10.14.11.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 14:11:21 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="KhRR3r7/";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KdjYJOzVCfeCe7Ioc9Rew5+ItUP7VYboNciWI+K3Sds=;
        b=KhRR3r7/IU4vwsMRTlx7/FpGeUnljFFYP0hYBTUz4QVWaHAdSdKTw/lQbXmof0EGEj
         TayS4DnDVo3jFmlWfOFpykaa1rI/WTHvLiz+ec/+b21DRII6dRWVi+Wj2++9GTh/s+vI
         Iz+7cNVt44OrPCRyvjoBHNcVhXM38UQJuQ0cw=
X-Google-Smtp-Source: ALg8bN6kPcgZ1T2riOsJ2p7Pq8D3kiDSKOQqdZ/J32myC1kx3zMakNz9L2SPBylXWKZ3IsER5GwStA==
X-Received: by 2002:a2e:561d:: with SMTP id k29-v6mr3096057ljb.91.1547158281048;
        Thu, 10 Jan 2019 14:11:21 -0800 (PST)
Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com. [209.85.208.175])
        by smtp.gmail.com with ESMTPSA id g85-v6sm2061229lji.17.2019.01.10.14.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 14:11:18 -0800 (PST)
Received: by mail-lj1-f175.google.com with SMTP id q2-v6so11123097lji.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:11:17 -0800 (PST)
X-Received: by 2002:a2e:2c02:: with SMTP id s2-v6mr7100855ljs.118.1547158277491;
 Thu, 10 Jan 2019 14:11:17 -0800 (PST)
MIME-Version: 1.0
References: <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica>
In-Reply-To: <20190110122442.GA21216@nautica>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Jan 2019 14:11:01 -0800
X-Gmail-Original-Message-ID: <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
Message-ID:
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, 
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
Message-ID: <20190110221101.I4zRCwhPjQJEGcHJWkyCRJCuNFJBpVnyCxnZPQD_614@z>

On Thu, Jan 10, 2019 at 4:25 AM Dominique Martinet
<asmadeus@codewreck.org> wrote:
>
> Linus Torvalds wrote on Thu, Jan 10, 2019:
> > (Except, of course, if somebody actually notices outside of tests.
> > Which may well happen and just force us to revert that commit. But
> > that's a separate issue entirely).
>
> Both Dave and I pointed at a couple of utilities that break with
> this. nocache can arguably work with the new behaviour but will behave
> differently; vmtouch on the other hand is no longer able to display
> what's in cache or not - people use that for example to "warm up" a
> container in page cache based on how it appears after it had been
> running for a while is a pretty valid usecase to me.

So honestly, the main reason I'm loath to revert is that yes, we know
of theoretical differences, but they seem to all be
performance-related.

It would be really good to hear numbers. Is the warm-up optimization
something that changes things from 3ms to 3.5ms? Or does it change
things from 3ms to half a second?

Because Dave is absolutely correct that mincore() isn't really even
all that interesting an information leak if you can do the same with
RWF_NOWAIT. But the other side of that same coin is that if we're not
able to block mincore() sanely, then there's no point at looking at
RWF_NOWAIT either.

And we *can* do sane things about RWF_NOWAIT. For example, we could
start async IO on RWF_NOWAIT, and suddenly it would go from "probe the
page cache" to "probe and fill", and be much harder to use as an
attack vector..

Do we want to do that? Maybe, maybe not. But if mincore() can't be
fixed, there's no point in even trying.

Now, if the mincore() change results in a big performance hit for
people who use it as a heuristic for filling caches etc, then
reverting the trial balloon is obviously something we must do, but at
that point I'd also like to know which load it was that cared so much,
and just what it did. Because we did have an alternate patch that just
said "was the file writably opened, then we can do the page cache
probing". But at least one user (fincore) didn't do even that.

So right now, I consider the mincore change to be a "try to probe the
state of mincore users", and we haven't really gotten a lot of
information back yet.

              Linus

