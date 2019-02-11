Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E857AC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:59:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A79262080D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:59:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="v2SmmsxY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A79262080D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C5808E014F; Mon, 11 Feb 2019 14:59:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49AF88E0125; Mon, 11 Feb 2019 14:59:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B0888E014F; Mon, 11 Feb 2019 14:59:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 111568E0125
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:59:00 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id r13so147054otn.10
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:59:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=aiCrOaqvqc6IXkmSpeBibC6k7Dt5ORUBY+Yth87tg8g=;
        b=FU9IsJkQnhW78GKW29FkJuU6dgP8FpCtwfnn6Wz8omEVeOeYNtHzN9dIjPtbCLr+Tl
         /wRTMb9lwqATbkB53mX0ndtqomMnOgmaWRMw5fPOufaxA01eT0iFQJs6SlxpEjnpogwj
         VIW8kV7Z4AQwawM00LqwSZbZUw91oJH26N7U1NwVgkgtEpxldJev5enTdmjgEsPnBM2x
         JCLnqWQYNFs9tXtn/BFvftA2nYXRQdASYUgoUS1+ZbVoEcyFA4mQ2D/LWcvLt8GgzSdy
         pe8bG8ofHrYDxBXPz4aQq+s6b6opuyhGpAMsKkth2W3LV9PsX1CnOUkJnSTfu7r12nyx
         f2qQ==
X-Gm-Message-State: AHQUAub+tApt788bNfrK9apLAY51NjTzNPPlDDJPIxpGTwe3DEdWVel0
	5db3riPPY3Tu5JmgiX5p3dtPM9BYb9JDqSZTGAOmwM7oSZbbJaSmT49NtnlNOmbLHb9gBwIzUhP
	XjkeYAAy6LrK9m0eIBHRvfKQZa2VscuKU9UneZQ1x/bjI+It0w4b/m5p6GJgWvDwC8lTTbLkgBp
	KvN/1cvsbqNZX3B0I3PHWyqHkcN9yk6LObUcWw8Bk0ViZ/ELMj2nEbGifmZ9JElo7Usae90z9Rg
	EQzFuvrGsO9AnTUbbYTX6PuNy8S/7MEjlTRCCwItPAPbRTNOHkqvoZR00O7gh3HwwiNz0z/MNnF
	ZC7slwHv9eJe0RNi4Djco6LPMC50lFf5alb3L39SpN1EqVxAv6opMTdqVJIkfV6iNNRgWW91DC0
	W
X-Received: by 2002:a9d:6205:: with SMTP id g5mr14377283otj.277.1549915139793;
        Mon, 11 Feb 2019 11:58:59 -0800 (PST)
X-Received: by 2002:a9d:6205:: with SMTP id g5mr14377213otj.277.1549915138673;
        Mon, 11 Feb 2019 11:58:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549915138; cv=none;
        d=google.com; s=arc-20160816;
        b=Y9B9/y7SvlMjeQuMrS4iPrMiJQByyA6hQWthYrLfXkf0KbaQ3zQv7Ih/4dD3ChweSi
         SgH+d9DfQQnUzpTMuH/BDtNAek2VJgnhALhJBhNfDykj9b9+6740lKXyZS0Nn5/jEAg2
         rViRYc7y3clVrZrIeO9C46Fsnv0endQGG1zpRJFmKbb2WMApH3oMoUZ5PcAi/ZJ/2/HL
         KqWHA6EpJUt/ylZvrsQOFVMAc6EijiXRR9tNQ1fybQDMUAoBVg9QaVpwU9bQVj2fvMxw
         YzhFaTxQsKOFJd5zEiJO8pg9dDSbBpsnkStmFHYZhd4SonPPawnaJ6qvMk4I92uEUXtw
         LtKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=aiCrOaqvqc6IXkmSpeBibC6k7Dt5ORUBY+Yth87tg8g=;
        b=cun5U/NI3LYWStcS50nORQRVl3go0zASbMnGnH0HcNssTs2s5qeA483t7CnTXi75AW
         l+gFGwSIrHIVCQS2eFKqzU0aKMFoCOyMf48o8vepB6VSvPEMgRWL6A9AuzkOgfJeGTcc
         /zAoB6z0PeTGCMiWVhANuXP65bQ02X41B75MA6nww8ua6YVGZTINl6utbyJEheMZhmPI
         wTAwJnRmw3GiLAKCGwsk6B+JbcwwM+5MXjYkrgLzM0+iom5/ILumjd+gPa3KYcoh/9jN
         JUhmTi1ZMzO65cCgbntSmvu8GaVKmN3O0AHBRDlS4w4b6kFxCAbvbaSZqa07I02oRmu5
         DDdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=v2SmmsxY;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r20sor7457170otq.0.2019.02.11.11.58.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 11:58:58 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=v2SmmsxY;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=aiCrOaqvqc6IXkmSpeBibC6k7Dt5ORUBY+Yth87tg8g=;
        b=v2SmmsxYbVz7eajzqaw1KE0S7eRG0vZw4fSOQMdWssxdYjWlIBUN/cdSMhrRO2Oitk
         ce0cr7TXBTH440tREOOROwN6aGzf0N0dK4YcxZbUDZxm8RsViTMLBKq5smoz1WnY93NS
         oQR4kw6bT14+qy26LgFr1aO0SNt82fha5GlY5Qi3ogUWx/2pP48/typtmKY+rDAX8Lv1
         F+/dJB7h3xKZs31nObrffQ/AvUKRhukK8lsADOxWW1EmvCCpE1S283Z4enFVd2DVpUEb
         Ma0S29ugwJQDvFOs3J8JSPV9d4SwIbvkitbF1yEKwKQi+RsWEbn7PTdayZRFQFB5jyqt
         Sa0g==
X-Google-Smtp-Source: AHgI3IZz5K9TqTpU5mfrAWqX17LGBxJt/PQR8+mBd04rCm+lHgw/p2iUDBeXhmYO4CyNzWTMaYVOQ2s59VGZwx2eYiI=
X-Received: by 2002:a9d:7493:: with SMTP id t19mr16664268otk.98.1549915138337;
 Mon, 11 Feb 2019 11:58:58 -0800 (PST)
MIME-Version: 1.0
References: <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz> <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca> <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <20190211182649.GD24692@ziepe.ca> <20190211184040.GF12668@bombadil.infradead.org>
In-Reply-To: <20190211184040.GF12668@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Feb 2019 11:58:47 -0800
Message-ID: <CAPcyv4j71WZiXWjMPtDJidAqQiBcHUbcX=+aw11eEQ5C6sA8hQ@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Matthew Wilcox <willy@infradead.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, 
	Dave Chinner <david@fromorbit.com>, Christopher Lameter <cl@linux.com>, Doug Ledford <dledford@redhat.com>, 
	lsf-pc@lists.linux-foundation.org, linux-rdma <linux-rdma@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 10:40 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Mon, Feb 11, 2019 at 11:26:49AM -0700, Jason Gunthorpe wrote:
> > On Mon, Feb 11, 2019 at 10:19:22AM -0800, Ira Weiny wrote:
> > > What if user space then writes to the end of the file with a regular write?
> > > Does that write end up at the point they truncated to or off the end of the
> > > mmaped area (old length)?
> >
> > IIRC it depends how the user does the write..
> >
> > pwrite() with a given offset will write to that offset, re-extending
> > the file if needed
> >
> > A file opened with O_APPEND and a write done with write() should
> > append to the new end
> >
> > A normal file with a normal write should write to the FD's current
> > seek pointer.
> >
> > I'm not sure what happens if you write via mmap/msync.
> >
> > RDMA is similar to pwrite() and mmap.
>
> A pertinent point that you didn't mention is that ftruncate() does not change
> the file offset.  So there's no user-visible change in behaviour.

...but there is. The blocks you thought you freed, especially if the
system was under -ENOSPC pressure, won't actually be free after the
successful ftruncate().

