Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C72EC46470
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:29:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E2DD20825
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:29:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="v+8Aj1+G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E2DD20825
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC40A6B0005; Tue,  7 May 2019 12:29:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B74986B0006; Tue,  7 May 2019 12:29:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8AF56B0007; Tue,  7 May 2019 12:29:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9F36B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 12:29:03 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id b139so3084977wme.1
        for <linux-mm@kvack.org>; Tue, 07 May 2019 09:29:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=c5+HOOPjtVbBo+8gy8vNmbmMcaHMqGZxYXAym2RjAtc=;
        b=hXxpHKl3BpVRei2gaj4vrHikzIdf5syy3tzGKeTXXWyqQXgiZtanSXQ7Y80RjpfV5M
         dAcaUlghwnH20w4uc5Ibhxs1oaHxh6xOIxqX5iWeZcBJ4EMpc52880BEpw4NZVW9wT9Y
         9bFYKTzDH1d6TiD8x1p9M/glThbq69uXUmkwMHlPQs10PJ3kQuaUt7gdhbws516lSzUL
         7q5z8QXHlBY/8Wjkp1PwRnhZ1NnikjsngeXK57dF9uu+6T/Tx5kBukBlzhS8mLEQevmi
         FHIK8pxEui9pvbXx+mwvh0/H5wtYf3hav4A4S/7q5OngVZOmVWdXhLCPBv8ke0N/cFhw
         /TvA==
X-Gm-Message-State: APjAAAVIZWXA5rV50KJaU43Db8EgMZ7QxWN94+gQEEzB08CyGnBMUB6t
	tUWy/7Uu+4X2ccEoSsJ6sCd1JPvSNPk8I+WPFs1vDoV3pVF6oz1heSuxyxSJsi/uDynJtz3L0Cl
	HLZ9pHpYC0qlqqP5tKunPPP9Z2BNOxA4wh3nOziwRL3WEGFo4Ad9LkwThe02W/vOTGQ==
X-Received: by 2002:a7b:c3c3:: with SMTP id t3mr21275551wmj.88.1557246542629;
        Tue, 07 May 2019 09:29:02 -0700 (PDT)
X-Received: by 2002:a7b:c3c3:: with SMTP id t3mr21275470wmj.88.1557246541179;
        Tue, 07 May 2019 09:29:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557246541; cv=none;
        d=google.com; s=arc-20160816;
        b=r8FA0qzA8mxCggCHBB/9Do1V8dslH7a/3GsrUttzMP+kJIq+PAFtHw1tPIQ/QRUzFK
         57gq9Ii7JlddxVA0YhvXdLWGKyTMcYWere6jzX/zJpod8mXx2iVJax702zUNAN3FvRr7
         4jqDZA/1vz1RgZIKXdVhBlMyiIHHHNlCuxGvNSowYx2fqId6NmU6p4wpNAXpEmgnfFBn
         KsZd73xAxzYPTxb/EbXytFmFCJkGwPEr3OdV0v806IxARis4M7igGUUS9v6NRQrtQdbl
         QofKjAvYAKSjn8jdmke58eKqjuBbPadYMPJgrumaA0YMIj3Tu88JepAdn63Jw+NPbqq0
         3EiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=c5+HOOPjtVbBo+8gy8vNmbmMcaHMqGZxYXAym2RjAtc=;
        b=hg9Kt28STWgPSCp+sUcPkKzHtqTtSt0D1MOUiRODL26OH2XO4darlNWSTyKLsavf2X
         smfy1O54dDqkdSewlXeVXlNcPjFnvfSVeSrocgqDPeghAJc2tvSw8oAlKIwWIvV/exyF
         X4+cLIK5Ys7u/QukvM0FrUfp/euIxy4jChlsIB4A3Xm6lSWKc6vHibCLFT8nrB0AxdIs
         BKefeaeLpTkEMYl03t4kCgRmOvMxB+3qUCuKJmiBAF0q88GQQikgkc64Kc2NMBi9iw8k
         mW5aoG1z37SYpWpd4EJy1wjKV0dNdFIuyxENYnOq0aoDp3PhMFxCnLTlC0izgK4Hni4H
         C1lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=v+8Aj1+G;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t12sor10517158wrn.28.2019.05.07.09.29.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 09:29:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=v+8Aj1+G;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=c5+HOOPjtVbBo+8gy8vNmbmMcaHMqGZxYXAym2RjAtc=;
        b=v+8Aj1+Gzh9xAnJJxTKBz5IK7NFM9zFnPBDBO6Jm8AvvbnH1v7/uyOpfFqno1rg2Zy
         fWlzgtf4P3z9BwjWzOPCVXxpfYQLRYcUGluLq7rfauxlh27T1igPdhO2PnmRmDrIzUZb
         33S/UPvcIKxDgySDvLphqkCw3nx66UVkzdh2llSzJaaZDYeQjUp1GcwIRKMf4Fd2qexE
         pdGjzUCJ0cl2KrpuTdYemEjJKYL6rrWeGL4OEu6CfqNZbV6vGok2PFHNRvDxGe1TFozQ
         Qc+ua3Dhgf5+4cL3nsEmG5URl479U6yNuIsdqC58anKp1C+pQdCb7goL/K4F1m96V0sQ
         DdoQ==
X-Google-Smtp-Source: APXvYqym1S8ixk/XT+rtdrTBe5tWrchiuDfbT6Q3mS29Rpb1RGpNAAYDcvRlOaaUxs5q8h8UIab6C7KWUWz1lN8rgvo=
X-Received: by 2002:a5d:60cd:: with SMTP id x13mr3984822wrt.291.1557246540040;
 Tue, 07 May 2019 09:29:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190318235052.GA65315@google.com> <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io> <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain> <20190507070430.GA24150@kroah.com>
 <20190507072721.GA4364@sultan-box.localdomain> <20190507074334.GB26478@kroah.com>
 <20190507081236.GA1531@sultan-box.localdomain> <20190507105826.oi6vah6x5brt257h@brauner.io>
In-Reply-To: <20190507105826.oi6vah6x5brt257h@brauner.io>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 7 May 2019 09:28:47 -0700
Message-ID: <CAJuCfpFeOVzDUq5O_cVgVGjonWDWjVVR192On6eB5gf==_uPKw@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Christian Brauner <christian@brauner.io>
Cc: Sultan Alsawaf <sultan@kerneltoast.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, Daniel Colascione <dancol@google.com>, 
	Todd Kjos <tkjos@android.com>, Kees Cook <keescook@chromium.org>, 
	Peter Zijlstra <peterz@infradead.org>, Martijn Coenen <maco@android.com>, 
	LKML <linux-kernel@vger.kernel.org>, Tim Murray <timmurray@google.com>, 
	Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Oleg Nesterov <oleg@redhat.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Andy Lutomirski <luto@amacapital.net>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Christian Brauner <christian@brauner.io>
Date: Tue, May 7, 2019 at 3:58 AM
To: Sultan Alsawaf
Cc: Greg Kroah-Hartman, open list:ANDROID DRIVERS, Daniel Colascione,
Todd Kjos, Kees Cook, Peter Zijlstra, Martijn Coenen, LKML, Tim
Murray, Michal Hocko, Suren Baghdasaryan, linux-mm, Arve Hj=C3=B8nnev=C3=A5=
g,
Ingo Molnar, Steven Rostedt, Oleg Nesterov, Joel Fernandes, Andy
Lutomirski, kernel-team

> On Tue, May 07, 2019 at 01:12:36AM -0700, Sultan Alsawaf wrote:
> > On Tue, May 07, 2019 at 09:43:34AM +0200, Greg Kroah-Hartman wrote:
> > > Given that any "new" android device that gets shipped "soon" should b=
e
> > > using 4.9.y or newer, is this a real issue?
> >
> > It's certainly a real issue for those who can't buy brand new Android d=
evices
> > without software bugs every six months :)
> >

Hi Sultan,
Looks like you are posting this patch for devices that do not use
userspace LMKD solution due to them using older kernels or due to
their vendors sticking to in-kernel solution. If so, I see couple
logistical issues with this patch. I don't see it being adopted in
upstream kernel 5.x since it re-implements a deprecated mechanism even
though vendors still use it. Vendors on the other hand, will not adopt
it until you show evidence that it works way better than what
lowmemorykilled driver does now. You would have to provide measurable
data and explain your tests before they would consider spending time
on this.
On the implementation side I'm not convinced at all that this would
work better on all devices and in all circumstances. We had cases when
a new mechanism would show very good results until one usecase
completely broke it. Bulk killing of processes that you are doing in
your patch was a very good example of such a decision which later on
we had to rethink. That's why baking these policies into kernel is
very problematic. Another problem I see with the implementation that
it ties process killing with the reclaim scan depth. It's very similar
to how vmpressure works and vmpressure in my experience is very
unpredictable.

> > > And if it is, I'm sure that asking for those patches to be backported=
 to
> > > 4.4.y would be just fine, have you asked?
> > >
> > > Note that I know of Android Go devices, running 3.18.y kernels, do NO=
T
> > > use the in-kernel memory killer, but instead use the userspace soluti=
on
> > > today.  So trying to get another in-kernel memory killer solution add=
ed
> > > anywhere seems quite odd.
> >
> > It's even more odd that although a userspace solution is touted as the =
proper
> > way to go on LKML, almost no Android OEMs are using it, and even in tha=
t commit
>
> That's probably because without proper kernel changes this is rather
> tricky to use safely (see below).
>
> > I linked in the previous message, Google made a rather large set of
> > modifications to the supposedly-defunct lowmemorykiller.c not one month=
 ago.
> > What's going on?

If you look into that commit, it adds ability to report kill stats. If
that was a change in how that driver works it would be rejected.

> >
> > Qualcomm still uses lowmemorykiller.c [1] on the Snapdragon 845. If PSI=
 were
> > backported to 4.4, or even 3.18, would it really be used? I don't reall=
y
> > understand the aversion to an in-kernel memory killer on LKML despite t=
he rest
> > of the industry's attraction to it. Perhaps there's some inherently gre=
at cost
> > in using the userspace solution that I'm unaware of?

Vendors are cautious about adopting userspace solution and it is a
process to address all concerns but we are getting there.

> > Regardless, even if PSI were backported, a full-fledged LMKD using it h=
as yet to
> > be made, so it wouldn't be of much use now.
>
> This is work that is ongoing and requires kernel changes to make it
> feasible. One of the things that I have been working on for quite a
> while is the whole file descriptor for processes thing that is important
> for LMKD (Even though I never thought about this use-case when I started
> pitching this.). Joel and Daniel have joined in and are working on
> making LMKD possible.
> What I find odd is that every couple of weeks different solutions to the
> low memory problem are pitched. There is simple_lkml, there is LMKD, and
> there was a patchset that wanted to speed up memory reclaim at process
> kill-time by adding a new flag to the new pidfd_send_signal() syscall.
> That all seems - though related - rather uncoordinated.

I'm not sure why pidfd_wait and expedited reclaim is seen as
uncoordinated effort. All of them are done to improve userspace LMKD.

> Now granted,
> coordinated is usually not how kernel development necessarily works but
> it would probably be good to have some sort of direction and from what I
> have seen LMKD seems to be the most coordinated effort. But that might
> just be my impression.
>
> Christian

Thanks,
Suren.

