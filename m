Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E34A1C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 02:41:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98D39214C6
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 02:41:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MRa/9bfd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98D39214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3665D8E0003; Thu, 10 Jan 2019 21:41:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3159A8E0001; Thu, 10 Jan 2019 21:41:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DF2F8E0003; Thu, 10 Jan 2019 21:41:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E38508E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:41:56 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id o205so156203itc.2
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:41:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RfMVf92gzaxzMAZMAu2AYRtnc2xIj45ckuZbtAg6QGU=;
        b=DXx4GlyXvyp/vZ3/32igIKGAGVTfaBQMLF+CsGDeHqb48XApTTfD7HI1ZEXnwRx3cl
         HQ1CAkIk50h8wPnq6/MC8rw10S7jjHFaOubvd9k46Oky9KuHl2s9HrA5l4ExNPVGq9Gl
         +7wZiM0akZvS6Lgrwa5YSu75RF6dubtoq9KySa9r/R44IlwhlrpCq8hN1wt6jfe90DQZ
         1s2vO/GWtxlZ9EA1vEiUflMFA3eHYqBsa3CCwKi7AGtMMfoR8vNjgOfj1C9BKi+UyWrG
         HYzHcxZS5KD99yyVY9H9XtZXwx8ha0bTY+TFAJM72Oqgd7ai5Y445Lxo3qpyjbNLVOwL
         AAAg==
X-Gm-Message-State: AJcUuke10IvgVRRBMGyVtfnAsCG4RFT0lIq96MuIBgYr5i9dVgIuCsej
	bX7OORwlDnge2oHybFNUdrAAzBoyhTgniEAouOar/H3vbFHYUnKpvETaTl/4XzTI/Cxw0L1/C8+
	yOhts1GMYk615/s0AyStFGRMSJbrSTFdfPjPuOUaK8Hb/YTiFOEB7Wb0A74gJ4TdorUSTsppisB
	Vm3Y0fjKBC7nztriYkrk9dr02Fo+sHdDbq+oOdsczOsVGr9K5tEk5Ycdjtp3rUIZZoxNKg0fLAN
	zC5YXzAIUg/YuKiP75KkSE+GQ/1NDWoqeRgjhGTPu+3xlOMeddBW3baPG5+INppHR0JA+37nHmc
	C8fuadYOWskiqjmDXyXaLPpgAGvQDvNJREWWKbCGroiNEgl7oC3sU/g8DJFCvypgqTW2T1IHlIs
	U
X-Received: by 2002:a6b:1490:: with SMTP id 138mr8911653iou.103.1547174516512;
        Thu, 10 Jan 2019 18:41:56 -0800 (PST)
X-Received: by 2002:a6b:1490:: with SMTP id 138mr8911642iou.103.1547174515828;
        Thu, 10 Jan 2019 18:41:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547174515; cv=none;
        d=google.com; s=arc-20160816;
        b=Ad1Mn89bWiaq5o0+YLIYvILhO2Hg0m+KGmJgKWgVz/fIF/XtqsEMsSLnxNGB65SeM9
         LVpK2EPPelbInbFaMQ5qCRJPAB34L4qu/US0hgqiNn1fCB7bn6aX0JH0ulb1fg8jO83u
         3zoiRltKlxfWMbbM81SH/6leaStWk0bJws6uURvoLHdl+a7ZS6Cn6acEh9al7Vp0XhoU
         A0/QqnfcRoOtwzW6BTg0CxbOYGMELyy3h1nmaLWRcAVFD+El7g3WnV/lelAON5OQwzmp
         TqIV7+zZJyNZjX53DJsIGxZ/5jy6YxQFLDJLtV67CC1GK2fyJhTZLjN68ldm9SbVi4cP
         YZIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RfMVf92gzaxzMAZMAu2AYRtnc2xIj45ckuZbtAg6QGU=;
        b=fHEtJaUb5Tv+fpyEVU19LWRi86MCnMRQDXLJL29goUgCAh5XIWFpUk/PsOXFu/8e19
         /21ESimSGV6PjjE+LkZP+pJRBwjFPsADq1Xeby72cpJ+EtIV9WeUha3PDNftWU8dcbNJ
         AJhZ1PztGO/4FrGi2+Fwccf1f9f82k5kUAbR7iY0MbbLCKCuVLlOw71rcyAJSkraJGjh
         gV5lcBVwALXd4rsq521KRokEZtS2rCuefIjynusMGTxa8ew7J4iO2BlF5VuJ7PU3gSrf
         5Wk8+RQCqbMl2un5hM1FzRKb9uk1YLTb5oSErR0nYiKZM3iTkp37etWCg7To5IY+coHI
         MH5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="MRa/9bfd";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m200sor208822itb.0.2019.01.10.18.41.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 18:41:55 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="MRa/9bfd";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RfMVf92gzaxzMAZMAu2AYRtnc2xIj45ckuZbtAg6QGU=;
        b=MRa/9bfdZyRjEJLIeG7zx4theoKEg2zKgAgFkxZWKncN6J87EabS6DUt0NbHO1ShdA
         5VCjc19Bfd313iZS4han3kE2BUIsu4KP2d0mnR+bdlN0tCmi2tAsGryx7UV1q55ZEDkD
         U9C9Ev40HlWbWLjIy8nxTZjhag0WOz4FJPnAsl9n+i+Rmg21C41DXjdU3LkKWbQvGoZ5
         3WdypC25V/3ydUa1q5Ec6VDvN2voHGx1GAzSo1X9dXUgjVf7YXcUqN1EqW/9Mfk/66IV
         GWlzmqJSRzdVqnTD23i7h+2jp0MH6UX79KJSD6/npLCUrRTqSlN1Be8lwtxlIH/MJl4D
         C6fg==
X-Google-Smtp-Source: ALg8bN7Gjki6FZggg6PyH5Cia7SKfuhztuj+BXYJGNQKyxr4jO6MOJX9oHMpyEvghsT3ptD0NxppM2zcXF6UenjhjZc=
X-Received: by 2002:a24:7a94:: with SMTP id a142mr83215itc.88.1547174515528;
 Thu, 10 Jan 2019 18:41:55 -0800 (PST)
MIME-Version: 1.0
References: <1546848299-23628-1-git-send-email-kernelfans@gmail.com>
 <20190108080538.GB4396@rapoport-lnx> <20190108090138.GB18718@MiWiFi-R3L-srv>
 <20190108154852.GC14063@rapoport-lnx> <20190109142516.GA14211@MiWiFi-R3L-srv>
In-Reply-To: <20190109142516.GA14211@MiWiFi-R3L-srv>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 11 Jan 2019 10:41:44 +0800
Message-ID:
 <CAFgQCTt6YjoqfvZhEFNAvg-0_r_V5apowNAcg4SSLx1QOMSSWA@mail.gmail.com>
Subject: Re: [PATCHv5] x86/kdump: bugfix, make the behavior of crashkernel=X
 consistent with kaslr
To: Baoquan He <bhe@redhat.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org, kexec@lists.infradead.org, 
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Nicholas Piggin <npiggin@gmail.com>, 
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, 
	Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, 
	yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111024144._dvjHAFz7JlBJkrnxgICwUJU_cXOK4cJ7yLKtrnXBL0@z>

On Wed, Jan 9, 2019 at 10:25 PM Baoquan He <bhe@redhat.com> wrote:
>
> On 01/08/19 at 05:48pm, Mike Rapoport wrote:
> > On Tue, Jan 08, 2019 at 05:01:38PM +0800, Baoquan He wrote:
> > > Hi Mike,
> > >
> > > On 01/08/19 at 10:05am, Mike Rapoport wrote:
> > > > I'm not thrilled by duplicating this code (yet again).
> > > > I liked the v3 of this patch [1] more, assuming we allow bottom-up mode to
> > > > allocate [0, kernel_start) unconditionally.
> > > > I'd just replace you first patch in v3 [2] with something like:
> > >
> > > In initmem_init(), we will restore the top-down allocation style anyway.
> > > While reserve_crashkernel() is called after initmem_init(), it's not
> > > appropriate to adjust memblock_find_in_range_node(), and we really want
> > > to find region bottom up for crashkernel reservation, no matter where
> > > kernel is loaded, better call __memblock_find_range_bottom_up().
> > >
> > > Create a wrapper to do the necessary handling, then call
> > > __memblock_find_range_bottom_up() directly, looks better.
> >
> > What bothers me is 'the necessary handling' which is already done in
> > several places in memblock in a similar, but yet slightly different way.
>
> The page aligning for start and the mirror flag setting, I suppose.
> >
> > memblock_find_in_range() and memblock_phys_alloc_nid() retry with different
> > MEMBLOCK_MIRROR, but memblock_phys_alloc_try_nid() does that only when
> > allocating from the specified node and does not retry when it falls back to
> > any node. And memblock_alloc_internal() has yet another set of fallbacks.
>
> Get what you mean, seems they are trying to allocate within mirrorred
> memory region, if fail, try the non-mirrorred region. If kernel data
> allocation failed, no need to care about if it's movable or not, it need
> to live firstly. For the bottom-up allocation wrapper, maybe we need do
> like this too?
>
> >
> > So what should be the necessary handling in the wrapper for
> > __memblock_find_range_bottom_up() ?
> >
> > BTW, even without any memblock modifications, retrying allocation in
> > reserve_crashkerenel() for different ranges, like the proposal at [1] would
> > also work, wouldn't it?
>
> Yes, it also looks good. This patch only calls once, seems a simpler
> line adding.
>
> In fact, below one and this patch, both is fine to me, as long as it
> fixes the problem customers are complaining about.
>
It seems that there is divergence on opinion. Maybe it is easier to
fix this bug by dyoung's patch. I will repost his patch.

Thanks and regards,
Pingfan
> >
> > [1] http://lists.infradead.org/pipermail/kexec/2017-October/019571.html
>
> Thanks
> Baoquan

