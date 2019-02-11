Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E9D0C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:02:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ACF921B68
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:02:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="hUIoym1j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ACF921B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E32378E0161; Mon, 11 Feb 2019 16:02:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB9EF8E0155; Mon, 11 Feb 2019 16:02:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C83048E0161; Mon, 11 Feb 2019 16:02:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 999E98E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:02:50 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id 4so366747otg.3
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:02:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ue3vXSU/Uyn4dHhRrNll0Xk0Xsd0Oc1wTjLcVxg/RVU=;
        b=IlSos3LCL3Dn+P/HGwn+IgSkU6RRKBOi2dY4pcTVm8E9IM/zCbc4cVqswzmkoosN/K
         U1vM5pGSHDKcrsYT43oNz0ha+c24fjpHcLCTGHIMw2eMUBIJvqQ5K7LgshsROjK680b7
         l3AkxLLTKLHH92tMkuNA6N9oUzJMPMTxjLErwmG1tdgQdqsdBWWS7nat7AH3Sz8QnVpS
         kjrWFAIwNPFCibK0uRK3wKwohZ55f3pV5BJqMjSmrvYN1NBrjW4SnXZ/6SSVHVKeTls+
         VbYNv/MCcNdWmlf7m5ujRWmQhjwjeZTbMey5wVyX6cqY+xtyJa4wlOOxJyjl6s6whfe/
         aQ7A==
X-Gm-Message-State: AHQUAuYuRTHJ7Kf77cwvK9Zd9Iv84J2L5cKxlFTDoAib6YZP1S0c78p1
	lJx3qsueejouGfw1heCllcNx8KD/ArZsm8JTHNImIB4Vep/eT9QIS60FEg0twgjFU7JbhPa2X+R
	ChJkx1urPbkPzyMDD6qn0Ulw5tmlI8MMH0bsIrRIFKhLECr+aeRmwUiHRH5a0bt6dW13HHFA/9Z
	Ii4yZBWTx01I1vLLroVJ/CiSYXZU0Xdb9iNeNxsaWT2Hh5zNPHZ/edTLcZJTALuiu/xfHwYcSMx
	FhUzNHSvUbHFAochdJkHZDZTqFJ/RlkWTF35N8D0wpb0ZX84gdB8WZKINFk1L9oRIhWNcdhSaG5
	urGwZihkB5aEKlwRWAhoozKYVaJelQ89ziHbAmYjXuKPMNs+uLYuFAU0e3rEkhDhgCgF1fZ2Yx/
	P
X-Received: by 2002:a9d:730c:: with SMTP id e12mr214375otk.144.1549918970334;
        Mon, 11 Feb 2019 13:02:50 -0800 (PST)
X-Received: by 2002:a9d:730c:: with SMTP id e12mr214313otk.144.1549918969483;
        Mon, 11 Feb 2019 13:02:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549918969; cv=none;
        d=google.com; s=arc-20160816;
        b=uqOp9uJBoWCu8ViviN71belFl2CO/klZSeEC93MtAAeDQzvAqlG+rv0yKxKt3dKkg2
         SNaFzeuDjA4YetLZqs2+bCve6NACRNfCtB2yhX66TLwPQ9OYQLCiGf4PPiKEKoDn2IME
         WBB7OKewYi3flW8VofMe6uQdaQ2EMBA0kPLqEDIy4MlrmPT3gl2fZAlcQBSBcDHsrmxN
         yOzeThRflY7ixmAqp0uLSEynMiqcmG92H2Do2RB9X8DzFI1EolDtShwp2B/IuvFRulUg
         POe2BV/hwFAbfj3/ugfxVyZZVWo3i9lFZoTSTrX/x7+9sOrcRn+EWlLJDMAP3H3Nxxd0
         3chA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ue3vXSU/Uyn4dHhRrNll0Xk0Xsd0Oc1wTjLcVxg/RVU=;
        b=wIj+vtTvSAJ1cNF/MCuHdsPsxlv4hkaPLvNRBXyuHvhSGtjijmLPAVjOz78k4d8vgM
         DL+RDI4TLhFFAhgfRl6jSGgCFtsxO3hTcooApCQQUqsPYrd2HfJVKDreE5qA8Y++qrIe
         LV2yNvZ0QvN1BoawwFfD1f+7v+vv1S3J2Psh275nmCVrG8oOEV+0Xim4TtX6qU86c56u
         tilAWhbaekWR19eVxddvZi7JeQuGORV++qY9nSeg4qPMvcbyuXx2e7Ib3V1g9A66rpS5
         jp1Ax1mhD8YvL54J8QFlwHUjCCXdNZn5jMMYzoyw5qShNdu+1dcA5WFrqJRn37kK9D4J
         cGXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=hUIoym1j;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m11sor6312892otk.110.2019.02.11.13.02.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 13:02:48 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=hUIoym1j;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ue3vXSU/Uyn4dHhRrNll0Xk0Xsd0Oc1wTjLcVxg/RVU=;
        b=hUIoym1jWomz+hQ3cjra7vbu8N5t4Hnlg+PAqHz9/FbJkw5AbL1Sv33KOuBzmBGiuw
         XFTkiY3/ijZ6462k6DJrU7QYA9Vd5lttHeHLC0g1iQcLlLS7j/vcZPHVAConzOdMRrvy
         n2QpK6+M5qBuH4QcCR04be/KEWKPeslapu3m3t0isgfrskGI8tLy1kqohwuqEFTvJPE3
         X1sCVWaUU0De1pZLAqvjBRCwaa7k+YeoI3EnJv4AYoa5NNEY1d7gCQSUmQsO2WEgstLP
         ac5rNKg/bs0GU3zUFz0Eq9XUOeFF4D8Di2ts/s5d0y6iESwJXdZbWcfvbwU4Nt0K7Oin
         LCmQ==
X-Google-Smtp-Source: AHgI3IZxeqNTfWgs9o1UN4GAPAtcCJWm5QBYZL8PcXZdv7fUAGZtHzMZB4bxYkGrLKUuX0CWjIpxvAiXIcKohnPhirs=
X-Received: by 2002:a9d:6a50:: with SMTP id h16mr169743otn.95.1549918968592;
 Mon, 11 Feb 2019 13:02:48 -0800 (PST)
MIME-Version: 1.0
References: <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz> <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca> <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <20190211182649.GD24692@ziepe.ca> <20190211184040.GF12668@bombadil.infradead.org>
 <CAPcyv4j71WZiXWjMPtDJidAqQiBcHUbcX=+aw11eEQ5C6sA8hQ@mail.gmail.com> <20190211204945.GF24692@ziepe.ca>
In-Reply-To: <20190211204945.GF24692@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Feb 2019 13:02:37 -0800
Message-ID: <CAPcyv4jHjeJxmHMyrbRhg9oeaLK5WbZm-qu1HywjY7bF2DwiDg@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>, Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, 
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

On Mon, Feb 11, 2019 at 12:49 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Mon, Feb 11, 2019 at 11:58:47AM -0800, Dan Williams wrote:
> > On Mon, Feb 11, 2019 at 10:40 AM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > On Mon, Feb 11, 2019 at 11:26:49AM -0700, Jason Gunthorpe wrote:
> > > > On Mon, Feb 11, 2019 at 10:19:22AM -0800, Ira Weiny wrote:
> > > > > What if user space then writes to the end of the file with a regular write?
> > > > > Does that write end up at the point they truncated to or off the end of the
> > > > > mmaped area (old length)?
> > > >
> > > > IIRC it depends how the user does the write..
> > > >
> > > > pwrite() with a given offset will write to that offset, re-extending
> > > > the file if needed
> > > >
> > > > A file opened with O_APPEND and a write done with write() should
> > > > append to the new end
> > > >
> > > > A normal file with a normal write should write to the FD's current
> > > > seek pointer.
> > > >
> > > > I'm not sure what happens if you write via mmap/msync.
> > > >
> > > > RDMA is similar to pwrite() and mmap.
> > >
> > > A pertinent point that you didn't mention is that ftruncate() does not change
> > > the file offset.  So there's no user-visible change in behaviour.
> >
> > ...but there is. The blocks you thought you freed, especially if the
> > system was under -ENOSPC pressure, won't actually be free after the
> > successful ftruncate().
>
> They won't be free after something dirties the existing mmap either.
>
> Blocks also won't be free if you unlink a file that is currently still
> open.
>
> This isn't really new behavior for a FS.

An mmap write after a fault due to a hole punch is free to trigger
SIGBUS if the subsequent page allocation fails. So no, I don't see
them as the same unless you're allowing for the holder of the MR to
receive a re-fault failure.

