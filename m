Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3E7CC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 22:00:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FD5A2184B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 22:00:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MqphQP92"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FD5A2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA0986B026B; Thu, 11 Apr 2019 18:00:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFD4D6B026E; Thu, 11 Apr 2019 18:00:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C75726B0271; Thu, 11 Apr 2019 18:00:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 719AB6B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 18:00:06 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id c8so4936490wru.13
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 15:00:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NawObyE9Zp16eLwFu5OPgzzdF2i4lMyPHI2QyUPOlK0=;
        b=ctNxT0dYeRIVXLOZHyagnwx9fJStjUY9tcQ+IfFzKC0jdwp4lhWWR3aV+EZto2UBzL
         vcuLVy8xJGO3/ZYxF/QyL7n5RODHmvc9a7REKcsK6ioKlnChoI4sKXtyZhwiqYNiFyaP
         56JUaoXO0j4g09VSaEz+hFyVuvn8LRZpDQaOzCR4qA6T2ff9G3UFGBEMhMIOX/nfX85O
         XidFMh5fw1zwFo6m3yats6qHu6ratUkB5V/qBXcYqABlydGTkJZhs6dW04oocaeghwt6
         Zy2tWffYVqwDhhPfr0+vaiNGU//+XpU3xPGOGwYmY627UEHXVSyBIjE9zZzVFkYpP0p1
         fk/Q==
X-Gm-Message-State: APjAAAXHTFF4UWqctV4t876iVhnNS8bW5pipR3r38qYw+pZ8sNzAwXEm
	7HufRH1EwzaUbkXV3AXB/8hp8drvRIr3LKSIuH6u+W6vYejiLguesFFH3eqWLbJEXOhT2ukT0qJ
	pnByplt9wB1ow0mxNU7R5+MZASbGfg61yLs2FADzwIfQg8E+BAMeYVC9/1BJZpQVmXQ==
X-Received: by 2002:a1c:7e10:: with SMTP id z16mr7812961wmc.117.1555020005919;
        Thu, 11 Apr 2019 15:00:05 -0700 (PDT)
X-Received: by 2002:a1c:7e10:: with SMTP id z16mr7812864wmc.117.1555020004218;
        Thu, 11 Apr 2019 15:00:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555020004; cv=none;
        d=google.com; s=arc-20160816;
        b=dnHf9ACT+y63T5GxSe1LZurGfHtU1cSMnP9Ceu7j7dUbDiryyjdYRNLX2OVyPs8pvF
         p3WTgGpBpFj5F1Xia3usCDWuXL2BRkIWEA/nTWBE56B6V5OaIS2zP776CEzajDvzUo2F
         ZW3OHaUXSPmbXV4PVtEAcw0ie4Ty4e6TJTtdZaUIfQzn/3NYn9ECYkvFfVIbIg/qZep3
         XMoLBWvfhtR/Fli6NTMCo8ufu/IXbD+MvXhifD/v2zknnhPS6kkax9Ssqg+mHnSVasFV
         B1UsEoT/REgKZyTUmpCwmwXzEweCtMZEf0VVBzhCiGp3lnwzo6U3ayMERvcPIIfdH2gv
         67UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NawObyE9Zp16eLwFu5OPgzzdF2i4lMyPHI2QyUPOlK0=;
        b=X/OLgmuMsc5C9rgQjeOI5+8gT9FkiAx9M6GiRGcskLggFb1v/HxK6iBXbWKPh71u7U
         lx3t/Ufvw7POLxi3mVYVlzVaWqnb/Ls4VV4YugzIjlgFAma4eSqNXZnRHyQDPbouPolE
         IpggtV0VpCtR/A7aLMadXJ+xTdp+RkqkwKn+ISMH1XEz4woEqVzjKdw2jWu2VLvU4RZf
         5AnoQ0YtzB+Ut/JFbDvKuhDrHKwk8qp8SlwDGbc04bctLfu90t9nkIriXsAlV3G4N2n0
         1Pe5PxbK1ajFeOFz3WRN/Z/wlnRIm9hhy1XeVZGdJE+j8myGJKyJrJPa31Ck6mtfDTaA
         O4Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MqphQP92;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w2sor29240479wrm.19.2019.04.11.15.00.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 15:00:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MqphQP92;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NawObyE9Zp16eLwFu5OPgzzdF2i4lMyPHI2QyUPOlK0=;
        b=MqphQP92OgsvRoMbbmbXn3lXPPv7JgQOj3uXy35tv7nQiYjdSaAyYZaXa/Q7P7wDXE
         kGDHBRN5P2Lxpgtg6vv9KELeDa+b3yyz+BtJsKyHo48XdAlE2kKFtC1jZgiuMjPMBn/9
         OjTpxGIvco4tQgJzkGyFaNaRFQw9jCg2YL9qyPEAMG5OlnctCup4J4BXFYZ/5M2VYQr0
         Xz7YQh086MWcG/jvWQkMTlzO9JW1GGWdNOTMp5I2/2LKJbdmYK+RLRhBva2DzlJdqhdP
         JiesYrjhOGVLwWT6cGkmVZ6UZseKXfSVFLy30lBl+Ts4/WKG4lrSxQ+OyS3G12/Y4EFk
         KCOQ==
X-Google-Smtp-Source: APXvYqywLXFZ26VMEzhbK5mzgQdSEa7/h59iSNw606UZ4yYmpRG6kaPD22As4lJ8uuB9GyxIbnLHPOuNGB/AzmlW7dI=
X-Received: by 2002:adf:cf0c:: with SMTP id o12mr13689115wrj.16.1555020003406;
 Thu, 11 Apr 2019 15:00:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org> <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
 <20190411214458.GB31565@tower.DHCP.thefacebook.com>
In-Reply-To: <20190411214458.GB31565@tower.DHCP.thefacebook.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 11 Apr 2019 14:59:51 -0700
Message-ID: <CAJuCfpFjwv7SFEYZ9gbZXYdiPSPpnKHaXfsbEJorN8Y55QAjVg@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Roman Gushchin <guro@fb.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	"mhocko@suse.com" <mhocko@suse.com>, David Rientjes <rientjes@google.com>, 
	"yuzhoujian@didichuxing.com" <yuzhoujian@didichuxing.com>, Souptick Joarder <jrdr.linux@gmail.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	"ebiederm@xmission.com" <ebiederm@xmission.com>, Shakeel Butt <shakeelb@google.com>, 
	Christian Brauner <christian@brauner.io>, Minchan Kim <minchan@kernel.org>, 
	Tim Murray <timmurray@google.com>, Daniel Colascione <dancol@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>, 
	"lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 2:45 PM Roman Gushchin <guro@fb.com> wrote:
>
> On Thu, Apr 11, 2019 at 10:09:06AM -0700, Suren Baghdasaryan wrote:
> > On Thu, Apr 11, 2019 at 8:33 AM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > > victim process. The usage of this flag is currently limited to SIGKILL
> > > > signal and only to privileged users.
> > >
> > > What is the downside of doing expedited memory reclaim?  ie why not do it
> > > every time a process is going to die?
>
> Hello, Suren!
>
> I also like the idea to reap always.
>
> > I think with an implementation that does not use/abuse oom-reaper
> > thread this could be done for any kill. As I mentioned oom-reaper is a
> > limited resource which has access to memory reserves and should not be
> > abused in the way I do in this reference implementation.
>
> In most OOM cases it doesn't matter that much which task to reap,
> so I don't think that reusing the oom-reaper thread is bad.
> It should be relatively easy to tweak in a way, that it won't
> wait for mmap_sem if there are other tasks waiting to be reaped.
> Also, the oom code add to the head of the list, and the expedited
> killing to the end, or something like this.
>
> The only think, if we're going to reap all tasks, we probably
> want to have a per-node oom_reaper thread.

Thanks for the ideas Roman. I'll take some time to digest the input
from everybody. What I heard from everyone is that we want this to be
a part of generic kill functionality which does not require a change
in userspace API.

> Thanks!
>
> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

