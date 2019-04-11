Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9A16C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:48:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67E692082E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:48:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jz89wF/P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67E692082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4C356B026D; Thu, 11 Apr 2019 13:48:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD2506B026E; Thu, 11 Apr 2019 13:48:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9A346B026F; Thu, 11 Apr 2019 13:48:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81C3F6B026D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:48:03 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id v22so2819565vkv.12
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:48:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EdmEfhETvX5sRZ2i3AN4xgxKTisr0Ltj90Tc5NPzL+I=;
        b=RVsAfzUGWrEAtfrglCjo7bFZa43SXdWdGg9259RsKQ2rrfkbZ4wbMOow/MHG4mDvPl
         kOdlogu8nV446Lvg6BS/jUKG91HtOuJjdZRDEc3tyzPsfIv7L0b/D1nASo+Mmj61pYJN
         5RxaYeU2jQthX/bWsGoZ+GRrhqPLq6nLJZSpobfvK5ONELTOtTQFns+8XBGiPucb3EhK
         pUf1siOVoE8bBq0q1H2/G4oW1F5LTCXo8xINFRrJ6PkEBsGnJbsmbzKoFDVljyvByCGH
         z5ij/oWSlAqpgcP1JEcpbl/NjoZdj1laLVXSyLhzkuxQoGJpchKkIWfdryBN0rOBeV7U
         0QiQ==
X-Gm-Message-State: APjAAAU07BM8MIQCAn+a4bbHPA+tFsvxoI94nzUjSgyAf/gXswQqJ3+u
	XOOk9K6TCxUpevxlRNyo8rOc4QWi6h31KWe9CFy00asyIN0mrGi65yWGvDTZSN6BtgtqCnQ8GL3
	roEWGevxgjkMhb6x/VcktCqNq/XJFSq0yr247wWxwnIC+QNT1LGBK/bc6jNJi6ZfSOA==
X-Received: by 2002:a67:f813:: with SMTP id l19mr28812492vso.46.1555004883244;
        Thu, 11 Apr 2019 10:48:03 -0700 (PDT)
X-Received: by 2002:a67:f813:: with SMTP id l19mr28812457vso.46.1555004882389;
        Thu, 11 Apr 2019 10:48:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555004882; cv=none;
        d=google.com; s=arc-20160816;
        b=Zu/lemjSDAfyDAAsV8hp5vr7sUumZCaCJB5hZ8nCiBTqPA/ZVwiEZgfDtKl/CYmS7z
         u+p5Je1698hVFTh9Q/AGIoTcxgCTnDvGn5AQKVeV9xgc9Bn6WriZuUH+JDL07PWXnIqo
         n7E7rEGCbxZzhX7TFYBGvu7uWbUr3zUPhdlwc9mrNVPaHjkcJIph1YHCJJ+WjiTzYnB+
         u4YSgvYpDOuH+0ujG5HcLtF1H257vf0onnH7hF2UN8qmVqxhzxhowXuQeT0OT5DcSK6D
         j4JGXF29Z0pIHmXOHce8HdqR42GOxQJegmIn65Z66xjh164DUhPaN+Nh5HxcLjujpcdN
         Ra+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EdmEfhETvX5sRZ2i3AN4xgxKTisr0Ltj90Tc5NPzL+I=;
        b=iHkyerVY+GIZxPMeBr5oLQL/9LGeILD32etwDnBX8oUVY+siK2mEUrIiGjKL8n5z+L
         i3Ovk//xgeEuUzD6l2sPPhAqAnqDNX1aekbQFdmIRZPJcRtkpR3y8dyuzRiqO9bbnT+g
         epEUiHROe3xd0GlEROmWBWPZZYunGa3+JXhOOd/yWFyZFCopl54QdUcZMFIliQOJm3PD
         nlOKXIcfDCM7fcfewzgamPBLEOSQoE0sPcA1QuLPdPWxNeglK+ViSDOeLsnvyRJ5gcRl
         NbGrl+MSmzN7Zx4PLzS+1yajsGfPRgCR8spmZziAcEclwj/rv8M5TRFQdZCT5qs9LumC
         QgFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="jz89wF/P";
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v3sor24460396vsj.14.2019.04.11.10.48.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 10:48:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="jz89wF/P";
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EdmEfhETvX5sRZ2i3AN4xgxKTisr0Ltj90Tc5NPzL+I=;
        b=jz89wF/PI7xg90sbXXootb01OYHrWVY1nyKpnYun8KA/55ifTn0poh8w9zFwRH252Z
         Dw+IysDpcGaJw6W5CznS2kYl/jSmZrStx7LG6OgW7ihxHEasnyj+5cNjp8m1rxozoENV
         vMjq/0/brXM7n2UaYUjItZAJjRAXYz1OmAao8Sd69dilMIvL2IJT3oDvDBgrSAejGbbH
         Zkfmdw/a3nVbVz2iTiFBR2bFuKyW6eJU5N2v2KaFR6vXkF5HJzyxVz9TqJVHMm1aLN/9
         EFNznjoGr1qh/+0NrHLQrLhfHjTFVDwPn5uDgrh7B5/JwMRo4NtPiZ0lSShhe+MBfz37
         1zCA==
X-Google-Smtp-Source: APXvYqwI0Tosne+pusVzKzdHblB/C7MtpXTvYlDo3J+xGAIK5hCHrHvOO0GrDJKsNhe/ffI89eTSYRDp9xlhLXpu9Ig=
X-Received: by 2002:a05:6102:212:: with SMTP id z18mr29458490vsp.218.1555004881611;
 Thu, 11 Apr 2019 10:48:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org> <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
 <CAKOZuetFU4tXE27bxA86zzDfNSCbw83p8fPxfkQ_d_Em0C04Sg@mail.gmail.com> <20190411173649.GF22763@bombadil.infradead.org>
In-Reply-To: <20190411173649.GF22763@bombadil.infradead.org>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 11 Apr 2019 10:47:50 -0700
Message-ID: <CAKOZuet8-en+tMYu_QqVCxmkak44T7MnmRgfJBot0+P_A+Qzkw@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Matthew Wilcox <willy@infradead.org>
Cc: Suren Baghdasaryan <surenb@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, yuzhoujian@didichuxing.com, 
	Souptick Joarder <jrdr.linux@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, Shakeel Butt <shakeelb@google.com>, 
	Christian Brauner <christian@brauner.io>, Minchan Kim <minchan@kernel.org>, 
	Tim Murray <timmurray@google.com>, Joel Fernandes <joel@joelfernandes.org>, 
	Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, 
	LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 10:36 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Apr 11, 2019 at 10:33:32AM -0700, Daniel Colascione wrote:
> > On Thu, Apr 11, 2019 at 10:09 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > > On Thu, Apr 11, 2019 at 8:33 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > >
> > > > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > > > victim process. The usage of this flag is currently limited to SIGKILL
> > > > > signal and only to privileged users.
> > > >
> > > > What is the downside of doing expedited memory reclaim?  ie why not do it
> > > > every time a process is going to die?
> > >
> > > I think with an implementation that does not use/abuse oom-reaper
> > > thread this could be done for any kill. As I mentioned oom-reaper is a
> > > limited resource which has access to memory reserves and should not be
> > > abused in the way I do in this reference implementation.
> > > While there might be downsides that I don't know of, I'm not sure it's
> > > required to hurry every kill's memory reclaim. I think there are cases
> > > when resource deallocation is critical, for example when we kill to
> > > relieve resource shortage and there are kills when reclaim speed is
> > > not essential. It would be great if we can identify urgent cases
> > > without userspace hints, so I'm open to suggestions that do not
> > > involve additional flags.
> >
> > I was imagining a PI-ish approach where we'd reap in case an RT
> > process was waiting on the death of some other process. I'd still
> > prefer the API I proposed in the other message because it gets the
> > kernel out of the business of deciding what the right signal is. I'm a
> > huge believer in "mechanism, not policy".
>
> It's not a question of the kernel deciding what the right signal is.
> The kernel knows whether a signal is fatal to a particular process or not.
> The question is whether the killing process should do the work of reaping
> the dying process's resources sometimes, always or never.  Currently,
> that is never (the process reaps its own resources); Suren is suggesting
> sometimes, and I'm asking "Why not always?"

FWIW, Suren's initial proposal is that the oom_reaper kthread do the
reaping, not the process sending the kill. Are you suggesting that
sending SIGKILL should spend a while in signal delivery reaping pages
before returning? I thought about just doing it this way, but I didn't
like the idea: it'd slow down mass-killing programs like killall(1).
Programs expect sending SIGKILL to be a fast operation that returns
immediately.

