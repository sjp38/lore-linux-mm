Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7B42C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 18:18:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5B5A20863
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 18:18:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QlQaK2P+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5B5A20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27D6F6B0005; Wed, 22 May 2019 14:18:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22CF86B0006; Wed, 22 May 2019 14:18:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11B326B0007; Wed, 22 May 2019 14:18:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id E6B756B0005
	for <linux-mm@kvack.org>; Wed, 22 May 2019 14:18:49 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s16so2428450ioe.22
        for <linux-mm@kvack.org>; Wed, 22 May 2019 11:18:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Oc3bQLWhGweMis4fWbACzNfmEcHdr/Fqo1ToP3CI3js=;
        b=Hy5uBJ4tA/VbCFAc/UQkmzBwKQeaTxQEzZQakbyYRwnFsKxdmOzFnZisO1Jj02gEdI
         dEx3vcTmtVqFJ9MVRb2TkIAYqA8O4o2+kugfECQ79eD9rad5qgrh4hjh+U3rEKuHfwTs
         UcDToT+mu093G3vlCCcLE2BNEla9GCX2mNvj9ZkUs449HgC5AAJeFhXuRKzqzLqBcoWu
         DTApN8IujVBcxBEi+bp0D8J68dBBwroVH7B6srGLJ6yrIJLDaWM1kB/JTJ1cwZAvmPm4
         nY5a6ZaJ06j7WblgRcklKyZpI7fTQiOow/OgX6jkgyx8uAJOpdkmnxIouLXI9u3R8s9r
         EKAQ==
X-Gm-Message-State: APjAAAU/Gs9Lr4SZyIa2lnVXhpUnhLfo94QTUkCyWA31OkQvmuyghQo0
	w6oRBkltRTaCPm535ljmtfusPAHG2UrILnhyNmd1KNKZIENKb2S2gZLHiJknLUrqIpfhj188uR5
	Ng5wnrQbhRWbI145GTzsoK3hptQcBLo0M4QkgO9vCIn3wTRDNprhDYjvddYgcarbGdw==
X-Received: by 2002:a24:b8c2:: with SMTP id m185mr9429683ite.0.1558549129682;
        Wed, 22 May 2019 11:18:49 -0700 (PDT)
X-Received: by 2002:a24:b8c2:: with SMTP id m185mr9429615ite.0.1558549128707;
        Wed, 22 May 2019 11:18:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558549128; cv=none;
        d=google.com; s=arc-20160816;
        b=IEekFqFezuyuG7mAiJzPZdvOetf5P6LSxG+usoZKTgfRNs4a3Nx8Xut3yz6FoivqMX
         ufJ8EuaMqJ1wZw+Ls97t8CjzdqYgdZ6gIBideLPdrRQiG3LTbAUtfmqJQ0f8SmYFK0Nc
         x/cDnKYfNSZ2Sp7tXFFhYR48WFMZCoOTlHjC3owjloZCNBCvQNdLmsMof1Qrogo7H10t
         n7oYxJxnpJoYiTX4PxJ9QS9aJ3mJSlsoPw8yZ4j6X4qlSJgEBKx2UxR+Nhn9yjfe5AHv
         LYL6kRwaVprsd4vHJmGur1OxPNvaUJhyZMMTfpzf+iCLWP5QyKBIKwdG2tcMqjOzEvP3
         huYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Oc3bQLWhGweMis4fWbACzNfmEcHdr/Fqo1ToP3CI3js=;
        b=RdoH/WVhmHdXbLDxpCWG0cKhG1Vt0RN1oCfpEDVlIRiJL4yHfDRe6zfMa1UPPpPs8Q
         cKtIJPGxsHT2FHtYs1jBP3HAK4PQIwXDIWJneVl0o87HujxEsfvud+BAer3S4V8deUNV
         mDPgrd88kiR9IxSIt/G+5hT5ZgSQGC/zRyCJtUklzIANn/JXq0AVcsoL25oQx8LJL0zB
         GlPxDCg8JiprdxihJPLrn1ZTkgd6w9JVJ+VGTidO+ykW+46YNlLH5Nq/dz/8+rabH8dm
         3O+niHTV/0diH+ysdbFPKzl+MnhLrRNMGl7S7XieWxyiHCWQUgjVg9NvRR6Ap4hOuQ41
         QCjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QlQaK2P+;
       spf=pass (google.com: domain of koct9i@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=koct9i@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor12712291iod.54.2019.05.22.11.18.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 11:18:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of koct9i@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QlQaK2P+;
       spf=pass (google.com: domain of koct9i@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=koct9i@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Oc3bQLWhGweMis4fWbACzNfmEcHdr/Fqo1ToP3CI3js=;
        b=QlQaK2P+0dNR9ypQ4OGuZYMLFCKkdci+YfCkVNBe6COsTQS2DPV11mNYcq7tRRrGLe
         BmranLCA7JuTHZhPDItrCR7un7Bf5dse8rPrKQiPxy5jQ6KSDbW1FZ4QYfXqBwQPLCaI
         aBXt+FVpPrQ/8RYXwLRRtk0LvP/mvejfYDbVke8SGGSkw6OTFK6pbs0cXrrOiEj8y+ec
         huaq+5IPo6T/XOU05pTr7EP42hMjv4Q5fKyjdW9r7kCruNo5gFOY/w2gyBFYVEf/b9bG
         gsiAXl93bu7o8el+3j8SkPdNGvtRZLp3MrswmlaPGFV48nfU7Qf2IndL9VZLA2pKlAz7
         NXJg==
X-Google-Smtp-Source: APXvYqzryR1p6C7aJHM3BCsQYpOhjrOy5oLO7EdNFedee6EaOmBlFfxoJBwTe7QkNoowKtV9thkMZTUBtYPqwqEtmW8=
X-Received: by 2002:a6b:7a49:: with SMTP id k9mr34067950iop.73.1558549128373;
 Wed, 22 May 2019 11:18:48 -0700 (PDT)
MIME-Version: 1.0
References: <155853600919.381.8172097084053782598.stgit@buzz>
 <20190522155220.GB4374@dhcp22.suse.cz> <177f56cd-6e10-4d2e-7a3e-23276222ba19@yandex-team.ru>
 <20190522170342.GA11077@tower.DHCP.thefacebook.com>
In-Reply-To: <20190522170342.GA11077@tower.DHCP.thefacebook.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Wed, 22 May 2019 21:18:36 +0300
Message-ID: <CALYGNiM9K6CTL+d5fUDgMFxQ_6xqtABOUhzFwbSm8zErmPZdZg@mail.gmail.com>
Subject: Re: [PATCH] proc/meminfo: add MemKernel counter
To: Roman Gushchin <guro@fb.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Michal Hocko <mhocko@kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 8:04 PM Roman Gushchin <guro@fb.com> wrote:
>
> On Wed, May 22, 2019 at 07:09:22PM +0300, Konstantin Khlebnikov wrote:
> > On 22.05.2019 18:52, Michal Hocko wrote:
> > > On Wed 22-05-19 17:40:09, Konstantin Khlebnikov wrote:
> > > > Some kinds of kernel allocations are not accounted or not show in meminfo.
> > > > For example vmalloc allocations are tracked but overall size is not shown
> > > > for performance reasons. There is no information about network buffers.
> > > >
> > > > In most cases detailed statistics is not required. At first place we need
> > > > information about overall kernel memory usage regardless of its structure.
> > > >
> > > > This patch estimates kernel memory usage by subtracting known sizes of
> > > > free, anonymous, hugetlb and caches from total memory size: MemKernel =
> > > > MemTotal - MemFree - Buffers - Cached - SwapCached - AnonPages - Hugetlb.
> > >
> > > Why do we need to export something that can be calculated in the
> > > userspace trivially? Also is this really something the number really
> > > meaningful? Say you have a driver that exports memory to the userspace
> > > via mmap but that memory is not accounted. Is this really a kernel
> > > memory?
> > >
> >
> > It may be trivial right now but not fixed.
> > Adding new kinds of memory may change this definition.
>
> Right, and it's what causes me to agree with Michal here, and leave it
> to the userspace calculation.
>
> The real meaning of the counter is the size of the "gray zone",
> basically the memory which we have no clue about.

Well, all kernel memory is a gray zone for normal programmers.
They have direct control only over anon and file-cache.

I want to invent simple metrics for 'system' memory usage.
It's about the same as separation cpu time to user and system.

> If we'll add accounting of some new type of memory, which now in this
> gray zone (say, xfs buffers), we probably should exclude it too.
> And this means that definition of this counter will change.

I'm not very familiar with xfs internals, never digged into it.
I've excluded buffers because this is simply file-cache for block devices.
Filesystems use it as cache for metadata. But userspace has direct access to it.

>
> So IMO the definition is way too implementation-defined to be a part
> of procfs API.
>

Ok. User/kernel memory separation could be redefined in more
abstract manner depending on the data access.

