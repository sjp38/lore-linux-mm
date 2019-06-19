Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06863C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:18:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BC3E2147A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:18:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="YlyPqPBi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BC3E2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 354356B0003; Wed, 19 Jun 2019 16:18:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3052C8E0002; Wed, 19 Jun 2019 16:18:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CD868E0001; Wed, 19 Jun 2019 16:18:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E84CD6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:18:57 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id i16so139312oie.1
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:18:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OMu1Eynp9KYFQ9eA5SmgvunmkEBDxoIzU+1szZNiCbA=;
        b=XWv2IgiancVPsd1JR17cj2uV1nlhDiDcILYVIVBoU05tI3zpTguXMelswQYbAuD/Mf
         G/0RuAb8wIao3gyz8wSTisTDSRVqplPheOrbOaN7wSHXLgxKgarmbv3Uytvpy+r0KAkS
         cGzj11+kl20txf5emOHJLm04Ppo1wMQiD+8Vc0T5CyT0NqSB862f90xumLTf3HgFQYoC
         FvMkK/Ecrs7YiPuj9Lfn5ry7vKLm+uaJFZx9GSD7Cj8wQS2ASdgMz618cFXls5Z32kWP
         DqKphdmk5wJ97NkvTO6FrihQazSmWYFNQ8BtUrhG/WtC3aZGEMVU2vcOvMSUFG2DPdRn
         +QZA==
X-Gm-Message-State: APjAAAWpw7uC+fD/iIToH8hZY3NV1GX9CvMyMYFxUz8tAFKNZNE9Foro
	Divii7ihhWmZS1uhGF9Nz9xBrptxUCbaLo4N3lDArE4pfFHlvlFKtT6wd+HeeF0V3WTGeTXKUS7
	LmJAr01V78DWC4Eb90+S2M2QMtMvMbKrAfW/cJDfzeQ4lKFbdDAzXYdJzsqkR/k+ygg==
X-Received: by 2002:a9d:66c8:: with SMTP id t8mr13338717otm.94.1560975537656;
        Wed, 19 Jun 2019 13:18:57 -0700 (PDT)
X-Received: by 2002:a9d:66c8:: with SMTP id t8mr13338669otm.94.1560975536895;
        Wed, 19 Jun 2019 13:18:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560975536; cv=none;
        d=google.com; s=arc-20160816;
        b=PLSkYr5rO640lJJijM/j9D5ORiv2hbYJ0N+zCtwhFWm9Kh1sLMJ/crIKstDoFOAgN1
         Kr1xNAH1M8/BvmVe9sv55tYzGhqKWSml1SWTnFyj8ceLWg5v4WsXfz6lMT9/eXMhiz++
         obWn9dn1P6us2t7bS5OpnHFXPkbNVs3HpO/wow3wUxkuewNIToSILo/n1gWeDNHAJ4/U
         bOVTUZtII5WhW3cCi+6Oenw2bacURTrYYK0SIpvjbRs8trCm/7wO9iISXnPmkqktolXr
         iuNBQAXQHdexQmstwwH5E4wuo3lMT3ouekPo5CuEb5Awt0/iOcyrOkowMorrPE/0GKsk
         tLKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OMu1Eynp9KYFQ9eA5SmgvunmkEBDxoIzU+1szZNiCbA=;
        b=M+1lF3VU/CFf4PjBh4zTiYaemRDOZBvfUir5ExAwVXdd6leJ9ARaV+oZDvokGrK9Mn
         hs7AgVtIgISS+gQ6AUov9cD8ymu5UYh829z/4CRF6UUDtCZLyXkdSoBQAVxcMe2/UyE7
         t7JO0O5Sph7pNdpMlctKC3ww++Cod5Bh9lRRDtUcRksRCWDFR+LLsj/iRU87r1yE97m1
         1D2CCyxB1wfQedhFd670Zl598Ve+4YuIVlt53bcX7FENZvstIhXxTy6fZPHuAIZJ3jo7
         jxw4Mkkpm5EMSK5/KoRTvaR7fa+jLJqHoe0v0S7xwqPSdbAglBr/+cvSv9RKiSmZOe6E
         Nl/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=YlyPqPBi;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f19sor5606355oto.86.2019.06.19.13.18.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 13:18:56 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=YlyPqPBi;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OMu1Eynp9KYFQ9eA5SmgvunmkEBDxoIzU+1szZNiCbA=;
        b=YlyPqPBiPTfkDOdJ5VJIj4DFNeLCKL8DI+SUapLpqcyHkZ3w7UdvlSsXa0Oewx+gIO
         ls8A9xGbEJDVy7wX+7Wrp2Y2dOkXE2UKcAt2aGPDe8APV+r21JZ69QC/JyzdhFWazDwg
         T44DzMD+35dNL6M4TaFtbY9aua85SEnMj9gpc=
X-Google-Smtp-Source: APXvYqw6bgG2GsUkNVmJ8zuOKu1tc9Z6lf4W2oeXwaheE4AOJs5xOP8C+LQrEQLCr9yBSA9ecTAu4RInlgBAYdXylok=
X-Received: by 2002:a05:6830:ce:: with SMTP id x14mr5140545oto.188.1560975536589;
 Wed, 19 Jun 2019 13:18:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
 <20190521154411.GD3836@redhat.com> <20190618152215.GG12905@phenom.ffwll.local>
 <20190619165055.GI9360@ziepe.ca> <CAKMK7uGpupxF8MdyX3_HmOfc+OkGxVM_b9WbF+S-2fHe0F5SQA@mail.gmail.com>
 <20190619201340.GL9360@ziepe.ca>
In-Reply-To: <20190619201340.GL9360@ziepe.ca>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Wed, 19 Jun 2019 22:18:43 +0200
Message-ID: <CAKMK7uGtXT1qLdUqnmTd9uUkdMrcreg4UmAxscx0Fp4Pv6uj_A@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: Check if mmu notifier callbacks are allowed to fail
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, 
	Daniel Vetter <daniel.vetter@intel.com>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, 
	David Rientjes <rientjes@google.com>, Paolo Bonzini <pbonzini@redhat.com>, 
	Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 10:13 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> On Wed, Jun 19, 2019 at 09:57:15PM +0200, Daniel Vetter wrote:
> > On Wed, Jun 19, 2019 at 6:50 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > On Tue, Jun 18, 2019 at 05:22:15PM +0200, Daniel Vetter wrote:
> > > > On Tue, May 21, 2019 at 11:44:11AM -0400, Jerome Glisse wrote:
> > > > > On Mon, May 20, 2019 at 11:39:42PM +0200, Daniel Vetter wrote:
> > > > > > Just a bit of paranoia, since if we start pushing this deep into
> > > > > > callchains it's hard to spot all places where an mmu notifier
> > > > > > implementation might fail when it's not allowed to.
> > > > > >
> > > > > > Inspired by some confusion we had discussing i915 mmu notifiers and
> > > > > > whether we could use the newly-introduced return value to handle some
> > > > > > corner cases. Until we realized that these are only for when a task
> > > > > > has been killed by the oom reaper.
> > > > > >
> > > > > > An alternative approach would be to split the callback into two
> > > > > > versions, one with the int return value, and the other with void
> > > > > > return value like in older kernels. But that's a lot more churn for
> > > > > > fairly little gain I think.
> > > > > >
> > > > > > Summary from the m-l discussion on why we want something at warning
> > > > > > level: This allows automated tooling in CI to catch bugs without
> > > > > > humans having to look at everything. If we just upgrade the existing
> > > > > > pr_info to a pr_warn, then we'll have false positives. And as-is, no
> > > > > > one will ever spot the problem since it's lost in the massive amounts
> > > > > > of overall dmesg noise.
> > > > > >
> > > > > > v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
> > > > > > the problematic case (Michal Hocko).
> > >
> > > I disagree with this v2 note, the WARN_ON/WARN will trigger checkers
> > > like syzkaller to report a bug, while a random pr_warn probably will
> > > not.
> > >
> > > I do agree the backtrace is not useful here, but we don't have a
> > > warn-no-backtrace version..
> > >
> > > IMHO, kernel/driver bugs should always be reported by WARN &
> > > friends. We never expect to see the print, so why do we care how big
> > > it is?
> > >
> > > Also note that WARN integrates an unlikely() into it so the codegen is
> > > automatically a bit more optimal that the if & pr_warn combination.
> >
> > Where do you make a difference between a WARN without backtrace and a
> > pr_warn? They're both dumped at the same log-level ...
>
> WARN panics the kernel when you set
>
> /proc/sys/kernel/panic_on_warn
>
> So auto testing tools can set that and get a clean detection that the
> kernel has failed the test in some way.
>
> Otherwise you are left with frail/ugly grepping of dmesg.

Hm right.

Anyway, I'm happy to repaint the bikeshed in any color that's desired,
if that helps with landing it. WARN_WITHOUT_BACKTRACE might take a bit
longer (need to find a bit of time, plus it'll definitely attract more
comments).

Michal?
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

