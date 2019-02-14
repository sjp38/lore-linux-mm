Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1174CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 01:51:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9C9321904
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 01:51:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vSAH0Rpc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9C9321904
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42B418E0002; Wed, 13 Feb 2019 20:51:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B3C68E0001; Wed, 13 Feb 2019 20:51:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A42D8E0002; Wed, 13 Feb 2019 20:51:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C468C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 20:51:08 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id v8so1562255wrt.18
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:51:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=F24RVbeKKB1cnCpDEq5tv60PU/vFe4EDFYXQPFBYiG4=;
        b=sgWML6tO/c16+1VQseLNrcmSRfxiXj38daOhpcj4/7wJl+IEw83Wy1iwvdPS9PkZZg
         t1vwDgNKasPE8njk2qfRy6qUng8Ky84C2c+ILIL5zRvD/agdiXKAsQNDwkcumqpoE7xl
         sj94v9NKwwEqsGPYQIABt1nJMV2BTRz5JbbvXfah//8JUclrUoaDDiHNC+xXtD+K4RN7
         HfzpEjOETaZBAs+n9neF3NU4x9Kx25FoLGA0sJoHUL5ctEBuUE/LGv3i5dMETpXV3FOv
         PVY4ntPMsI8HoJGiHXiaL4JDeDsf/RHtlr8Gi4XyJaGH1CocOokuzbeox1KITYwn69Qm
         X7eA==
X-Gm-Message-State: AHQUAua2JuvdiN+t6gtzcN3JP/a+c9FmGPrygvJlZeQGKla+hupI4bjN
	yjaer8hqhjK0ogZpcdcb2X54lX/kxJx/fpNlAGyvNvUXharEBHzS/xVjQDzK0V2W2QsbjOc19ql
	Dve6n6y/rzn3W8twBuMONkZTKAiQ8/Y8ebNL5fS0VqMnnnFHI99jGA/LWVmHUAsMkstLzvT/3Kf
	SvIFVjQsYqr2ECVqVoxDHDcupSTqcjWm0zv47nW+9f4HAvBWo/05ZTkBLEMRjYoWtByHdVBc+qH
	DRHA4eH/wJoMeDQi4IOznIEH7WKYbvhLAXs9eNU74NOtDxop14J+4sVIvL16v0mrN7IuJ5X24M/
	uO4ILAd4yS0IRwSFU4HVs7z75Mm3barorn2aT1xU/MK7tvjAOi2lcWL5I9YNF/bwPcwZ4JEY8p9
	E
X-Received: by 2002:a1c:8086:: with SMTP id b128mr665986wmd.117.1550109068351;
        Wed, 13 Feb 2019 17:51:08 -0800 (PST)
X-Received: by 2002:a1c:8086:: with SMTP id b128mr665966wmd.117.1550109067523;
        Wed, 13 Feb 2019 17:51:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550109067; cv=none;
        d=google.com; s=arc-20160816;
        b=UdmZl23jNu8rDhD9HaxL59ajSbPTsVKTmtEWTUh2ZItXO/ZGZes18xQ7Jb+t84gPoA
         LL3FOCTuA1oWX0rQ8FLSVQNTRoGytlr0tEnk82xe5hqg44p/kQYoLwVuhx3emOnaNzN0
         VKR0D8SEi/WZfUwmNd4iSTQFFYfWsQaChK5EW/h27MCuAqDrMzgmxYFrUCVQ357ZSGwg
         7fduMc7vM+g7x9dSx/14fnYhDt63qd59rmSdEwcI+xE/oqMRU1ZBkikcvkrRHc5XFv34
         XxcYCrJv+1XcPRE1YUbeobV9CdCwRuA1CT3om6vb0YzjkSXxacjTVT9qALg1dH50WInr
         wv5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=F24RVbeKKB1cnCpDEq5tv60PU/vFe4EDFYXQPFBYiG4=;
        b=JQkhuhuSIPtzR1/gIuM2jPO8HkvkjAjytcz3TddNfTZaNYubOIFvAmiGFfH5u5wvux
         MedLfMvDXrpcVJFbSf5bwIKjMBWeOWW3gs5nGAp6z1mkGuXR9719b8kDEsGNthVmRJ98
         /9nIoD417tOfYc/sEl1IN+w3grUKTyVGeAM3tB5oe7eSeCLvWupW2g1WIQAltxtxKbwu
         qqCtD5CIc6xhybCBzjkSrHzZqs104c2WLp1vEj60zyqoI6pSqRLGWNzJG2QGJ6PRHkR7
         crsrHkvX2TIs6YXsHh4xINwu5wRVs8Dip02txR2cJfpMZnzc3qLBzz/2lEGODGHnQrpe
         oopg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vSAH0Rpc;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor565237wrs.49.2019.02.13.17.51.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 17:51:07 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vSAH0Rpc;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=F24RVbeKKB1cnCpDEq5tv60PU/vFe4EDFYXQPFBYiG4=;
        b=vSAH0RpcqZoI384N6aWx/a6ZO2VP1uD+NDCUhuF485R1ktTjgbuR4PWJN1jDtxgthv
         tpuxVzwCTlSEem19lNbbjRd64NWiI9+H6gVoVdOXse39STXrhIByIAXR29cbksE5hDeC
         XDzgSzzrFoubIeuv61vg5LzUDm/AuQA4Xu03E2eYI9EmAfExE4qrbEENk6rXge3HAWll
         yk+QSMLSZoH9LNhMKxKRUJrev4N4BQU22lVhPXu6d7xlfHHX0HTrpCxsEuitSs+riyGW
         xPyFR4EXHqRBAEPYUcJ2+Tz9aB+EKuX81RkV5ag74cXkyQ1IH4W3dS6RONT25M15qXXs
         +74w==
X-Google-Smtp-Source: AHgI3IawV0AoL7/SiLAiW/evEF+BYLElakf4/oiB4CxjF1FDKzc7cBvow+JY0LNl96CjfAcJTQ9o3oVFmLRng1RtSqs=
X-Received: by 2002:adf:dbc4:: with SMTP id e4mr748458wrj.320.1550109066968;
 Wed, 13 Feb 2019 17:51:06 -0800 (PST)
MIME-Version: 1.0
References: <201902080231.RZbiWtQ6%fengguang.wu@intel.com> <20190208151441.4048e6968579dd178b259609@linux-foundation.org>
 <20190209074407.GE4240@linux.ibm.com> <20190212013606.GJ12668@bombadil.infradead.org>
 <20190212163145.GD14231@cmpxchg.org> <20190212163547.GP12668@bombadil.infradead.org>
In-Reply-To: <20190212163547.GP12668@bombadil.infradead.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Wed, 13 Feb 2019 17:50:55 -0800
Message-ID: <CAJuCfpGuT=Rn6J-YbN6TUoiqZqmUBS7pHRvXOEdX1RcasM-A+Q@mail.gmail.com>
Subject: Re: [linux-next:master 6618/6917] kernel/sched/psi.c:1230:13: sparse:
 error: incompatible types in comparison expression (different address spaces)
To: Matthew Wilcox <willy@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "Paul E. McKenney" <paulmck@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <lkp@intel.com>, kbuild-all@01.org, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 8:35 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Tue, Feb 12, 2019 at 11:31:45AM -0500, Johannes Weiner wrote:
> > On Mon, Feb 11, 2019 at 05:36:06PM -0800, Matthew Wilcox wrote:
> > > On Fri, Feb 08, 2019 at 11:44:07PM -0800, Paul E. McKenney wrote:
> > > > On Fri, Feb 08, 2019 at 03:14:41PM -0800, Andrew Morton wrote:
> > > > > On Fri, 8 Feb 2019 02:29:33 +0800 kbuild test robot <lkp@intel.com> wrote:
> > > > > >   1223        static __poll_t psi_fop_poll(struct file *file, poll_table *wait)
> > > > > >   1224        {
> > > > > >   1225                struct seq_file *seq = file->private_data;
> > > > > >   1226                struct psi_trigger *t;
> > > > > >   1227                __poll_t ret;
> > > > > >   1228
> > > > > >   1229                rcu_read_lock();
> > > > > > > 1230                t = rcu_dereference(seq->private);
> > >
> > > So the problem here is the opposite of what we think it is -- seq->private
> > > is not marked as being RCU protected.
> > >
> > > > If you wish to opt into this checking, you need to mark the pointer
> > > > definitions (in this case ->private) with __rcu.  It may also
> > > > be necessary to mark function parameters as well, as is done for
> > > > radix_tree_iter_resume().  If you do not wish to use this checking,
> > > > you should ignore these sparse warnings.
> >
> > We cannot make struct seq_file->private generally __rcu, but the
> > cgroup code has a similar thing with kernfs, where it's doing rcu for
> > its particular use of struct kernfs_node->private. This is how it does
> > the dereference:
> >
> >       cgrp = rcu_dereference(*(void __rcu __force **)&kn->priv);
> >
> > We could do this here as well.
> >
> > It's ugly, though. I'd also be fine with ignoring the sparse warning.
>
> How about:
>
> +++ b/include/linux/seq_file.h
> @@ -26,7 +26,10 @@ struct seq_file {
>         const struct seq_operations *op;
>         int poll_event;
>         const struct file *file;
> -       void *private;
> +       union {
> +               void *private;
> +               void __rcu *rcu_private;
> +       };
>  };
>
>  struct seq_operations {
>

Personally I would prefer cgrp = rcu_dereference(*(void __rcu __force
**)&kn->priv); as it's more localized change but if union would be
preferable I'll roll that into the next version of psi monitor.
Thanks,
Suren.

