Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 498FFC169C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 00:22:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E10CD2075D
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 00:22:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="k8tnarCT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E10CD2075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 607A88E0009; Wed,  6 Feb 2019 19:22:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B70A8E0002; Wed,  6 Feb 2019 19:22:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CC898E0009; Wed,  6 Feb 2019 19:22:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 26CEA8E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 19:22:30 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id z22so7671757oto.11
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 16:22:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=N9lRRqnsHDT7GDO+v7XW7/VJ5v3X9tiPM2p9vi+qGY8=;
        b=lmGmfAo3CsWd/3ZPTu4pEXyY86TJNrD0c2a3RqYqlfCuyx0admTnE1JwEQyDWlS4Xg
         fuEmjONP7jN08iwDfK87pfxpm25/Ms5kx1askj7c4nPCj+75dBALcH7kppN+SefhbADu
         UMEPitkpsLJwtevL6jXQqwG7QtwTwraTpI5gKV1hBIVsZ1cEXz/clR22cMSDv9KUkm5U
         fvAw2rSed1xfOEZjYj2Q+QnNrM53maRcEoMyB6rl3pv7aAKsDAa4y13UzjZ2foYb+4Z1
         FiZ2kyn3s4o0VxPWrqYpu6X2jTdkoE2pzAv2JMDLrgC9CpukBTvYIOGBvP6PYq15OWk9
         QyxA==
X-Gm-Message-State: AHQUAuahIawcZbZgX0fnGLYzi3sXYv6rND18OCMtxdILfCLzOiKuE7dL
	rlqGumVqjXCFFayCAXfBiuitVSB63FVk22dj769VMJFACGtkwMSA8NlUPfzjIGYjQGMFOZrz8e/
	pGUhYor/9j4P5oEilX6mlWimQwlZGaF3EUBia+IhdJaHr+kU73GWh0gCxHeP35F42bINQOrVd+7
	2GZU5c+ULCVfAbTCIqulMK+bIyyc5OclOlSx7d5dsnH6FnJt5dKGJ9aGlEOu+Es1OG6k5IQqYbH
	gLhuNYoaSr7mEi7cvcna+qdxiJ36dZki2UUnC194ZKxuJsZ0T9d5/+pwhfdJ00f9Y8Mgpoziyyk
	Z8s2FeMrqy69QsZEvOwIebzjBbHga/Mbu8dzIR9dCp0ZYUzbjnyWYAQ5C1Qr9Vg/76lnhxBmYUo
	4
X-Received: by 2002:a9d:734e:: with SMTP id l14mr6852620otk.270.1549498949848;
        Wed, 06 Feb 2019 16:22:29 -0800 (PST)
X-Received: by 2002:a9d:734e:: with SMTP id l14mr6852594otk.270.1549498948968;
        Wed, 06 Feb 2019 16:22:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549498948; cv=none;
        d=google.com; s=arc-20160816;
        b=1KbonH0EOseb49ZH0X8MJzC+iv0M21v0p2csRqpzKhjPsxeUwg2ATIz0iwOsVwzKG0
         8OKKE96392iRPKhs+RoPtYHTcNxTBNVh07KYHszG+vFUihqTQ+hANdcdK123UW0W3Y8h
         312NQx/J9p6g47DiNAcIaLRDYaRd0qF57Mvo9TX+NJbv6+yVcyPJX1UEl/N9DTNWesw2
         lj69yfuBtNFh/FDF7+dd6kOvSvZcz3+Jpz0VcWae9/VbwZ7NLYSPS1SNAytZlYp93BJ/
         QfcuO7L/LqBddM/BYMkAA4VgMuqneX9p+Z1t6DzvmVwIb8C699A2ceGGJsHrC5ium0x8
         rlPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=N9lRRqnsHDT7GDO+v7XW7/VJ5v3X9tiPM2p9vi+qGY8=;
        b=gpqdd37IEB4pgYDlF6JS8Yl6k1vwXWrA2SH2QoOnw7YnUveavGtn1QbEd3hFl73Ilr
         /KZnNImnY27ESTQQzmIUJELsoGFioVndwmLibG61G4jMZQm2kPD68EdPntSUPPHdN8i0
         PO+v9sAAeBE8BruZKItAoxn7KJneqrKfvDfv7jrAvYslvf0qjTv+3tq4ajT4WlNB8Y/p
         P9I+q3YhOFM0S+PGPjx6/7fJF4Dso+tjW5QHk9rVPeIc4o6I/32CK4BAJ9S0V0NveAyt
         ZKCiJD9sW1H8E9+vX0jlk/F/aY/n59CwHPE2vY3mpEvQI144Sa9k69fW487dBFtzlkkA
         oe9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=k8tnarCT;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y9sor12528377oig.53.2019.02.06.16.22.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 16:22:28 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=k8tnarCT;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=N9lRRqnsHDT7GDO+v7XW7/VJ5v3X9tiPM2p9vi+qGY8=;
        b=k8tnarCT7do6m4YClkIf2+OB/cSXl05ZHqWyDLOAoSSB9nAV6GR7IOivzKXDJizJie
         p+38ESxiMKxx8gLcOsFJUqbLhF88jqW94mz6D55BGtR9Uj7xdHLNf1XxqvgLkYl/9M8A
         TPIzwWGe56Pi0cx6OdmhIAzJqLRWF/6icRk+DuBoGPG5UjFlitPyQYJbSL3g0aZYoSoO
         vOgQrVay97ebCs4OHx3tcX1mxEaaYMljmc2PyA3njJmuo6TP1JJH7qsXkEaa487WK+qP
         rEwesohUJbI4NidP95LSmAQ0iNbB5lrGzrY5kEqLLhWOb7KpJBtjqL6aFn2O36hh2qUR
         WQ2Q==
X-Google-Smtp-Source: AHgI3Ibqjhw/vsUKHyjILXNjBnifndhwYQTmHR5DdOu3tq7tqHjwpj5Yu5rjPWEExLu7zymchHLui7jCBzPdS3wEE4s=
X-Received: by 2002:a05:6808:344:: with SMTP id j4mr1089747oie.149.1549498948442;
 Wed, 06 Feb 2019 16:22:28 -0800 (PST)
MIME-Version: 1.0
References: <20190206173114.GB12227@ziepe.ca> <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <20190206232130.GK12227@ziepe.ca> <CAPcyv4g2r=L3jfSDoRPt4VG7D_2CxCgv3s+JLu4FQRUSRWg+4Q@mail.gmail.com>
 <20190206234132.GB15234@ziepe.ca>
In-Reply-To: <20190206234132.GB15234@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 6 Feb 2019 16:22:16 -0800
Message-ID: <CAPcyv4h1=GTAqHBw+Zsp9eNYR3HFbB_qjmhntwnO-jyGun4QNA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Doug Ledford <dledford@redhat.com>, Dave Chinner <david@fromorbit.com>, 
	Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
	linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 6, 2019 at 3:41 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
[..]
> > You're describing the current situation, i.e. Linux already implements
> > this, it's called Device-DAX and some users of RDMA find it
> > insufficient. The choices are to continue to tell them "no", or say
> > "yes, but you need to submit to lease coordination".
>
> Device-DAX is not what I'm imagining when I say XFS--.
>
> I mean more like XFS with all features that require rellocation of
> blocks disabled.
>
> Forbidding hold punch, reflink, cow, etc, doesn't devolve back to
> device-dax.

True, not all the way, but the distinction loses significance as you
lose fs features.

Filesystems mark DAX functionality experimental [1] precisely because
it forbids otherwise typical operations that work in the nominal page
cache case. An approach that says "lets cement the list of things a
filesystem or a core-memory-mangement facility can't do because RDMA
finds it awkward" is bad precedent. It's bad precedent because it
abdicates core kernel functionality to userspace and weakens the api
contract in surprising ways.

EBUSY is a horrible status code especially if an administrator is
presented with an emergency situation that a filesystem needs to free
up storage capacity and get established memory registrations out of
the way. The motivation for the current status quo of failing memory
registration for DAX mappings is to help ensure the system does not
get into this situation where forward progress cannot be guaranteed.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2019-February/019884.html

