Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9031CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 03:59:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BE00206DD
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 03:59:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="EkcTR7Mh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BE00206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C7E96B0007; Thu, 28 Mar 2019 23:59:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 776CE6B0008; Thu, 28 Mar 2019 23:59:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 667376B000C; Thu, 28 Mar 2019 23:59:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 488C46B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 23:59:58 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id a75so731008ywh.8
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 20:59:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sodBEomwfUZX4txDWtjSVMZxEBAIq/0o8L2NFyjYD0g=;
        b=L1Uxu7AGAqbk5u21f0hxfWSrWjp1metzCgqvJUWigKPHXmYNC0y/faGDgAmwz6lmlT
         ifzLp7ghIGqdpQtPvWOvmtTqpazTeGV89H/0WMI5UDq8F+tCksl3WLyLvAvtQTG+uHES
         1NEXbmVGcwdVrUdI82KY5Uk/ZNIxNceVnjEVltYaPcHP/lGY0/ie8GPyq1M53S09apHs
         tzPfB8cXpgstWd7LXgJ+xcZXaMhGvYMFTsDWUMiVsgfs43kzM3Y7I5yTebtD18ZhsmHr
         9yqYDeHxGddga7nFatEMdJTkltv3edKmiRVZor+a12nedGF1TcXnBA0lVyfWittyYcsq
         aqmQ==
X-Gm-Message-State: APjAAAXjRjxQ9GbOH7dRLtakuPfDdXx9aPQ/23UXo5waom5eZSGlKZx4
	zdzR8bCxh7OoXCZAjypmj8SLVboQsy04zh83ONNqm4Jqz2HZye58i+Nq6x/1/BFIfJywdTinkGC
	NK4GMn7pF+vO2L/6iitHzaFG2Z5oRLVeec8GtfOcxWGOHv1+WHmq6XiyuZNKVGwHZJQ==
X-Received: by 2002:a25:50d7:: with SMTP id e206mr1301266ybb.266.1553831997979;
        Thu, 28 Mar 2019 20:59:57 -0700 (PDT)
X-Received: by 2002:a25:50d7:: with SMTP id e206mr1301236ybb.266.1553831997103;
        Thu, 28 Mar 2019 20:59:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553831997; cv=none;
        d=google.com; s=arc-20160816;
        b=RVGsZO3U3tI6EDiHS44bWrjiY8MKM4SiDTmUljW6yVbeiTnSvwZHQvBGF34unyFWyk
         zmQfTs8CEjM2N8xURSslVGX7oZd03QafhKafuAnwqUH5jEaFVfvq7AMSfv4wqEO83LDK
         j2MuSGlnSLz+7nRa9/WV3M+kIZgmSgRB0ktv7rJ4xiXXvPofCH611a4j36vqJc473R/Y
         4l20dq5pkgMUZbhu+lAFXTwwFIaDaXzj1xbvvECWiBs2kvpT4mW528WJyd9D26yCpJZg
         FYgPER9dCCxWRa79N86/a3OlPZIAshA303gMEX03EWE17MKPiwy5bBxEURVsX0ivTW/x
         femA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sodBEomwfUZX4txDWtjSVMZxEBAIq/0o8L2NFyjYD0g=;
        b=XQO5pc0CWyCRPeDdHPqth8A2gll6h5zHipPunXjQ1ao3wM46K3y/saQt6YKhQajQjx
         81KrkpIzoQCVB/GlvPmq2HZalHGyUag9pOSMp3/Tjic4IpFqNUyeeJjDw9/IaVWe5k34
         K8MfJra6mO9Qa/1EE8LNmczR9+EUntsiMymoerwASiGS4wNI691JVIZWE7Uha5HKV+Nl
         tyQJaNElFmTwiR6GI/QtElpsOTrVyrXsQKe/ThsXqH8DVrldKL35XZwUR48VOGAfAvDA
         c2YOQbC1xWlLvVUaP3gUcGUqR0qXTmrY0QUOQ53QcO60cwsQC4PArvZ5Ollt04JJS9tI
         QsXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EkcTR7Mh;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 135sor301406yww.116.2019.03.28.20.59.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 20:59:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EkcTR7Mh;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sodBEomwfUZX4txDWtjSVMZxEBAIq/0o8L2NFyjYD0g=;
        b=EkcTR7MhCLUJ3wg1Mkfze+pvFsS9FB7+CPtJTkogY2qjrCBEdYGc1kiyAGuFvCKbFX
         /i3X0AdR8j1gSbjYvOqorKAxMkFweTtSd3UfZW6lzzItqCBTx2wG/e8X0/Sv6auOmel6
         3w4v/O/rNX74uhId2sTheecpJUaZGonuf10NeAc9RXnfWan/Dgxn/0a5psLOH55uOZvZ
         rG4OaN15bq3MAiQGV7Q4jjmSOldrVYzzDyky9mMZ3oozjvW/EHRclj7HEPvtKOAMk1ZC
         LpTpok6yvbeh61jPs1j2Nb1prK/UfFE9QnuBubIq8wY6AwhnFDjcQnN0Pw/PpbcWXRiI
         qrFQ==
X-Google-Smtp-Source: APXvYqxuG02NZLurFciuM9gsdcxHoqpf5aEBrqH2HonpHDdVpXor894q8P+U1qJC2MJKs8kgzcwU4hs8pReSX8zYJ60=
X-Received: by 2002:a81:1b52:: with SMTP id b79mr39274302ywb.285.1553831996530;
 Thu, 28 Mar 2019 20:59:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190329012836.47013-1-shakeelb@google.com> <20190329023552.GV10344@bombadil.infradead.org>
In-Reply-To: <20190329023552.GV10344@bombadil.infradead.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 28 Mar 2019 20:59:45 -0700
Message-ID: <CALvZod5GiC1+HB3_Mm969Qbgj7s6-unbd141uP5pnMbsufS+mg@mail.gmail.com>
Subject: Re: [RFC PATCH] mm, kvm: account kvm_vcpu_mmap to kmemcg
To: Matthew Wilcox <willy@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, Ben Gardon <bgardon@google.com>, 
	=?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, 
	Linux MM <linux-mm@kvack.org>, kvm@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 7:36 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Mar 28, 2019 at 06:28:36PM -0700, Shakeel Butt wrote:
> > A VCPU of a VM can allocate upto three pages which can be mmap'ed by the
> > user space application. At the moment this memory is not charged. On a
> > large machine running large number of VMs (or small number of VMs having
> > large number of VCPUs), this unaccounted memory can be very significant.
> > So, this memory should be charged to a kmemcg. However that is not
> > possible as these pages are mmapped to the userspace and PageKmemcg()
> > was designed with the assumption that such pages will never be mmapped
> > to the userspace.
> >
> > One way to solve this problem is by introducing an additional memcg
> > charging API similar to mem_cgroup_[un]charge_skmem(). However skmem
> > charging API usage is contained and shared and no new users are
> > expected but the pages which can be mmapped and should be charged to
> > kmemcg can and will increase. So, requiring the usage for such API will
> > increase the maintenance burden. The simplest solution is to remove the
> > assumption of no mmapping PageKmemcg() pages to user space.
>
> The usual response under these circumstances is "No, you can't have a
> page flag bit".
>

I would say for systems having CONFIG_MEMCG_KMEM, a page flag bit is
not that expensive.

> I don't understand why we need a PageKmemcg anyway.  We already
> have an entire pointer in struct page; can we not just check whether
> page->mem_cgroup is NULL or not?

PageKmemcg is for kmem while page->mem_cgroup is used for anon, file
and kmem memory. So, page->mem_cgroup can not be used for NULL check
unless we unify them. Not sure how complicated would that be.

Shakeel

