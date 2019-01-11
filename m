Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83B97C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 16:26:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32D012183F
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 16:26:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="A7k/Kaiz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32D012183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C46528E0003; Fri, 11 Jan 2019 11:26:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF6798E0001; Fri, 11 Jan 2019 11:26:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE56E8E0003; Fri, 11 Jan 2019 11:26:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42C068E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 11:26:36 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id t22-v6so3881398lji.14
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:26:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vbenFxntMJJI3im+gr+rLb3/45Dw0c7ONogM+YwDZXY=;
        b=K4e/7aaGt4KsSeeI6lJiqhkOnQyGv3SegZ029ffcLjGvokDdlVOSAfSLgGlkF4z/bt
         OQXNHMtAibYH0AO593UHfXdFvF2xOF/e7c8w728zkeYiRDrFzLFj3hH+drerewe2fWOC
         ZHxARUmzp80MBczIKiBHoMqiElQ5h14xrbGzXEogN2cQFF2sQZEjhIYkRxHKFoFxA3Ew
         4wP+PplzLZ5Zt2jdokSUh+ShJE8BmrFV0RrRkmsoQCmvs7DUSbVtmxQ3mhO5YJLNRQxc
         GZRJxwvmqm8Dicb34mHWuTbSL9EC+51xsyjDPJSB5x2mKDGj3h7YH2ySw95FiOyvTNvX
         as4g==
X-Gm-Message-State: AJcUukdv5zbh87AZqLf5dksYmbNimrVTSSqv3nc6PTE9w7U4y3kOM4FT
	g1AH2Gp3868Clxg8ugm3oArHuC2+Gk39qILTdKmXmtkqOocDSzmPqzFUO9kSBC4UMbgbSPh4sma
	0//1L7SaM3W4n/Vr6UpB7WqXh/lGLFOcbavrqyE8VZruOj7RBZqqaCauH4to3ga5HlDcSq3CuB2
	lBd3yBhZsEwUjHjf1qWrhuXNNVghDNhm5B2hr1cg8jsSOv4wlzq/UR55zKzN8j9EFiDKubZngv7
	Q8/WFwDXuSFBoAYuguq2Ha1BwUPrGhPvP1Y7kJflmnITjYgz7X8FqMEGVUHuxCl4F2IMUrKo0YY
	rznLFfBVTFNqGYsdiNv4bHnIFliG5OzBpMrhfK2yn+L16KQZ7LL11PAyRzDaefu5A3r8e/dZ3KL
	R
X-Received: by 2002:a2e:5b93:: with SMTP id m19-v6mr7671314lje.115.1547223995622;
        Fri, 11 Jan 2019 08:26:35 -0800 (PST)
X-Received: by 2002:a2e:5b93:: with SMTP id m19-v6mr7671260lje.115.1547223994246;
        Fri, 11 Jan 2019 08:26:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547223994; cv=none;
        d=google.com; s=arc-20160816;
        b=czf+goJKFHV3ugOSK9XLAmbWDfwPjAMeQujfEOFqIh/7BK7rR/W5f9YQDB/N6jSf4J
         2BKae6hf1C0UaDjU0IhYZwh5xIcDsVq99L1Ms3rR0Km1eS4SAiPzj6wxHOTeBLgUeeU9
         lvbLyzTiV308iB58doFviITIZlIcfSTJBsbi4aAxK2sah7K1HHuSqv34lL5QLPWYxd8f
         rJ2lQ2g1PrH4zHboLIrFf33UFBNqA3guUpJN+VKBGe9I7Q5x74qlGlTihY4Zd6h7lJX6
         qF4+L1CmgWpkkp9yTTgKUEcTHsgDu63+uLCdSomkKTqx9cFa4JESBQORgk5babIa1iHC
         0Ypg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vbenFxntMJJI3im+gr+rLb3/45Dw0c7ONogM+YwDZXY=;
        b=ZqM5phr3e2DYOW2nOF2ilTI5/VePl9PsGvYf8wfXFbMN7xTwRtj+i8mQcqaWP1XFAK
         Y55bPlO4sPCsTkK0Vb0eIQbWC0aPpIduE5WzgSMv2T7XgZGCXTPuH00Xzl8Isg8IQbU7
         g5QQjJlhp536IQhJOKM1cNF+F+zZoDLXAt76wwHVp1q5cJtRzvZMBLND8q0IJuMmxLdw
         06UdFDeko+dFWYwX9ghY+ZQOE+hh27vHatauxiqDR+V1HjSWZHQF1LPoyINX3x8fEwHE
         hbST4UQ3pd6QLt1brubxQcpn/D8Cj9DICBuMNbktslpcGFKNOfpaExxc5lAaMek0msvn
         QhBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="A7k/Kaiz";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10-v6sor44640343lje.8.2019.01.11.08.26.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 08:26:34 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="A7k/Kaiz";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vbenFxntMJJI3im+gr+rLb3/45Dw0c7ONogM+YwDZXY=;
        b=A7k/KaizozfTI3rBrlvY3irlDJ5TfkFn1JQLsJSc13ang98zrx0HocnODrct6I3zRv
         sXlVINnsBzbxsJRy2F0R8MOI6FDB9D8UqJgkszbOp9fTU/2qZpfc5E3qRvfiuagKxYTH
         khvqSsnfI7FaBQLpIXqdntBzaFT9jEEhlEHik=
X-Google-Smtp-Source: ALg8bN5swoOud4RsC/XQhe3NDmYknpJeZ+My+LMszx5AjaRioNjRyaTO9YghKHMJq3BvJLya/abzRQ==
X-Received: by 2002:a2e:5356:: with SMTP id t22-v6mr8521951ljd.26.1547223993015;
        Fri, 11 Jan 2019 08:26:33 -0800 (PST)
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com. [209.85.208.170])
        by smtp.gmail.com with ESMTPSA id m4-v6sm15560999ljb.58.2019.01.11.08.26.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 08:26:31 -0800 (PST)
Received: by mail-lj1-f170.google.com with SMTP id v1-v6so13467276ljd.0
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:26:31 -0800 (PST)
X-Received: by 2002:a2e:310a:: with SMTP id x10-v6mr9708846ljx.6.1547223990982;
 Fri, 11 Jan 2019 08:26:30 -0800 (PST)
MIME-Version: 1.0
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard> <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard> <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
 <20190111073606.GP27534@dastard>
In-Reply-To: <20190111073606.GP27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 11 Jan 2019 08:26:14 -0800
X-Gmail-Original-Message-ID: <CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
Message-ID:
 <CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
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
Message-ID: <20190111162614.Sx6jlVG-VNZBAsNXe31UURRdaX_T1IRYkRhwwg7sTuw@z>

On Thu, Jan 10, 2019 at 11:36 PM Dave Chinner <david@fromorbit.com> wrote:
>
> > It's only that single page that *matters*. That's the page that the
> > probe reveals the status of - but it's also the page that the probe
> > then *changes* the status of.
>
> It changes the state of it /after/ we've already got the information
> we need from it. It's not up to date, it has to come from disk, we
> return EAGAIN, which means it was not in the cache.

Oh, I see the confusion.

Yes, you get the information about whether something was in the cache
or not, so the side channel does exist to some degree.

But it's actually hugely reduced for a rather important reason: the
_primary_ reason for needing to know whether some page is in the cache
or not is not actually to see if it was ever accessed - it's to see
that the cache has been scrubbed (and to _guide_ the scrubbing), and
*when* it was accessed.

Think of it this way: the buffer cache residency is actually a
horribly bad signal on its own mainly because you generally have a
very high hit-rate. In most normal non-streaming situations with
sufficient amounts of memory you have pretty much everything cached.

So in order to use it as a signal, first you have to first scrub the
cache (because if the page was already there, there's no signal at
all), and then for the signal to be as useful as possible, you're also
going to want to try to get out more than one bit of information: you
are going to try to see the patterns and the timings of how it gets
filled.

And that's actually quite painful. You don't know the initial cache
state, and you're not (in general) controlling the machine entirely,
because there's also that actual other entity that you're trying to
attack and see what it does.

So what you want to do is basically to first make sure the cache is
scrubbed (only for the pages you're interested in!), then trigger
whatever behavior you are looking for, and then look how that affected
the cache.

In other words,  you want *multiple* residency status check - first to
see what the cache state is (because you're going to want that for
scrubbing), then to see that "yes, it's gone" when doing the
scrubbing, and then to see the *pattern* and timings of how things are
brought in.

And then you're likely to want to do this over and over again, so that
you can get real data out of the signal.

This is why something that doesn't perturb what you measure is really
important. If the act of measurement brings the page in, then you
can't use it for that "did I successfully scrub it" phase at all, and
you can't use it for measurement but once, so your view into patterns
and timings is going to be *much* worse.

And notice that this is true even if the act of measurement only
affects the *one* page you're measuring. Sure, any additional noise
around it would likely be annoying too, but it's not really necessary
to make the attack much harder to carry out. In fact, it's almost
irrelevant, since the signal you're trying to *see* is going to be
affected by prefetching etc too, so the patterns and timings you need
to look at are in bigger chunks than the readahead thing.

So yes, you as an attacker can remove the prefetching from *your*
load, but you can't remove it from the target load anyway, so you'll
just have to live with it.

Can you brute-force scrubbing? Yes. For something like an L1 cache,
that's easy (well, QoS domains make it harder). For something like a
disk cache, it's much harder, and makes any attempt to read out state
a lot slower. The paper that started this all uses mincore() not just
to see "is the page now scrubbed", but also to guide the scrubbing
itself (working set estimation etc).

And note that in many ways, the *scrubbing* is really the harder part.
Populating the cache is really easy: just read the data you want to
populate.

So if you are looking for a particular signal, say "did this error
case trigger so that it faulted in *that* piece of information", you'd
want to scrub the target, populate everything else, and then try to
measure at "did I trigger that target". Except you wouldn't want to do
it one page at a time but see as much pattern of "they were touched in
this order" as you can, and you'd like to get timing information of
how the pages you are interested were populated too.

And you'd generally do this over and over and over again because
you're trying to read out some signal.

Notice what the expensive operation was? It's the scrubbing.The "did
the target do IO" you might actually even see other ways for the
trivial cases, like even just look at iostat: just pre-populate
everything but the part you care about, then try to trigger whatever
you're searching for, and see if it caused IO or not.

So it's a bit like a chalkboard: in order to read out the result, you
need to erase it first, and doing that blindly is nasty. And you want
to look at timings, which is also really nasty if every time you look,
you smudge the very place you looked at. It makes it hard to see what
somebody else is writing on the board if you're always overwriting
what you just looked at. Did you get some new information? If not, now
you have to go back and do that scrubbing again, and you'll likely be
missing what *else* the person wrote.

Ans as always: there is no "black and white". There is no "absolute
security", and similarly, there is no "absolute leak proof". It's all
about making it inconvenient enough that it's not really practical.

                 Linus

