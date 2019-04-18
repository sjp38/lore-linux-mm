Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A14BDC282DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 01:55:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C6CD217F9
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 01:55:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lWEA3zXd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C6CD217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 957AA6B0005; Wed, 17 Apr 2019 21:55:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DFE06B0006; Wed, 17 Apr 2019 21:55:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A7626B0007; Wed, 17 Apr 2019 21:55:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5392C6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 21:55:25 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id x2so575424ywc.7
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 18:55:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KCQ+0ux3f2lhz2JQz+sODUn7gTy6oTF+cvFWZuiFK1k=;
        b=LAFBqODuC7467h8YNr0d81ILvv5suPiQz8If+UyI63Q8n+uu5Yo/on0/erPcz3GQSi
         /sX26T4acpb5ecFlQVGckkjIi2cHog3+4AIzcFnWq1T5tK1XwMA7a5KENdsc9rSqOhNr
         mNDS/vGw9ftEM10vML9Akv5cVn8jBexxvuDCNbUhp6xAWhu/w2hrFHLycNjBsZSMn1wY
         FkF5y1N93BepqF7HSOp27LXmKI3QK5THKanCJ8TgePsg64g1BbLOD2w8CI05Dqb0WWkI
         /Rv14KN1tsUTq+rVEQmCTntZHq+WnHDkeulklYXufTMTnSIWMPN4PR4KwenfIafmnB/y
         jNHA==
X-Gm-Message-State: APjAAAX3mqKGGT7A5Xc4kmoKEmfXhMwIGRthy7ffBsBUEofiKWNCW7v+
	wOm+XMTO0Fp8UB4gZlAT5cSbGUlallmFiVfNDIRuGy3xBgwOjacKJXx2HNV4I2tzugKh+MS90IC
	vjf8syKOWw6go1/rOszB/BpXlz1uY3oZ1rBfGPXRNG4lP69ehI0cviwnDl6GZIBrsIQ==
X-Received: by 2002:a81:2257:: with SMTP id i84mr72885002ywi.394.1555552525011;
        Wed, 17 Apr 2019 18:55:25 -0700 (PDT)
X-Received: by 2002:a81:2257:: with SMTP id i84mr72884967ywi.394.1555552524210;
        Wed, 17 Apr 2019 18:55:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555552524; cv=none;
        d=google.com; s=arc-20160816;
        b=0em4UDJG9BsOql3oTJNEldBW2j8+c8klE/KXMFeX9rCNi02M7i8HzPQyTprIlH3QU/
         rVXkME2dElgDYkD7n0u3S9IbOGRNz5IM+L+2pSXrfAF+84rrhvFC2fFH2YUsqxMoDXXN
         +2p+4DKY2q7ax3JTXHpRC2SUEW+QSfqjaFpNdxzTCcyctc3AMGkPSU62rzhLFrVPQYEi
         Y4S4DPfzp+RBQ9OIHHctjuZE02No61N3TjyPtVeizgcD1X+nIhJDCRU8wk+l98w2J8kO
         k4PdTjFQcJxDDT9JmY8WcaETDsrz8KbHaVaWazRG+bhZgTzFv0geSzoljrSLbU4tFVGH
         SaMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KCQ+0ux3f2lhz2JQz+sODUn7gTy6oTF+cvFWZuiFK1k=;
        b=tg8Im5oWi9/YebUxtC7k1LO7lpy5fmobIOWJz6y7zItTxRDO76nghuOzHQyiAVol3n
         vHKZP8JmvgeeIodpEN1uTryjTYEu0qNk6oEl1x8EE2PwaMd98LhK+n7v4/9vTQQuusZG
         iVLgBhfTht9YqWxwOx8IlTWv0NZciHR9DCHcmdnKKpTO/U7nUwB1CjiMDWCrJfhGj/4K
         s2wyCoj0hidWOiP8HTDqIAJUcZC2z+1WEh445H02jc1Sa68RihZnMtiVXWNk3wY+AwpX
         vKE686jF3lhCUr99BBntCtg0ick+p7erv0XKyKjAKBSkhpxGCLgQ64QsujCSmFKl7DFK
         GJOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lWEA3zXd;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 22sor289041ybl.120.2019.04.17.18.55.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 18:55:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lWEA3zXd;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KCQ+0ux3f2lhz2JQz+sODUn7gTy6oTF+cvFWZuiFK1k=;
        b=lWEA3zXd1uUNwv1sfs/UBAcFEGV7gzD1mipY5IZjzjsWevuBoSGre2ffvv0LXhiX4/
         il0RgAxHngPy2TypBkVVpVhebvUuicEOsLe69KHZgTg2Zena0Fg5SHPJGeGcJUlix0KX
         weKb4jER8526L50m+2MUd9bNeIw/1seMQ5k/0Z9qBKWVfB5W7YQF7LwAeFzykqOcPsyl
         2EEp3IbR6TfHeeiJW5IAuOiQa+KVTjR9+cqCX6OraglnF6lFsaoXFgMyDt6OtNR3uKYk
         0WCmXgoVwQMwrGnETEOjRHfIB7v11L7+Pesh8yrqNVI1oU/z4JfX2WzzMZLRH801nTP+
         3YwQ==
X-Google-Smtp-Source: APXvYqyG3Qa/sADVmtgfR8FKB8zQ5pNAcFMTM0KK3pvwUWD2+SmxAIyLgj1W5jy5fx0yF+lk8/gSatle6wvaeXaR8H8=
X-Received: by 2002:a25:2bc4:: with SMTP id r187mr52894861ybr.150.1555552523533;
 Wed, 17 Apr 2019 18:55:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190417215434.25897-1-guro@fb.com> <20190417215434.25897-5-guro@fb.com>
 <CALvZod5K8SM2EQFH1WM9bbwWBtyXWb_PvzJGvF5dg1Z=bdR7zg@mail.gmail.com> <20190418003850.GA13977@tower.DHCP.thefacebook.com>
In-Reply-To: <20190418003850.GA13977@tower.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 17 Apr 2019 18:55:12 -0700
Message-ID: <CALvZod6UiTeN40RgpE-4zE5zagSifqh3o_AXaw8o-ubVUWf=4w@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm: rework non-root kmem_cache lifecycle management
To: Roman Gushchin <guro@fb.com>
Cc: Roman Gushchin <guroan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Team <Kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, 
	"david@fromorbit.com" <david@fromorbit.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 5:39 PM Roman Gushchin <guro@fb.com> wrote:
>
> On Wed, Apr 17, 2019 at 04:41:01PM -0700, Shakeel Butt wrote:
> > On Wed, Apr 17, 2019 at 2:55 PM Roman Gushchin <guroan@gmail.com> wrote:
> > >
> > > This commit makes several important changes in the lifecycle
> > > of a non-root kmem_cache, which also affect the lifecycle
> > > of a memory cgroup.
> > >
> > > Currently each charged slab page has a page->mem_cgroup pointer
> > > to the memory cgroup and holds a reference to it.
> > > Kmem_caches are held by the cgroup. On offlining empty kmem_caches
> > > are freed, all other are freed on cgroup release.
> >
> > No, they are not freed (i.e. destroyed) on offlining, only
> > deactivated. All memcg kmem_caches are freed/destroyed on memcg's
> > css_free.
>
> You're right, my bad. I was thinking about the corresponding sysfs entry
> when was writing it. We try to free it from the deactivation path too.
>
> >
> > >
> > > So the current scheme can be illustrated as:
> > > page->mem_cgroup->kmem_cache.
> > >
> > > To implement the slab memory reparenting we need to invert the scheme
> > > into: page->kmem_cache->mem_cgroup.
> > >
> > > Let's make every page to hold a reference to the kmem_cache (we
> > > already have a stable pointer), and make kmem_caches to hold a single
> > > reference to the memory cgroup.
> >
> > What about memcg_kmem_get_cache()? That function assumes that by
> > taking reference on memcg, it's kmem_caches will stay. I think you
> > need to get reference on the kmem_cache in memcg_kmem_get_cache()
> > within the rcu lock where you get the memcg through css_tryget_online.
>
> Yeah, a very good question.
>
> I believe it's safe because css_tryget_online() guarantees that
> the cgroup is online and won't go offline before css_free() in
> slab_post_alloc_hook(). I do initialize kmem_cache's refcount to 1
> and drop it on offlining, so it protects the online kmem_cache.
>

Let's suppose a thread doing a remote charging calls
memcg_kmem_get_cache() and gets an empty kmem_cache of the remote
memcg having refcnt equal to 1. That thread got a reference on the
remote memcg but no reference on the kmem_cache. Let's suppose that
thread got stuck in the reclaim and scheduled away. In the meantime
that remote memcg got offlined and decremented the refcnt of all of
its kmem_caches. The empty kmem_cache which the thread stuck in
reclaim have pointer to can get deleted and may be using an already
destroyed kmem_cache after coming back from reclaim.

I think the above situation is possible unless the thread gets the
reference on the kmem_cache in memcg_kmem_get_cache().

Shakeel

