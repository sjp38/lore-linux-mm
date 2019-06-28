Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBC5DC5B578
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:14:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80E2A21726
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:14:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="jX7l/aSc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80E2A21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18E086B0003; Fri, 28 Jun 2019 15:14:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 140268E0003; Fri, 28 Jun 2019 15:14:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFC6A8E0002; Fri, 28 Jun 2019 15:14:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f208.google.com (mail-oi1-f208.google.com [209.85.167.208])
	by kanga.kvack.org (Postfix) with ESMTP id C88286B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 15:14:56 -0400 (EDT)
Received: by mail-oi1-f208.google.com with SMTP id f19so2994236oib.4
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 12:14:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3EPvpztsPK7520nxsbDhjXQoNlIusJTLU8rYF+ocke4=;
        b=CVQnODefr7G3A/3XUluPOWAXkHkxx/sEPUWKA0hyVMEZFWAf7M/zdH5b9XsLa027RZ
         8Gy+yInv2X6QJ16g2JldYTIWdvl2HPxQ+MVvmWPCsICcT7GBVkUW7eFmcK2fSt9PQq9l
         6KWg7HgZH2kyeBDzZrcztHxeq0HMDuXUsbR8al92ZNt3/fUUwrkV7gcck8IsamPR5FwK
         xCyRA7mpQMdOHr4uCHz4pmkccoCtU+IFS7q0n/fcgBeKCFs8ka9n4SLiJWZYoLtdjrot
         l6gYWvHhPbTqU1u8zND/S9Ey/RgzYBlysrR3uqM028nEJXobyMwyDqlT6pk3Frp7eMM7
         PIhg==
X-Gm-Message-State: APjAAAU+M7dw65+bHJ4Vm2zQloIU09nG66mIZUvEi6zSBGp1v61TV9vP
	VZsWBemngllvgtTgPd3LPJATvloTPzkfplvfIjrpMXaASgkRvlE2QLrPN3Dys1Mkz8C7xhtPWy1
	eYKAZG85LILqiVdROiOUdgg8Qg+FteAG7dTqtsDgQ5CKFnFjUxNWSB9rRZ/3oz1xVNw==
X-Received: by 2002:aca:5451:: with SMTP id i78mr2642289oib.85.1561749296456;
        Fri, 28 Jun 2019 12:14:56 -0700 (PDT)
X-Received: by 2002:aca:5451:: with SMTP id i78mr2642254oib.85.1561749295744;
        Fri, 28 Jun 2019 12:14:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561749295; cv=none;
        d=google.com; s=arc-20160816;
        b=w71UjpasdPnM0TzLjjgm62BOWDegl9hmhtFW5gnil86Q2QziCMhGfJ226+0aT0u7nk
         qOIOB9TkpsWUJnOQTVmMM3t1UgcKBjLBNwSac5Q9Mp5T7mR8dwuSoJBBPVs7VsBhwHuz
         CofUrMCR2yXz1nAl8/hPOwjt4ZMIBMRvYYxuac4PVf5aVjbMDI5VrZjjfilxJ/xXyUwh
         m44JZBOKJNreMwdV3MRwK+RIznoaz7YNIyi4sR0SbTZkmeokDAkiqmwCZyRqQdqjDis+
         i/623Oqr0CfXzedr5/obYTyCm/Edoz8mDkZDayayV/09zOGMUHo0v3ZSxjWMZvuuVEEV
         8gFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3EPvpztsPK7520nxsbDhjXQoNlIusJTLU8rYF+ocke4=;
        b=xYJOL61xNMGcDNfFFmeJzr0mPjDIbaIPZquUUDs8W8YaFNmpR+V7m9wxHAYnDX3IAL
         AVn69uAf9+LltusQ8sq6DmDhJATZOeV/lpG7m1orrBEOsA178a0e01SXMIznmpaeh7xV
         +BouK5udhoNKUpf8plwDwb+m/7aNOMjr7I8M5jUUAkLotaCfemKbHJLpjA8yavSfrfek
         352hC3U7ThwMDTTZTGL9ccUZQdRpXila++PNvvIi/vuZqNriz3xqbePymune3/cPbmzR
         qIVbp3lGfhN8uGyFFGHsmwCPWXu8bThUQ6OlXBduPycgo3Fac8OAfelIr+PL3yGiswEh
         fzDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="jX7l/aSc";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7sor1793518oto.26.2019.06.28.12.14.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 12:14:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="jX7l/aSc";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3EPvpztsPK7520nxsbDhjXQoNlIusJTLU8rYF+ocke4=;
        b=jX7l/aScOnNag6NN8PLCh3f8Z8jWQa8rXqdmRFTm19zC5cGsMg4bGsXFEunae/2WjS
         ovvvaTeYJH2utyMhChKwGiGq8ZBoeIIKayiImspczzJ8SDCf8XDDL3viRbXyjtD1lYaK
         kzh/gY0uzN3viGFbDD3U65We27uV73cZy9DpexfMTRSqDZy8x6zljmPhhW1gZcx2hqFe
         GQ/mPFT2QGn+yrEJgjwPpeYXNTM2MxsKsrWYit2Wtxn/cph7hWSIQxFHWHLu8ToPNVuS
         0Ys9z5mBN7oGuoBHQrTDBIA0uIvuwg0tIL5G5RHXTDvUcDFV767ifaCgmnx0wSkTm7cV
         iWpw==
X-Google-Smtp-Source: APXvYqwk0yjTvQhVqTpz4jl7ioGiwvBTeiygz26S4gTf6ee6guEN0yjq3zRwNg6EKq8iXaiv+Kpq8rgpgiSlzbcUkgY=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr8541745otn.71.1561749295055;
 Fri, 28 Jun 2019 12:14:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190626122724.13313-17-hch@lst.de> <20190628153827.GA5373@mellanox.com>
 <CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com>
 <20190628170219.GA3608@mellanox.com> <CAPcyv4ja9DVL2zuxuSup8x3VOT_dKAOS8uBQweE9R81vnYRNWg@mail.gmail.com>
 <CAPcyv4iWTe=vOXUqkr_CguFrFRqgA7hJSt4J0B3RpuP-Okz0Vw@mail.gmail.com>
 <20190628182922.GA15242@mellanox.com> <CAPcyv4g+zk9pnLcj6Xvwh-svKM+w4hxfYGikcmuoBAFGCr-HAw@mail.gmail.com>
 <20190628185152.GA9117@lst.de> <CAPcyv4i+b6bKhSF2+z7Wcw4OUAvb1=m289u9QF8zPwLk402JVg@mail.gmail.com>
 <20190628190207.GA9317@lst.de>
In-Reply-To: <20190628190207.GA9317@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Jun 2019 12:14:44 -0700
Message-ID: <CAPcyv4h90DAVHbZ4bgvJwpfB8wr2K28oEes6HcdQOpf02+NL=g@mail.gmail.com>
Subject: Re: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, 
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 12:02 PM Christoph Hellwig <hch@lst.de> wrote:
>
> On Fri, Jun 28, 2019 at 11:59:19AM -0700, Dan Williams wrote:
> > It's a bug that the call to put_devmap_managed_page() was gated by
> > MEMORY_DEVICE_PUBLIC in release_pages(). That path is also applicable
> > to MEMORY_DEVICE_FSDAX because it needs to trigger the ->page_free()
> > callback to wake up wait_on_var() via fsdax_pagefree().
> >
> > So I guess you could argue that the MEMORY_DEVICE_PUBLIC removal patch
> > left the original bug in place. In that sense we're no worse off, but
> > since we know about the bug, the fix and the patches have not been
> > applied yet, why not fix it now?
>
> The fix it now would simply be to apply Ira original patch now, but
> given that we are at -rc6 is this really a good time?  And if we don't
> apply it now based on the quilt based -mm worflow it just seems a lot
> easier to apply it after my series.  Unless we want to include it in
> the series, in which case I can do a quick rebase, we'd just need to
> make sure Andrew pulls it from -mm.

I believe -mm auto drops patches when they appear in the -next
baseline. So it should "just work" to pull it into the series and send
it along for -next inclusion.

