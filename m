Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EABA5C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 07:20:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75FD62147C
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 07:20:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="RqdT+3F7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75FD62147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8E048E007E; Fri,  8 Feb 2019 02:20:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3DC08E0002; Fri,  8 Feb 2019 02:20:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2C268E007E; Fri,  8 Feb 2019 02:20:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92DE28E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 02:20:52 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id d5so2175718otl.21
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 23:20:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EalRzoWbflT2aUthpO0bEhvXjIl1xZCE1RoISoW/U9Y=;
        b=hAEvqh7xkknp1Vbgacp8uRBMM0+Wm1DWbtEyIVc1gqwLiNS7IBUVUMDOC28D2DH7l+
         JZbWIIOC9ub7/TU5/mOaco7ICJZ6RDDBp1o6WH+VHmIHRfgvZskQ0w0sXKUKgpd7BDi8
         ZYwT/V7XZg7ylQp5Uxq+M+1Itmb/heDwtMKTZMvNsBJ7IpWrTylC0/YCBgmVB9vC2NT4
         ggcJP986N1EI6DMsSFg5hIP/b5KG76GOZ6Y8ZMwknf/6cWI15y9DAY2rLys7W7eSokYn
         ADQZuSIC+fs6ORzW4uhyoSPj0cqKTJlGJZAy7hchC1omrJ8dBf8iPE5a9suhxnYcFZld
         +HPw==
X-Gm-Message-State: AHQUAuY8EWxB0h6PkTFy27FFc3zAvW71asZYu5nyMgcpSWY9TVkHt/Y5
	FpdRxdoKM6JI5l8ba7jL8ct5qbSMqC+BFsPXlExwi8uWfTqpqfiFD+aa0bKRwi7SFBcVEFxKgxg
	8165syD8C/NoN+rrx9Wgm6HGGwfhYpqBEyhbuWqDh/aQ4VgcC2v80tyHzB6/vG/5T2Pj73xmQE8
	6hJHDgztqoP7LZPJIsys19LYpivbesNSGtPoVbYej7dVketjRx7M5f0DTBcDmZDCKBUQU5bEn/4
	ckD3/PM4ELQzIqmN7ona9Okh2flEVxOndGpN9sfAizzHNaIceaXH2SgfNHgsZH06DuAZp8fGvv2
	9gE09O2VQZc4E5qL5HLPbMr3Qtj48Fk4zrMJ6o/JwjRQloQCQDxizb/Ue8fboBqXuK9b+J2pXA9
	W
X-Received: by 2002:a9d:5d0e:: with SMTP id b14mr7661086oti.263.1549610452167;
        Thu, 07 Feb 2019 23:20:52 -0800 (PST)
X-Received: by 2002:a9d:5d0e:: with SMTP id b14mr7661033oti.263.1549610451257;
        Thu, 07 Feb 2019 23:20:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549610451; cv=none;
        d=google.com; s=arc-20160816;
        b=YnptTVOJNqzlNFqsQcEIn3ukgSOetcaWVWD2qjn6SXtnX+RNwL6B7wOdYGtRSPPmWf
         tbDz/A/46AyvPOqn7DZWT/KXCqPtMQYy/RqYS2hDOqe2susM7RawcWuPFNd79xI2Ifoo
         oyh7aPcYW1MEKHFFATrgo9/4D4yBGPz8mwNUAJXYrYOWAkpnBPK1VwulYkA4bIsrARKe
         kbYAN54aPWyybfUnIwjHd6BADV+KZ9wzpHy5bPrEQ5euEoI7/Ckp/+y1NaHukibDDTCO
         yFc2CJTfZEgPthvMUdpDtTKiY+rgGrRonrbhjy2AdBqy8vxfGzQjzFRR4hhxcAJFBYYj
         HmTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EalRzoWbflT2aUthpO0bEhvXjIl1xZCE1RoISoW/U9Y=;
        b=EZrA5WSPsjskdePA1gj4Q7AxWaRrivSSTjASl3D6jg5XyPTDvmG/nbj8r4ebLeiXF2
         syPCKBeAX34K0+CkZKUsltSpsfKaoXnh9jcMNb0/Oxvru++Si8J8NjpzQKrhbcO7PSr2
         Hzph77ifqXaAE2vV9kKTYErh/PSFQmsZ4tiUC2M+mIyZydM8Xqo1U8A7GqfUgRTzse70
         F1Tdk3kjtW/X2L05SQBQhNMXJfTm480MJAIeVxUQyBZQuM73wdvC7/Ffpr0RT96fDX6n
         lJJ0+7JLYnVwZC8MPl7il3woqvf2KbdiOSurNmJOYuXAmAQs+GFxQ0o9IeB7fS+SRYqO
         R5kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=RqdT+3F7;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor671755otn.150.2019.02.07.23.20.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 23:20:50 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=RqdT+3F7;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EalRzoWbflT2aUthpO0bEhvXjIl1xZCE1RoISoW/U9Y=;
        b=RqdT+3F72R/XTbxkQVYqEPxLju2bMe5GObiCn7fONaAWZovYmEhemig/3V41W8s0bq
         avOpQIP2tDET1eQ8G5YrUaSYErm7Ut26GfFEgnMQFAAienKbiP1eBbnAVPQYEF9MLsEZ
         /f8WjcEg/F/fpfBJUPjzgrELyxY7Z92C7fF3JOsOOuQPIS2qltuHKPCHUprp8mbL96Ze
         Hsz+FK+QgdMfpoF7ufDl4hUiHaOaUyiN7VR8zWb7nf17YP5MurLGfMBOlmg7vqcnOwAt
         IiqitN7VTf8qNrSIwQZeLCnR4PqcktvSj+pUKWoVS51xR9HHF/KboRwvQr9uJQ9Um2fW
         bHxw==
X-Google-Smtp-Source: AHgI3IZXcUnnQaJW7YsANVhPGTSt2w31gaQbk9tULfIlXaNf0UZe4rmwULn4ckSvOVDerW//0ny6kxOaPLKqk45/OSM=
X-Received: by 2002:a9d:7d18:: with SMTP id v24mr3691452otn.352.1549610450102;
 Thu, 07 Feb 2019 23:20:50 -0800 (PST)
MIME-Version: 1.0
References: <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard> <20190207052310.GA22726@ziepe.ca>
 <CAPcyv4jd4gxvt3faYYRbv5gkc6NGOKjY_Z-P0Ph=ss=gWZw7sA@mail.gmail.com>
 <20190207171736.GD22726@ziepe.ca> <CAPcyv4hsHeCGjcJNEmMg_6FYEsQ_8Z=bvx+WmO1v_LmoXbJrxA@mail.gmail.com>
 <20190208051950.GA4283@ziepe.ca>
In-Reply-To: <20190208051950.GA4283@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 7 Feb 2019 23:20:37 -0800
Message-ID: <CAPcyv4jWnkHxBcU2_Pz99wM02RYab4y25hu_qUE8KCVArYxCeg@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dave Chinner <david@fromorbit.com>, Doug Ledford <dledford@redhat.com>, 
	Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
	linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 7, 2019 at 9:19 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Thu, Feb 07, 2019 at 03:54:58PM -0800, Dan Williams wrote:
>
> > > The only production worthy way is to have the FS be a partner in
> > > making this work without requiring revoke, so the critical RDMA
> > > traffic can operate safely.
> >
> > ...belies a path forward. Just swap out "FS be a partner" with "system
> > administrator be a partner". In other words, If the RDMA stack can't
> > tolerate an MR being disabled then the administrator needs to actively
> > disable the paths that would trigger it. Turn off reflink, don't
> > truncate, avoid any future FS feature that might generate unwanted
> > lease breaks.
>
> This is what I suggested already, except with explicit kernel aid, not
> left as some gordian riddle for the administrator to unravel.

It's a riddle either way. "Why is my truncate failing?"

The lease path allows the riddle to be solved in a way that moves the
ecosystem forwards. It provides a mechanism to notify (effectively mmu
notifers plumbed to userspace), an opportunity for capable RDMA apps /
drivers to do better than SIGKILL, and a path for filesystems to
continue to innovate and not make users choose filesystems just on the
chance they might need to do RDMA.

> You already said it is too hard for expert FS developers to maintain a
> mode switch

I do disagree with a truncate behavior switch, but reflink already has
a mkfs switch so it's obviously possible for any future feature that
might run afoul of the RDMA restrictions to have fs-feature control.

> , it seems like a really big stretch to think application
> and systems architects will have any hope to do better.

Certainly they can, it's just a matter of documenting options. It can
be made easier if we can get commonly named options across filesystems
to disable lease dependent functionality.

> It makes much more sense for the admin to flip some kind of bit and
> the FS guarentees the safety that you are asking the admin to create.

Flipping the bit changes the ABI contract in backwards incompatible
ways. I'm saying go the other way, audit the configuration for legacy
RDMA safety.

> > We would need to make sure that lease notifications include the
> > information to identify the lease breaker to debug escapes that
> > might happen, but it is a solution that can be qualified to not
> > lease break.
>
> I think building a complicated lease framework and then telling
> everyone in user space to design around it so it never gets used would
> be very hard to explain and justify.

There is no requirement to design around it. If an RDMA-implementation
doesn't use it the longterm-GUPs are already blocked. If the
implementation does use it, but fails to service lease breaks it gets
SIGKILL with information of what lead to the SIGKILL so the
configuration can be fixed. Implementations that want to do better
have an opportunity to be a partner to the filesytem and repair the
MR.

> Never mind the security implications if some seemingly harmless future
> filesystem change causes unexpected lease revokes across something
> like a tenant boundary.

Fileystems innovate quickly, but not that quickly. Ongoing
communication between FS and RDMA developers is not insurmountable.

> > In any event, this lets end users pick their filesystem
> > (modulo RDMA incompatible features), provides an enumeration of
> > lease break sources in the kernel, and opens up FS-DAX to a wider
> > array of RDMA adapters. In general this is what Linux has
> > historically done, give end users technology freedom.
>
> I think this is not the Linux model. The kernel should not allow
> unpriv user space to do an operation that could be unsafe.

There's permission to block unprivileged writes/truncates to a file,
otherwise I'm missing what hole is being opened? That said, the horse
already left the barn. Linux has already shipped in the page-cache
case "punch hole in the middle of a MR succeeds and leaves the state
of the file relative to ongoing RDMA inconsistent". Now that we know
about the bug the question is how do we do better than the current
status quo of taking all of the functionality away.

> I continue to think this is is the best idea that has come up - but
> only if the filesystem is involved and expressly tells the kernel
> layers that this combination of DAX & filesystem is safe.

I think we're getting into "need to discuss at LSF/MM territory",
because the concept of "DAX safety", or even DAX as an explicit FS
capability has been a point of contention since day one. We're trying
change DAX to be defined by mmap API flags like MAP_SYNC and maybe
MAP_DIRECT in the future.

For example, if the MR was not established to a MAP_SYNC vma then the
kernel should be free to indirect the RDMA through the page-cache like
the typical non-DAX case. DAX as a global setting is too coarse.

