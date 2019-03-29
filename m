Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24F70C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 16:00:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C62642070B
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 16:00:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Xjf8FyZo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C62642070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 648316B0010; Fri, 29 Mar 2019 12:00:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F4986B026B; Fri, 29 Mar 2019 12:00:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 509FB6B026C; Fri, 29 Mar 2019 12:00:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2016B0010
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 12:00:46 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id s76so1901950ybi.23
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 09:00:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4V5sQShKmoDEmjjbDrynbQSxEwhXjukz0aLZkhIYYv4=;
        b=rF8IVvqyhSsGlzElqkwzRn3dKtNqp8oYfwZ32WLH2llzhLeNqrQGvF8l8+Dyqf1gY6
         BBCEEQhX7cFq5Ens2AgwDbTuu7XJnfGlS7DGA28RmaMjBb5OsQUeZuXE8g9CM5uSKMIp
         SlJOooarv2bo46+CJMoz7tRZnMHvnt7xS9aTFIcxItN4fMLzTrbqrO2YqeadHy76bRoK
         ZEA1Ld4Hayw8Pr7+xpHJ1TvwreVUxaRWmayf+ImOnPzyukK6ztBU9SzV1GWhyFBKKzCE
         0hFGnQikHeSeX8m0ponCzHPLP00pgFaUCQRUMFm3Vb3CtCfxAL7qEUWUFvwOqhRvppx3
         eAUg==
X-Gm-Message-State: APjAAAWyOgi0Bj1zgEYWhGRliJISVZrjvy5pCuzcoyzK7vyppw2N3/ss
	UzU+8eA3KkU+U70EhblXaQwAHpxZDFDo9dGaFkM+kR2K9NpNLh+WAwawMKCkPsBX1OlZlvmiPIP
	ROwx/YaeXPRZP/xpZyZfCShxHyZ6s5x0mgCRFPxZGVlKli/HK/hv/VRxRUlZur6uBnA==
X-Received: by 2002:a81:1d10:: with SMTP id d16mr40623150ywd.449.1553875245792;
        Fri, 29 Mar 2019 09:00:45 -0700 (PDT)
X-Received: by 2002:a81:1d10:: with SMTP id d16mr40623081ywd.449.1553875245072;
        Fri, 29 Mar 2019 09:00:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553875245; cv=none;
        d=google.com; s=arc-20160816;
        b=vHmmo3BJluJj9Uo78P3xeUbAQNE+LKYpmt4ULNGkePia8MSCpNiTcvkZvmNo910xQp
         ieYaEANGvzdOMzyRVKVdWUqEYcuuM6D1l0i2YqaVtlr2PpMUqO8aiD5a6nzqJmxX2wXI
         wNj2umVYHCwDvmm/HmOiv/QqfmF+PTXWKh8G7TxJwWp/sjXSQuF/2eqgjCHv5yXDVhym
         HXeijLI5Atgu7wq4ZGAYWojWx023ue67WCfxt8wdoP9mGy+yzNgWguxzCVKcwBDWcLII
         koHnA1BKuCswepHjdpYlVp5vvOVKuLnGOkVxh6fOaRK3z4oX+Rj0KHjqGGczI9XUnlLC
         QSHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4V5sQShKmoDEmjjbDrynbQSxEwhXjukz0aLZkhIYYv4=;
        b=WXnaf8x4slow4TXDPdqnEUM5QIeArGZ4baVNnE2VlZStFeoDdX1bcxPpDHwlbmBVN2
         FJUbS53r4G/JQx/x6NiA4fDX/WigTmpg3N6hoJOULVnoIsHlD5kEgtoQa7GA3vpGZnIF
         65QLnGe9UfpI7FhqLTfAsQMxUb5JgJodzO5PnWUo1Xql/MDIHlqtxpUhMoHqE4SdSPFb
         rOQk5rzVvfhSufkbvsWvT7Ytx+dIw2AQjV47X9V6mu/8u9ebev1hIzbBXzqs6pSX+hUH
         TXGK1vg3Ould02Gd4YpByJ3y2jnxmhJkoWt2KyAbw48oFGsJvA2MLdxp2YJ40gU1sYIP
         Ssrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Xjf8FyZo;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d10sor917180ywa.192.2019.03.29.09.00.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 09:00:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Xjf8FyZo;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4V5sQShKmoDEmjjbDrynbQSxEwhXjukz0aLZkhIYYv4=;
        b=Xjf8FyZoJnfK7UXhcyUKPo5VUYyrf3DnYUcJ9U4X70Yu5KAwlKJi6rPsLNlKoQ33rs
         f6pyWEKkSMuVDklPNlOxdZVssB1gIRQD03r7NTChqQcWnGDlT7qfeH8N0241cOGU4WLp
         pADXJEs74am39QIE6iXUA39pxOTEhwWUZXyxScjNFiwgY2NpexJjYbFPfQd8USWYx471
         dJ2AmaH6qlepKzm3z81T2HrDO9pArk7R2TAEcLRnID0DVQe0VrCGeOfZ3iFxAjcQofqc
         nQIc52uk+tb/ZCLLDRpyUo378xFHEO6oOoZ7b0kW6MaBVkeR/5/+FkZnfqnL52qLl5PP
         iKzA==
X-Google-Smtp-Source: APXvYqyAhuC4YfxtINnB6mmpwBdddcY+Smqv25npb0ZUAJEjPO5XDmEj7HCfZV3EjUUEQPhPztXoy47rSpSBvJlSixA=
X-Received: by 2002:a0d:e6c9:: with SMTP id p192mr7150620ywe.255.1553875244213;
 Fri, 29 Mar 2019 09:00:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190329012836.47013-1-shakeelb@google.com> <20190329075206.GA28616@dhcp22.suse.cz>
In-Reply-To: <20190329075206.GA28616@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 29 Mar 2019 09:00:32 -0700
Message-ID: <CALvZod5foPZvaD5jTBH9a7bdtMys6MdDLV=D-BLcUMU1Q7EZPw@mail.gmail.com>
Subject: Re: [RFC PATCH] mm, kvm: account kvm_vcpu_mmap to kmemcg
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
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

On Fri, Mar 29, 2019 at 12:52 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 28-03-19 18:28:36, Shakeel Butt wrote:
> > A VCPU of a VM can allocate upto three pages which can be mmap'ed by the
> > user space application. At the moment this memory is not charged. On a
> > large machine running large number of VMs (or small number of VMs having
> > large number of VCPUs), this unaccounted memory can be very significant.
>
> Is this really the case. How many machines are we talking about? Say I
> have a virtual machines with 1K cpus, this will result in 12MB. Is this
> significant to the overal size of the virtual machine to even care?
>

Think of having ~1K VMs having 100s of vcpus and the page size can be
larger than 4k. This is not something happening now but we are moving
in that direction. Also

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
> IIRC the only purpose of PageKmemcg is to keep accounting in the legacy
> memcg right. Spending a page flag for that is just no-go.

PgaeKmemcg is used for both v1 and v2.

> If PageKmemcg
> cannot reuse mapping then we have to find a better place for it (e.g.
> bottom bit in the page->memcg pointer or rethink the whole PageKmemcg.
>

Johannes have proposal, I will look more into those.

Shakeel

