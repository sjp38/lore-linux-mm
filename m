Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93DFCC7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:09:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BE5621019
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 21:09:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g/A6ZSXF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BE5621019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D70156B0003; Thu, 18 Jul 2019 17:09:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D21738E0008; Thu, 18 Jul 2019 17:09:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0F278E0001; Thu, 18 Jul 2019 17:09:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9E86B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 17:09:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t196so24411473qke.0
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 14:09:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Dyup3V+7x6vR5f0mEdgXHm4ad/gxVODy2UYvXjZtm38=;
        b=OP0i6Oy4V73abSCpBNF3Tzh5SW02e6geq+SuKqs2L1BD0aXa70Si5KKEHI3QlodGdo
         S2Kny6uxd7iBDCgZLYSng6MA2MbknTBzKmE6n3BeELTlcbo8OfSjd0TmozEX917REtrC
         1feBRZ0mUtfC5Y3hfchUAgQCGYveSqQ8SK9jWphTS4gwLjsc/qUbEsKmPUXlEcw2Xj7M
         0j0DloOMLectflY+MmGdnszQW9VWlyF5n+0HHLJJ3KzxpCJfKhmSrHAXwNgeKwbsCv+I
         gYEw0CFBcjZft7JZlub7HwmS7iwgkZjm+9FIJHkTaMOb0y9Z/bDu4wJOzetehik1Tjal
         1K1A==
X-Gm-Message-State: APjAAAX2dCprtzZCddIsQnu87jI6B7w80ZorgEQcU8Ens+55G2IVsfex
	3SmpVoMGas62t5S9MNJGqVIEZUPIRa/XS+40y0SEVh/TeRSdba6llrpGSYz0iWQW2w4kMCQv82Q
	wJ5OGcHY/1bICTE6WcEQlW1zOI/G7XHc8njn26OCkisKTNSIMFiEDvt+7kQcSiUSw6g==
X-Received: by 2002:ac8:5547:: with SMTP id o7mr1381578qtr.297.1563484162389;
        Thu, 18 Jul 2019 14:09:22 -0700 (PDT)
X-Received: by 2002:ac8:5547:: with SMTP id o7mr1381548qtr.297.1563484161786;
        Thu, 18 Jul 2019 14:09:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563484161; cv=none;
        d=google.com; s=arc-20160816;
        b=I5+NCrBh7575Ft+3lU/izB3KGmpUWWgXhBTGd1u6PsWjEmLFoSKlckphBXpdgFIm+s
         Ci/o/FvwXEWiq8h1f40Y+Yr5PS7Fwi/czV7/jr8z87VROL+pb7bYSpHH64O1RpBVPdSX
         d4CpVXb+/Eoz0w6ZHOm8prIp1pEg3Dz9XoJSETuFKaZn8QRsRD0py0XK7xKEYX5Gwe2b
         ww8mgXhC4nF7KxitZgAwj8C5Usd6WT1VLm6WmES22hPPmbT63iP8vHE+YUSu0qmPd9NV
         ttGLfyw1TWkmTIKBtP9LaTi9LMOVB/q7x35nPPNOYFNdCcLwD4SBb/nliZx+2UArHvL8
         KuYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Dyup3V+7x6vR5f0mEdgXHm4ad/gxVODy2UYvXjZtm38=;
        b=NBm7CrLeDRj/osQ5Ktip7/1nFzvX0OEaq7HBmkUWu2fd71F68vwUk/T1m8fw6Zaric
         0jXxVgXSFKPStgcTb90TZcuvRmHMbnCqdR1SQVTtl/x1e6U9GCp/9spb3XhATAkYfTUM
         6fMJgVwmLKp0ASBJSTgSkvj2DfL0X2uNTlwFgs3odICtb8n/51hZtbPXmK/hb6uUnsJW
         1qgDxfgn9slc6WuDN6OT5T4ImpCBXIfADTOx96byb2FQLb2k+Ql7BGTVupdtI5A/u1+f
         U75SwdZVs4IY25g4sMaLqnqzI87jxWMDxtfAakX26fTRmZTil/alkuFjLBwGGaFJGL3Z
         JWyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="g/A6ZSXF";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r12sor18671019qvy.6.2019.07.18.14.09.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 14:09:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="g/A6ZSXF";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Dyup3V+7x6vR5f0mEdgXHm4ad/gxVODy2UYvXjZtm38=;
        b=g/A6ZSXFBVZwZkYYxAc6/240ZOw/nl+fyU7BjnEptzhSBtU1aTXriTXck/+BG1DVOY
         EV7nAttQx1wz7J9GFiiRlu0+0fpCDFuK708Veu0VrtQUKch3fKT7QXOYuBgA8ioW/L8g
         2yZ0VeWPfE0VAB52AKfusR8k1B+mH6sY1xsE/zS6Lw2e7m1ItUaud6iua3qpHdSKDx8W
         +J+F5QDBMqMYtZmLIUaPCxV6mlxG/HcVbe7ITBXceI3phQoSF7h/u01JzOVR0mj3Kh2y
         H9GcUErP1w0nbrRy6K7wnuPkIyOSttzXPL1P2OKYyjOOPeZvocpNWmgMp6FzpqRmFiHN
         SOfQ==
X-Google-Smtp-Source: APXvYqx/Xj+iAj6ZhkMjTX1Z+74RGCpbHhz221hQ/4tFr/eSNb0ZRWjxjhZdyPpTxY3WuORbyCrdGEBMm+KsiHIPG48=
X-Received: by 2002:a0c:b095:: with SMTP id o21mr35480609qvc.73.1563484161439;
 Thu, 18 Jul 2019 14:09:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190716115535-mutt-send-email-mst@kernel.org>
 <CAKgT0Ud47-cWu9VnAAD_Q2Fjia5gaWCz_L9HUF6PBhbugv6tCQ@mail.gmail.com>
 <20190716125845-mutt-send-email-mst@kernel.org> <CAKgT0UfgPdU1H5ZZ7GL7E=_oZNTzTwZN60Q-+2keBxDgQYODfg@mail.gmail.com>
 <20190717055804-mutt-send-email-mst@kernel.org> <CAKgT0Uf4iJxEx+3q_Vo9L1QPuv9PhZUv1=M9UCsn6_qs7rG4aw@mail.gmail.com>
 <20190718003211-mutt-send-email-mst@kernel.org> <CAKgT0UfQ3dtfjjm8wnNxX1+Azav6ws9zemH6KYc7RuyvyFo3fQ@mail.gmail.com>
 <20190718162040-mutt-send-email-mst@kernel.org> <CAKgT0UcKTzSYZnYsMQoG6pXhpDS7uLbDd31dqfojCSXQWSsX_A@mail.gmail.com>
 <20190718164656-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190718164656-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 18 Jul 2019 14:09:10 -0700
Message-ID: <CAKgT0UchVPRuM1pNnsuxcJrTg1-tWQWzW1+q=_v7VuEDS3pL5g@mail.gmail.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, 
	Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 1:49 PM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Thu, Jul 18, 2019 at 01:34:03PM -0700, Alexander Duyck wrote:
> > On Thu, Jul 18, 2019 at 1:24 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> > >
> > > On Thu, Jul 18, 2019 at 08:34:37AM -0700, Alexander Duyck wrote:
> > > > > > > For example we allocate pages until shrinker kicks in.
> > > > > > > Fair enough but in fact many it would be better to
> > > > > > > do the reverse: trigger shrinker and then send as many
> > > > > > > free pages as we can to host.
> > > > > >
> > > > > > I'm not sure I understand this last part.
> > > > >
> > > > > Oh basically what I am saying is this: one of the reasons to use page
> > > > > hinting is when host is short on memory.  In that case, why don't we use
> > > > > shrinker to ask kernel drivers to free up memory? Any memory freed could
> > > > > then be reported to host.
> > > >
> > > > Didn't the balloon driver already have a feature like that where it
> > > > could start shrinking memory if the host was under memory pressure? If
> > > > so how would adding another one add much value.
> > >
> > > Well fundamentally the basic balloon inflate kind of does this, yes :)
> > >
> > > The difference with what I am suggesting is that balloon inflate tries
> > > to aggressively achieve a specific goal of freed memory. We could have a
> > > weaker "free as much as you can" that is still stronger than free page
> > > hint which as you point out below does not try to free at all, just
> > > hints what is already free.
> >
> > Yes, but why wait until the host is low on memory?
>
> It can come about for a variety of reasons, such as
> other VMs being aggressive, or ours aggressively caching
> stuff in memory.
>
> > With my
> > implementation we can perform the hints in the background for a low
> > cost already. So why should we wait to free up memory when we could do
> > it immediately. Why let things get to the state where the host is
> > under memory pressure when the guests can be proactively freeing up
> > the pages and improving performance as a result be reducing swap
> > usage?
>
> You are talking about sending free memory to host.
> Fair enough but if you have drivers that aggressively
> allocate memory then there won't be that much free guest
> memory without invoking a shrinker.

So then what we really need is a way for the host to trigger the
shrinker via a call to drop_slab() on the guest don't we? Then we
could automatically hint the free pages to the host.

