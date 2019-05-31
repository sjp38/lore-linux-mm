Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CF70C28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:59:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8F4D26B37
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:59:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="wuALX1ds"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8F4D26B37
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C8906B026F; Fri, 31 May 2019 10:59:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2789A6B0278; Fri, 31 May 2019 10:59:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18F396B027A; Fri, 31 May 2019 10:59:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id E6CE76B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 10:59:41 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id l63so3587570oia.7
        for <linux-mm@kvack.org>; Fri, 31 May 2019 07:59:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gkjgr9yAq+VhnnIt5t0RaPzTkMpIeWNJYrEuBA5bAY4=;
        b=H5YhU/gEfkgWAPC0n2XN/FesI4kGxPkaF4z/vS+nF3KQjhKFNZT57VprDmTnrUrM3/
         SkfDgVeCI1+9PlswLSWUMSDu6AR23rYtBNpb97inWZUWfqDklYITHLuDdSCmxBv9Hzgt
         6LFZ2bbiTbOLHQWTkxW59qm5zh0yAXqTSnaUoDXHuVAzXANM1cJgsKwJLwtpG5ktfsqD
         DDvYCTPpU/Dizp+VliYoAyYeWnPKxC8pYNlVSgiXCFIehAZd+aW3ckqSfM8OhCqexVz2
         gPSxStK1bCmY2gBq6nUmhaqvHQDmzAktc9BTOVnAGboTzCh1FaikDRJzym1W5QtFOwZF
         TPqQ==
X-Gm-Message-State: APjAAAVDR0VWeJaW43HGxxirPLbHslpOF9c8rY3MwE6lB2vlM34mPJw6
	lghKDsDJWIcoucQpIsrWXAQMCyLg4JDuHyf1CsCusU7cI6i/Tci40Fry8miu6AI6j9ookTQ2/vW
	7pdJfGKUqUkwKopwjrpRWAe56I7b3d8zAJjtpfEjRNb6M7rr5qn4YLIqY+sW04lSrww==
X-Received: by 2002:aca:d88b:: with SMTP id p133mr5375219oig.3.1559314781537;
        Fri, 31 May 2019 07:59:41 -0700 (PDT)
X-Received: by 2002:aca:d88b:: with SMTP id p133mr5375183oig.3.1559314780874;
        Fri, 31 May 2019 07:59:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559314780; cv=none;
        d=google.com; s=arc-20160816;
        b=BB/fLnb/MZ4PF0AjtZiHX8nGHeUR6f9LEtUh+uf5RsSuf0EL2OhWlOcOHGoekmdPWV
         v+fpKVb/Mxs9KwKcgqltY6L1Kv7CzFBZKuRGBydyZMzex+f16AOtLIozu2OGr3SxAA+X
         dapkB1N3T10bm/q0v4m+8SS7LRWIBvtoX6wHs6JhoGi9DHCN0ptmkpaLXYXyriAsTRN4
         Rdjlq5CJnsRORAKnl1a7gtadgwhISQgh4L5PJIsXh8tOIXScHZ2eroUJy5pb/quk54zU
         mGUEBLTaSYNQMyPG6/3znF7FW1ym4HL7+Dbj0Ejl1j7ffjuXCIAqdt0Na8MORUHrlMne
         LH7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gkjgr9yAq+VhnnIt5t0RaPzTkMpIeWNJYrEuBA5bAY4=;
        b=zwUmSwmLWFUAnQZ2w6J4tbkIjSk0PowPrCdy5WDpvzaemUHnuTHdf7tukIqhiPRg49
         2ctmObaSMV38dHCb2+mLWKmoK3nRCWQPg2+BOAe8IuWFxtrKa3InxqmOEylq3CUtaG2b
         dE1NQmWfJN089w5cdFS3K58whhzUy5gga1SqdcSG8l72a3c+3JlH5eJVvx+HYkvZViWp
         DDeolx+8bp1CaTILts77DGoc8efU6oeFGmrH5TZCAuhecKYL/ICh+d8Sxo12SFGMGyBl
         N8M6WWvxPkokhmhNAVmJ7BxIAFTy0UQA4w+Xv9uGTjNYIp3U2oYAKIU9l6dqJCYh/y8z
         udug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=wuALX1ds;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4sor2983587otq.175.2019.05.31.07.59.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 07:59:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=wuALX1ds;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gkjgr9yAq+VhnnIt5t0RaPzTkMpIeWNJYrEuBA5bAY4=;
        b=wuALX1dsEVY6xCVhPDDDGuSpN6wnECHReOyE/T6CGO5EOwmGiJJwGPmhE7Ls/LTmZj
         k9a53MPPnTG2Xl3DCJuMUQTLVWZ0MTaq91bcxe2buFfCgv4m4p73z0cN+T9o4RExfzEI
         PVmANmnSmNdsXekO7tYe2xfPJMWkEXOduZ4LfbZq5hFqAN5oQv7TsVMsLaWjzCTTkXIk
         qpjBBB70swa9i43eULEvRpovxAhGjq3moOMow2nluRvxO2o8BhSmAi6m5qRSfbVBG5+p
         TdhvwucQ/LfYApSKBBASABxtO+MCKfSA9XJEFlpOa+/e4ECKHx2souc8xpsDSEV8WsBh
         IVRA==
X-Google-Smtp-Source: APXvYqyEy2uoSeMif4klObB48qoPaiK9up6/IKR3TQTeJ3zBAsdV8u4dmVPKTkeVoooxLhERezABZp9xoq24sg44nUc=
X-Received: by 2002:a9d:2963:: with SMTP id d90mr2134041otb.126.1559314780136;
 Fri, 31 May 2019 07:59:40 -0700 (PDT)
MIME-Version: 1.0
References: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154899811738.3165233.12325692939590944259.stgit@dwillia2-desk3.amr.corp.intel.com>
 <cddd43de-62f6-6a91-83aa-da02ff17254d@suse.cz>
In-Reply-To: <cddd43de-62f6-6a91-83aa-da02ff17254d@suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 31 May 2019 07:59:28 -0700
Message-ID: <CAPcyv4g-g=Gyf0T1rENCEH_2KyLtt74kiLydxO=__tM71_bYww@mail.gmail.com>
Subject: Re: [PATCH v10 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Keith Busch <keith.busch@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 12:33 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 2/1/19 6:15 AM, Dan Williams wrote:
> > --- a/init/Kconfig
> > +++ b/init/Kconfig
> > @@ -1714,6 +1714,29 @@ config SLAB_FREELIST_HARDENED
> >         sacrifies to harden the kernel slab allocator against common
> >         freelist exploit methods.
> >
> > +config SHUFFLE_PAGE_ALLOCATOR
> > +     bool "Page allocator randomization"
> > +     default SLAB_FREELIST_RANDOM && ACPI_NUMA
> > +     help
> > +       Randomization of the page allocator improves the average
> > +       utilization of a direct-mapped memory-side-cache. See section
> > +       5.2.27 Heterogeneous Memory Attribute Table (HMAT) in the ACPI
> > +       6.2a specification for an example of how a platform advertises
> > +       the presence of a memory-side-cache. There are also incidental
> > +       security benefits as it reduces the predictability of page
> > +       allocations to compliment SLAB_FREELIST_RANDOM, but the
> > +       default granularity of shuffling on 4MB (MAX_ORDER) pages is
> > +       selected based on cache utilization benefits.
> > +
> > +       While the randomization improves cache utilization it may
> > +       negatively impact workloads on platforms without a cache. For
> > +       this reason, by default, the randomization is enabled only
> > +       after runtime detection of a direct-mapped memory-side-cache.
> > +       Otherwise, the randomization may be force enabled with the
> > +       'page_alloc.shuffle' kernel command line parameter.
> > +
> > +       Say Y if unsure.
>
> It says "Say Y if unsure", yet if I run make oldconfig, the default is
> N. Does that make sense?

The default is due to the general policy of not forcing users into new
kernel functionality (i.e. the common Linus objection when a new
config symbol is default 'y') . However, if someone is actively
considering whether to enable it I think there's no harm in
recommending 'y' because the facility currently needs to be paired
with the page_alloc.shuffle=1 command line option.

