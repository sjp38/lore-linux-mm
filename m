Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB386C43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 11:47:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 864C3214DA
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 11:47:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="heKFGZ0d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 864C3214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2357F8E009E; Thu, 10 Jan 2019 06:47:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E3438E0038; Thu, 10 Jan 2019 06:47:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F9988E009E; Thu, 10 Jan 2019 06:47:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 971738E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 06:47:22 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id t22-v6so2690188lji.14
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 03:47:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2qXkOqTnBKSOzxBijAL8L2hMMKEeLSzTv8+NcatDO6s=;
        b=ubsRp7I2RCGhPVkrPjEW4c/U2I0B5rxj9nlWloncbKAYxrOyu28sylhK7HHVCl4aIC
         ya1Nj0Nf2Kn+EaXatsK7MMyV909VTrToaLypiWTytA+rEsBzJ0WeYcAzfUYhWCcYar8J
         TlluE5/vw5l5XUkmWjbj76IXMwBRtKIbAkocj61aolg6Z4I9yWqyspoe0IBeylgQQBKj
         2o9JS7r58ooLKvkb1cAIf8DP1EFt5idS9Mk661dnpkti5YaaxIgI3bQYbfFR5exgyi1q
         RZurLZOZp00uk0eqGyOpvOEoPv1MBCjwWUfZkjfeHmS769n/htgH3gEkRAk7Bi49ZkpQ
         NBPg==
X-Gm-Message-State: AJcUukdL+5t3vKEsJCe7jdoFrml12Q5I7qepzQc6++ljTsxpaLyrs0Ok
	m9TvOFUYGgW/m2UuPO03SW6tmSkzFN91NxoPEFZ86I60CRR40jCnFJeuRjzu22vkyiAS2r+pNJ1
	dE5M4ALMjm4M9AGPS9FnsbNqO/ST5WH+ig4wkPIfWMH4klVzgU+X3wrp+pt3SAEHjyQQTF+tjO1
	PKTn9xQgS6D+bIAEF/Y/gcK96Pw73xf8+Ru/x8FbjNYoUG4CZ1+YCzLkU1/sFEzVp+Bu5souASX
	VrEPADr3A84nSJhyL9h5wlo49twWVZWYpihTF8mJ/vif1xhKs696Y97cMsFoF7cU89XmVvD6hq4
	JwuCaxqgaUWFzxc9HHwn5qDzLiwITn777Lm4yl0m1AHzjw8DOhn6kR124sRvbGWOvaDaZhpe9DP
	9
X-Received: by 2002:a2e:484:: with SMTP id a4-v6mr5689283ljf.27.1547120841560;
        Thu, 10 Jan 2019 03:47:21 -0800 (PST)
X-Received: by 2002:a2e:484:: with SMTP id a4-v6mr5689239ljf.27.1547120840373;
        Thu, 10 Jan 2019 03:47:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547120840; cv=none;
        d=google.com; s=arc-20160816;
        b=EvsWQWw8GQoMo1CCPdcGlr2VjRHOunClzyWH7IGorOdi1KoxRDn9ahCTpsDBQG9tUZ
         /iX3GVnyYH+gnh8kGHkNwcUNgeVctJA/AQLxo+7uIqyKO76UR1dmFeT5MHTdBL0+Np2x
         2Y9c706j59m2eALZ1TaQ0DfYrQu98hnN1WpmMyNhCbMtGEaL+BpYBPRpUvO1nanuZR3V
         IQoBJVIKBx0EIaP9aBihCuMDAbLS//vZJDK4k/4z7Z7WRjwhhKRJED0sV3NuCd/nGjCi
         haBuuWg8MGPOfflW2fyfFlRKTtr4re97eiXCMGK9bEpyD9Pp3NHmMQ/C7cYX1a4oKzlg
         ZYfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2qXkOqTnBKSOzxBijAL8L2hMMKEeLSzTv8+NcatDO6s=;
        b=N1sbOCNFDlQXwRq4GQ0i8dsahfGkGmpJqUn6OWUrSv+LFIUuk5rbKsMwZyr3FYFDeI
         /e0QbQo4+9PN0W2zEKhLo49gKAHMVsIRUezWkW7v604lCgRLvyoCJWnfikw3BdBXxIoA
         lRX4bN7BTTPEB2rKe8M58kiJ1ZRZRaBrYf9l1MuDHf9bJa7DNQfmOOkTsZRZCZ5qo5mJ
         SELFk9Pwp2HZ321M6Uh8fb4aeXs2NKY7/qa0ds0XaUSrSWHgHBzhSbldy397u+1kCbX/
         KmjF34AXd/8V+yVhaoyJ2gD93Mf0phgP5MqxOoFFz1LUz8gbmqWDTHlnvMtECiTbfF8R
         yYDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=heKFGZ0d;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 65-v6sor36279409ljs.15.2019.01.10.03.47.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 03:47:20 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=heKFGZ0d;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2qXkOqTnBKSOzxBijAL8L2hMMKEeLSzTv8+NcatDO6s=;
        b=heKFGZ0dHc9drtpVWDCyKfCccI3cR2LapDVPQM5fKcQR9ZeVI/gAEDrUpj0YuugaSt
         T3OZ8Bi3W5/Yk8/h5yuv+q67dU5dXlR4QQNyuEYflvu+LShhI5chbNWQpZdK6xRK2wWz
         33fQoABuYZAPNriQ+jXXBAbmJLXJslnaTLn08=
X-Google-Smtp-Source: ALg8bN41j5QnYkNvNd+RhhcZD9Syhp/b5fe0ZAMVYgiKiGTnR1lAljDZJm2M/yy81d+mXGRIF9zNRw==
X-Received: by 2002:a2e:8546:: with SMTP id u6-v6mr5696731ljj.95.1547120839530;
        Thu, 10 Jan 2019 03:47:19 -0800 (PST)
Received: from mail-lj1-f174.google.com (mail-lj1-f174.google.com. [209.85.208.174])
        by smtp.gmail.com with ESMTPSA id g17sm15261877lfj.36.2019.01.10.03.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 03:47:17 -0800 (PST)
Received: by mail-lj1-f174.google.com with SMTP id q2-v6so9396575lji.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 03:47:17 -0800 (PST)
X-Received: by 2002:a2e:2c02:: with SMTP id s2-v6mr5799378ljs.118.1547120836837;
 Thu, 10 Jan 2019 03:47:16 -0800 (PST)
MIME-Version: 1.0
References: <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard>
In-Reply-To: <20190110070355.GJ27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Jan 2019 03:47:00 -0800
X-Gmail-Original-Message-ID: <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
Message-ID:
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dave Chinner <david@fromorbit.com>
Cc: Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110114700.leVMSRWSSwALxswBnqC6Je-PSQ5mo_OhtTaBxjgkdw8@z>

On Wed, Jan 9, 2019 at 11:04 PM Dave Chinner <david@fromorbit.com> wrote:
>
> Sorry, what hacks did I just admit to making? This O_DIRECT
> behaviour long predates me - I'm just the messenger and you are
> shooting from the hip.

Sure, sorry. I find this whole thing annoying.

> Linus, the point I was making is that there are many, many ways to
> control page cache invalidation and measure page cache residency,
> and that trying to address them one-by-one is just a game of
> whack-a-mole.

.. and I agree. But let's a step back.Because there are different issues.

First off, the whole page cache attack is not necessarily something
many people will care about. As has been pointed out, it's often a
matter of convenience and (relative) portability.

And no, we're *never* going to stop all side channel leaks. Some parts
of caching (notably the timing effects of it) are pretty fundamental.

So at no point is this going to be some kind of absolute line in the
sand _anyway_. There is no black-and-white "you're protected", there's
only levels of convenience.

A remote attacker is hopefully going to be limited by the interfaces
to just timing attacks, although who knows what something like JS
might expose. Presumably neither mincore() nor arbitrary O_DIRECT or
pread2() flags.

Anyway, the reason I was trying to plug mincore() is largely that that
code didn't make much sense to begin with, and simply this:

 mm/mincore.c | 94 +++++++++---------------------------------------------------
 1 file changed, 13 insertions(+), 81 deletions(-)

if we can make people happier by removing lines of code and making the
semantics more clear anyway, it's worth trying.

No?

Is that everything? No. As mentioned, you'll never get to that "ok, we
plugged everything" point anyway. But removing a fairly easy way to
probe the cache that has no real upsides should be fairly
non-controversial.

But I do have to say that in many ways the page cache is *not* a great
attack vector because there's often lots of it, and it's fairly hard
to control. Once something is in the page cache for whatever reason,
it tends to be pretty sticky, and flushing it tends to be fairly hard
to predict.

And a cheap and residency (whether a simple probe like mincore of or a
NOWAIT flag) check is actually important just to try to control the
flushing part. Brute-forcing the flushing is generally very expensive,
but if you can't even see if you flushed it, it's way more so.

If there's a way to control the cache residency directly, that's
actually a much bigger hole than any residency check ever were.

Because once you can flush caches by reading, at that point you can
just flush a particular page and look at the IO stats for the root
partition or something. No residency check even needed.

So I do think that yes, as long as you can do a directed cache flush,
mincore is *entirely* immaterial.

Still, giving mincore clearer semantics and simpler code? Win-win.

(Except, of course, if somebody actually notices outside of tests.
Which may well happen and just force us to revert that commit. But
that's a separate issue entirely).

But I do think that we should strive to *never* invalidate caches on
read accesses. I don't actually see where you are doing that,
honestly: at least dio_complete() only does it for writes.

So I'm actually hoping that you are mis-remembering this and it turns
out that O_DIRECT reads don't invalidate caches.

                Linus

