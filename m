Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCE0BC46470
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 10:58:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E53920B7C
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 10:58:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="E+YVKccV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E53920B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 197E46B0005; Tue,  7 May 2019 06:58:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 147776B0006; Tue,  7 May 2019 06:58:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 037176B0007; Tue,  7 May 2019 06:58:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC4A16B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 06:58:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h12so14225882edl.23
        for <linux-mm@kvack.org>; Tue, 07 May 2019 03:58:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1HC/MUgf456zJfRJXUVVgg6o0d0M1B+L7QMi6llJ2Bo=;
        b=rrP22tTXhvYVCenlKcXgBRs3Xg5L7d3bZZL+cG4pn+l37cPL879aqWCpFd5mVByYbm
         st52TZQuSdbFi3N/d65OSLj2KhPp0Tkt/VXK3TYc5eD5l9BnmXSexWuS10bTKMPHEd3j
         wE0lunairBJMu2cNgBNFvt+Jqonr6NGRvdddRgHXqubnEemddEEd4j+F+65JpTpAHMWK
         b/6iLQd2aaW55n7zrKQxA1TvSvwl6wNbjXGZLMMij88hd3VX1ZNbjPCqxlVMuhrPw8Gn
         cFliDqbSzbxw8A/4cQHJ9o/KQaimbuZciVkrZYbwYoTGyf0qgWPVTHG/v0CCsNRp8j5T
         MfYg==
X-Gm-Message-State: APjAAAX7Wxu+A7wAh0y/mqX0pzHdCmgxyjbjjYnC8pt/CqOWItkstcTi
	w3ZJt8Oz1yhP3APbwLcTwkFWzxcLjc1twCRkZYOFtcI8yjIIBbR9mGmQIN6+jZQVig5QZLNJyae
	pIkCFbyLyrFBB7aQV3lOdNFBeHXNfHWkBuwEXreNDSOz+xecShhQPShKadmcQsoJ6+g==
X-Received: by 2002:a17:906:5c10:: with SMTP id e16mr23720351ejq.19.1557226711235;
        Tue, 07 May 2019 03:58:31 -0700 (PDT)
X-Received: by 2002:a17:906:5c10:: with SMTP id e16mr23720295ejq.19.1557226710173;
        Tue, 07 May 2019 03:58:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557226710; cv=none;
        d=google.com; s=arc-20160816;
        b=o35HSuhQ6LJZXwN767k9Rqac8wXrw94LoVUTE7/4upWbmflrlcV6ukOwgk69QkwbsP
         NBrHm6/Vg5dUTJ2rNJQEo8r0pzWYeH+vm5ewstsjQo2B1rJ6E4Pz8gNjSKeint9uScc0
         q6a/p4m5N261vLnwUhuWsWHBzPWZJstTaKNvBvQ4IzpMKQ83h4ocRgfQIDlswvQ3ry+3
         2rFLMEGtSD0fw2c3LY/+Hgrc7XNl56OMc4kY0W8dmlsD8cKEFTCk49VDc4hTThNC6Jy3
         ji7WufYb2R7592oN/jd1LFz0ZuDFw8CxIbDZeAad2QN836IT5tdzwK4Y4jKa771zB+kC
         pmYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1HC/MUgf456zJfRJXUVVgg6o0d0M1B+L7QMi6llJ2Bo=;
        b=u9SFm33GaDzc7QU41sHBlOMGdXFgpKxNjgxycopkhDiSaArYT01wW6Pqwlvkw15VZm
         wPJ9O7vJDIOXEXESRLuqBXqHKzL5xji/h8HO9OzS4qH9PdUf/mLvWx3Ci7gNEf2rzec6
         eHVSr01Dq9BoXjd/vVF9LFyER9EKTitI9BIVVjivfzmww9F0gPLfbeqheSsxhHRW/cw3
         z5vFJWEjnatAVEOyYplurBN/H3dWjbetr2k6nzXHbuwik5SI7FvnFPA/2C8b6EjA1QB4
         yfzdOvNXoP0STvk88Mx9Q3l/2ls30MbJAgf8vr2/vtjT+ctLT7pn99JNvmnJRDOcFNUE
         +mww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=E+YVKccV;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e51sor6765105ede.15.2019.05.07.03.58.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 03:58:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=E+YVKccV;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1HC/MUgf456zJfRJXUVVgg6o0d0M1B+L7QMi6llJ2Bo=;
        b=E+YVKccV3crljzyzQRgZ+qVmjGAxpSmba/m9j8r8NgrA34RUFop5bvNMjUbDwOuRNB
         b32+Jl/qjNWnlvTDYyTs/KeVx58V71F7zbu28ARzlDJFrza6g9g8Zi8OL55OmDTkgfSl
         1BGDJtAmk2ERpdEdX2xDcrPZ80zvjefZo+oei1Mm2khGrth/UBL1A1VFwvbheFqAlcQ8
         9JSttdgh0BDB+Z/aTtQZkNW6+cetIuH9iCeGfDRIqCOLydg98GdTqe6LAdP4iTh2ppDw
         LsM9hKBQMNpP2ECL1fjkX6fYcURKheF5cqWjXseRus2cycqTaunLSVR2osQqCa3I6n/H
         lrLw==
X-Google-Smtp-Source: APXvYqyHqFTcJpvyTuty9Yn2Sc9cm+BuGmLDrYq55IuT9aIRo5DWhxH0xy9+mtPoGye/4Y6Cby05tA==
X-Received: by 2002:a50:885b:: with SMTP id c27mr31844820edc.155.1557226709457;
        Tue, 07 May 2019 03:58:29 -0700 (PDT)
Received: from brauner.io ([178.19.218.101])
        by smtp.gmail.com with ESMTPSA id w14sm4048277eda.18.2019.05.07.03.58.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 07 May 2019 03:58:28 -0700 (PDT)
Date: Tue, 7 May 2019 12:58:27 +0200
From: Christian Brauner <christian@brauner.io>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	Daniel Colascione <dancol@google.com>,
	Todd Kjos <tkjos@android.com>, Kees Cook <keescook@chromium.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Martijn Coenen <maco@android.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	linux-mm <linux-mm@kvack.org>,
	Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Andy Lutomirski <luto@amacapital.net>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507105826.oi6vah6x5brt257h@brauner.io>
References: <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507070430.GA24150@kroah.com>
 <20190507072721.GA4364@sultan-box.localdomain>
 <20190507074334.GB26478@kroah.com>
 <20190507081236.GA1531@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190507081236.GA1531@sultan-box.localdomain>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 01:12:36AM -0700, Sultan Alsawaf wrote:
> On Tue, May 07, 2019 at 09:43:34AM +0200, Greg Kroah-Hartman wrote:
> > Given that any "new" android device that gets shipped "soon" should be
> > using 4.9.y or newer, is this a real issue?
> 
> It's certainly a real issue for those who can't buy brand new Android devices
> without software bugs every six months :)
> 
> > And if it is, I'm sure that asking for those patches to be backported to
> > 4.4.y would be just fine, have you asked?
> >
> > Note that I know of Android Go devices, running 3.18.y kernels, do NOT
> > use the in-kernel memory killer, but instead use the userspace solution
> > today.  So trying to get another in-kernel memory killer solution added
> > anywhere seems quite odd.
> 
> It's even more odd that although a userspace solution is touted as the proper
> way to go on LKML, almost no Android OEMs are using it, and even in that commit

That's probably because without proper kernel changes this is rather
tricky to use safely (see below).

> I linked in the previous message, Google made a rather large set of
> modifications to the supposedly-defunct lowmemorykiller.c not one month ago.
> What's going on?
> 
> Qualcomm still uses lowmemorykiller.c [1] on the Snapdragon 845. If PSI were
> backported to 4.4, or even 3.18, would it really be used? I don't really
> understand the aversion to an in-kernel memory killer on LKML despite the rest
> of the industry's attraction to it. Perhaps there's some inherently great cost
> in using the userspace solution that I'm unaware of?
> 
> Regardless, even if PSI were backported, a full-fledged LMKD using it has yet to
> be made, so it wouldn't be of much use now.

This is work that is ongoing and requires kernel changes to make it
feasible. One of the things that I have been working on for quite a
while is the whole file descriptor for processes thing that is important
for LMKD (Even though I never thought about this use-case when I started
pitching this.). Joel and Daniel have joined in and are working on
making LMKD possible.
What I find odd is that every couple of weeks different solutions to the
low memory problem are pitched. There is simple_lkml, there is LMKD, and
there was a patchset that wanted to speed up memory reclaim at process
kill-time by adding a new flag to the new pidfd_send_signal() syscall.
That all seems - though related - rather uncoordinated. Now granted,
coordinated is usually not how kernel development necessarily works but
it would probably be good to have some sort of direction and from what I
have seen LMKD seems to be the most coordinated effort. But that might
just be my impression.

Christian

