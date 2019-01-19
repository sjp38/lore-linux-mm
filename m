Return-Path: <SRS0=Ztt1=P3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13259C61CE4
	for <linux-mm@archiver.kernel.org>; Sat, 19 Jan 2019 16:56:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 960592087E
	for <linux-mm@archiver.kernel.org>; Sat, 19 Jan 2019 16:56:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="VMAuENoz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 960592087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0D8A8E0003; Sat, 19 Jan 2019 11:56:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBD9A8E0002; Sat, 19 Jan 2019 11:56:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAE738E0003; Sat, 19 Jan 2019 11:56:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF2078E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 11:56:16 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id 73so6667904oii.12
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 08:56:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nSqLnpETBLGsJ2UvGu+7zWAcLpmYNR5gRP5L1Qg9cEA=;
        b=uRRkbM2V1PgC0RCLcBbFNqWNvrxpXvyVsw4aM8nPZQ5mT7RM4CGnD9FcD80ZFVKohU
         EZozyDqddN/cAAZGuhm+0u9m2YlBbrJjJgtqXCXcQ8D5TJHOMzm/5IFYVAPrOnefFgdI
         r9AeEDZX4gVnUFvna6ftu7E6+WGqsgTR4K+t9ORPzw542h4kKHNs6abc/Zhgxd1J9KRJ
         j9WicUpmpQqIEh4KF/6rpoMKeLTlYkcAHI1cquzx2DUqE6u7sVYikM/DpPwV5GV82aof
         h8N6iSw3LJK6SCZvMya9NdZXa4n0Xq3tC/J2FSPTKg25VPgQzUf15g4Gq2akScVMH50M
         SghQ==
X-Gm-Message-State: AJcUukdd5TAdKL7umqKKpuiPVssmVUvX2Zmzy4EBK8siFnLkABc8pH1/
	9tRLqgraX52ZAw24i5sLq4rQzr9K3cAsrir+qgrqLRH/FmC8VwRjcvQtOqB3zcaxkUiFuBbyXS3
	dEMdPDj7OVG7tQ7+RFdDPBfIzScHSheZjrOFyZYc6nYC8+6uJxdTZUi94qvtLMpn6QTRHb8OgLq
	Fbb0UFgOjq6G6az/TWg+irPFJQepjr1rjRQbkmH2Jk5YQlGfJd1D57S7PsTTb977SldaZ31jSrN
	VLT0TfyRjjF3b8++UUb4TJtjmguZ5rNqQnWy7gaYgTnxWmOFRPdkItVM0qWoztVRdO+dLGuk1hn
	Q/gugr7itbp+G0V6q1bw5/BT18dZ1ytpKIRsUwcG8VAeeAniJ7hTelA9iSMh/zaGfO2CNXoznJk
	z
X-Received: by 2002:aca:be41:: with SMTP id o62mr1286328oif.206.1547916976315;
        Sat, 19 Jan 2019 08:56:16 -0800 (PST)
X-Received: by 2002:aca:be41:: with SMTP id o62mr1286297oif.206.1547916975282;
        Sat, 19 Jan 2019 08:56:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547916975; cv=none;
        d=google.com; s=arc-20160816;
        b=L8ULDdvKyfWozbrmFBZ5HmIbNlwSk84VjmW9hRPpuCAPvLjqOdRHcwrsVjayX3BrSi
         SsYOp1hEOSjEWKiDVnml4S2Maa5OxzX2lDTJSY4Wjn8AIF2H6EMK3ATXP4CkXpUzi+ot
         2cg/D43hfoFp5uJ3MlpfBApAuq63YjcHxf9oKMeSWZzB4Q3kYEh6kS8GdyL4xZHOkFCb
         MJU0/k36NJ2ZlGoekxbiL8+Ei9JkFQ/10sgSb6b5qE49BmmF0g9qlY/HD8t9tcyxqnRj
         EeTEV76ehRXY15SjJ3UaLWf+ZPtXQqi6nd/5mOKb7Pxz+64ipQ06QtDIBX1faW6mO21Z
         LR3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nSqLnpETBLGsJ2UvGu+7zWAcLpmYNR5gRP5L1Qg9cEA=;
        b=tq30eNYF8HqjXxfkXvAnlDhW8xrhb2h1AKRsqPNUysLPHPHy7W0MLGrjJrvQ4BClm3
         /17Ub3p6D71nov17lZOI06GvYjOi+unZjiG0ZP0Ygc45xcYBRSS6Lx9cagRWApNe8buC
         72ibfdpJIGTv9gFXSfymbCQhzZ7BsGvxPPAXUikdm36IsXVpG579NrnQ4cBTi9lIVhuH
         6j25UZqWmzJubRg1Fq20+AFaNbq69svrd4fglGC1CyY6WFlltC0p/AjJFAj6hEtMaDIs
         0x/GAh3RlsOyBtqULYhl3t75eq8qfLzcIYDTonlBFGV4nAO/OxEx8wNSk25PmaGkI5Ql
         XQug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=VMAuENoz;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7sor4922496otq.70.2019.01.19.08.56.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 Jan 2019 08:56:14 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=VMAuENoz;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nSqLnpETBLGsJ2UvGu+7zWAcLpmYNR5gRP5L1Qg9cEA=;
        b=VMAuENozNQB0jiQ3Z8uHfWBcQ2wRKuBQcOhGjMNT6J7bMCdaJOJbDTwCqPDOoVrPuG
         rtoPNOFXQQDwIxXWK+kJsMBc7UFMNkLYYvkAzs+Ylw2eK8g09q/cJn2NCvj6SEv1wY3P
         Gzwd4Zc0uaE+5IzfOJ/eDF39S4kSN3dwdlguJJkpSBhHfB30PYvoSYvEqHXMB67Kg/xc
         wdiAfOhP4bwo1U+I30o0q8I3KZf8o6LNWSrJUB4rEEGCjTI+a4xdn24oPeZ9Ly6k2Mu7
         JnKCTfTUkLiVjfXupXdu6Fh2qbk7QsrycL1C4un+Q9W78xIpt5rD00j/Somgi5HtvTqh
         rNwA==
X-Google-Smtp-Source: ALg8bN5FNXNsu5fcBlk9edmXb8qlxYVHuZJL0prgv+a2N4OMV/QK3cX1rQFzLaefYgHREEVqOSOoFj1HD7xSlRHLT40=
X-Received: by 2002:a9d:3a0a:: with SMTP id j10mr14458057otc.229.1547916974345;
 Sat, 19 Jan 2019 08:56:14 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-6-keith.busch@intel.com>
 <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
 <CAPcyv4gH0_e_NFJNOFH4XXarSs7+TOj4nT0r-D33ZGNCfqBdxg@mail.gmail.com> <20190119090129.GC10836@kroah.com>
In-Reply-To: <20190119090129.GC10836@kroah.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 19 Jan 2019 08:56:02 -0800
Message-ID:
 <CAPcyv4jijnkW6E=0gpT3-qy5uOgTV-D7AN+CAu7mmdrRKGHvFg@mail.gmail.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Keith Busch <keith.busch@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190119165602.q_dIoToe2Gs5Kb_qe5QqkXqkLdwcViRlZrz-aBN9gdI@z>

On Sat, Jan 19, 2019 at 1:01 AM Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
>
> On Fri, Jan 18, 2019 at 01:08:02PM -0800, Dan Williams wrote:
> > On Thu, Jan 17, 2019 at 3:41 AM Rafael J. Wysocki <rafael@kernel.org> wrote:
> > >
> > > On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
> > > >
> > > > Add entries for memory initiator and target node class attributes.
> > > >
> > > > Signed-off-by: Keith Busch <keith.busch@intel.com>
> > >
> > > I would recommend combining this with the previous patch, as the way
> > > it is now I need to look at two patches at the time. :-)
> > >
> > > > ---
> > > >  Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
> > > >  1 file changed, 24 insertions(+), 1 deletion(-)
> > > >
> > > > diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> > > > index 3e90e1f3bf0a..a9c47b4b0eee 100644
> > > > --- a/Documentation/ABI/stable/sysfs-devices-node
> > > > +++ b/Documentation/ABI/stable/sysfs-devices-node
> > > > @@ -90,4 +90,27 @@ Date:                December 2009
> > > >  Contact:       Lee Schermerhorn <lee.schermerhorn@hp.com>
> > > >  Description:
> > > >                 The node's huge page size control/query attributes.
> > > > -               See Documentation/admin-guide/mm/hugetlbpage.rst
> > > > \ No newline at end of file
> > > > +               See Documentation/admin-guide/mm/hugetlbpage.rst
> > > > +
> > > > +What:          /sys/devices/system/node/nodeX/classY/
> > > > +Date:          December 2018
> > > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > > +Description:
> > > > +               The node's relationship to other nodes for access class "Y".
> > > > +
> > > > +What:          /sys/devices/system/node/nodeX/classY/initiator_nodelist
> > > > +Date:          December 2018
> > > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > > +Description:
> > > > +               The node list of memory initiators that have class "Y" access
> > > > +               to this node's memory. CPUs and other memory initiators in
> > > > +               nodes not in the list accessing this node's memory may have
> > > > +               different performance.
> > >
> > > This does not follow the general "one value per file" rule of sysfs (I
> > > know that there are other sysfs files with more than one value in
> > > them, but it is better to follow this rule as long as that makes
> > > sense).
> > >
> > > > +
> > > > +What:          /sys/devices/system/node/nodeX/classY/target_nodelist
> > > > +Date:          December 2018
> > > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > > +Description:
> > > > +               The node list of memory targets that this initiator node has
> > > > +               class "Y" access. Memory accesses from this node to nodes not
> > > > +               in this list may have differet performance.
> > > > --
> > >
> > > Same here.
> > >
> > > And if you follow the recommendation given in the previous message
> > > (add "initiators" and "targets" subdirs under "classX"), you won't
> > > even need the two files above.
> >
> > This recommendation is in conflict with Greg's feedback about kobject
> > usage. If these are just "vanity" subdirs I think it's better to have
> > a multi-value sysfs file. This "list" style is already commonplace for
> > the /sys/devices/system hierarchy.
>
> If you do a subdirectory "correctly" (i.e. a name for an attribute
> group), that's fine.  Just do not ever create a kobject just for a
> subdir, that will mess up userspace.
>
> And I hate the "multi-value" sysfs files, where at all possible, please
> do not copy past bad mistakes there.  If you can make them individual
> files, please do that, it makes it easier to maintain and code the
> kernel for.

I agree in general about multi-value sysfs, but in this case we're
talking about a mask. Masks are a single value. That said I can get on
board with calling what 'cpulist' does a design mistake (human
readable mask), but otherwise switching to one file per item in the
mask is a mess for userspace to consume.

