Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25D78C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:51:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D58BD20856
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:51:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="x2dQ5VNc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D58BD20856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65CB28E0002; Tue, 29 Jan 2019 15:51:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63E8C8E0001; Tue, 29 Jan 2019 15:51:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 549A78E0002; Tue, 29 Jan 2019 15:51:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24E808E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:51:41 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id t83so11366317oie.16
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:51:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Sm0C8uNoBe+bGoNiTlTfD56A+1LmrUUdkZUy9VizQWU=;
        b=oRbBHm6CuwvyrreKJIGEQIZSIqB7yFN3bdpeY+8+3Em3j3NWLqNAXyYNiVK2uqhvWE
         uiU1ctgsulJSqb1p9Q07mR+G6LwhHCyQZylQOq6C4HWhXr06pburUR7R1yl9HoTOGn67
         z635dlPMc9ztN/5jI/Q7T/iJhiUXMU0M+JWY2a3aRFQWOo+ePihCwvCenaBTdk4rAs18
         +jJavnPEpOc/oKE/jdR9Rx0zflKIQ2ywRcWsiPwF7RnTxU82IP4jfsk8CdV5yvzo0hGi
         NZ3rRX/sbXsvnlUcw9qbMlX2Mkq4ayAGS/2pFUe/OTX+zMMBSMgw8COAeTkmW7XSerXg
         UKoA==
X-Gm-Message-State: AHQUAubncQybF0YjpVojHdt+uuiIbSkWdZVzCyl13RlsE44KO+D+gt8H
	58CNIfId1laiLB6K0X2vyeBQO9PdTdtlfz3Eb6X7bM0Ecakc6fKQesU35bZpeD+ogxrWswa3PSN
	OKgR5R/GR0TTw+DaYbs3CjQC2mRG9RRKm5Auw9EDfB3GL2CocL9GjYjtID0yTtaPPTnDeKwVf2c
	ILUGnRQeNvgENens8F8tGd8Mpa8NP37YZyJo0Ivh5rfK3GxJ9N1JoI46BawQ8T708a0WTShHjaI
	VrruS8FOHzodEQhrfyWoBrh+89DR4WEnKF/vtMnoKk2HWztRkBlo3Py24HjfS07gX4QwS41fS/R
	1jXPa+PkiCkUb3kM9s6mjEujEhfazmyu+jSJvgi9eSzTjS0posxoZ5xfOFFtK9hWknXAYFjg8ue
	d
X-Received: by 2002:aca:c715:: with SMTP id x21mr10041913oif.139.1548795100761;
        Tue, 29 Jan 2019 12:51:40 -0800 (PST)
X-Received: by 2002:aca:c715:: with SMTP id x21mr10041892oif.139.1548795100104;
        Tue, 29 Jan 2019 12:51:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548795100; cv=none;
        d=google.com; s=arc-20160816;
        b=hLuB8iJQm9BftYv6rPvOijyX8mjO7+cuUOrcDyUtfUiaG9zilqQCWpfu7HFdRwIMPo
         u4ku/EDktE3V6xkHYOYuHcVblgIvTPjeKcYn2LcmBtoN4tf7O0FVk4VBWz6srxe1Ll+Q
         IcQNxWKeyO5IrvIfZ4RiXvjHIxSCrcWgipOSkoahOD4BRZ8INHny6rb+qXh/p0sVhTnn
         ITXTFTagDHJPS2+TptlPXljYd5Bq4UWVgjoU6YsBw7XD4bPhvC8tGwS+hyoQezuc7F6s
         cXvxEhJIgG+EkbMY0FNP63gfI2rQMYPVai4XtNyd6TGIBH4nITG+XjoGQi0Fcw9AUlM9
         TBXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Sm0C8uNoBe+bGoNiTlTfD56A+1LmrUUdkZUy9VizQWU=;
        b=TjUVxiVzmKec7rae8e7p82ZITDNWRZv22CEyWPD0dSb64wRKRS8kC6agWoPwOk8d75
         H1Rjfop3eko5siCKieh7sWare6ZKk2LSYrdvrjNja1Nh7pjluYhmqXYvPBUheLDiZMyQ
         hj7P0XRKWmstueoJwRWikjiQKfaifpLsG+1AnwtvNi7ARpkbDxitGefP6cB7F+6SDwBS
         QgG/7dFtaRlcSWQJSnBhm43kTXbsVrPp/CgogrPRxrPQ4EcsCE32b0HUOP9Ja9PtT4pz
         uZ9bVEMvaOthSWCQbVqW6Eoqy8GB6jOSPCjHpK2s2ocYJC/3uw3b01mESp0az0MksKrM
         BLCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=x2dQ5VNc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 39sor8825656otp.137.2019.01.29.12.51.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 12:51:37 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=x2dQ5VNc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Sm0C8uNoBe+bGoNiTlTfD56A+1LmrUUdkZUy9VizQWU=;
        b=x2dQ5VNcnVPbB/3914tiLEowS6woiNf8m3LiZx+ju5NM3v2hVeBlbL5BB+2F3v8tI9
         8bCjWLHXDZraJiv5GcKCkDn+hDrl58AafZEFzNUwaTMcg0ITbieMksWTXZ+WXUO5yymp
         WT6Z1iZa70ZpL7xjPHjzcdu96ri3Gp92IiU5i0Zf5gucfPZ7J5ct3paPY5Lur4Vc1WQA
         g4JwYYZLzKp+AC82ktXAm3QGps1+EiY7OOb/Mdw2QelncymUyJ5Z70158dBvt5zq2icc
         CjlUBzlJXzvaGvW8l+NoooQg0boOnHnARMpgJLX/wBYYIhhMs/2IkGwy+MX1OttGq5Ck
         Ombw==
X-Google-Smtp-Source: ALg8bN7nGMnDAxFShZDbVEGc5m0fcNw41rSBLb27K1CZLYgEIBC+fjBSxWrbi+E2BQVSfwLrE6d6AQ/pP4xiQag4yws=
X-Received: by 2002:a9d:5cc2:: with SMTP id r2mr20886983oti.367.1548795097418;
 Tue, 29 Jan 2019 12:51:37 -0800 (PST)
MIME-Version: 1.0
References: <20190129165428.3931-1-jglisse@redhat.com> <20190129165428.3931-10-jglisse@redhat.com>
 <CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com> <20190129193123.GF3176@redhat.com>
In-Reply-To: <20190129193123.GF3176@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 29 Jan 2019 12:51:25 -0800
Message-ID: <CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
To: Jerome Glisse <jglisse@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 11:32 AM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Tue, Jan 29, 2019 at 10:41:23AM -0800, Dan Williams wrote:
> > On Tue, Jan 29, 2019 at 8:54 AM <jglisse@redhat.com> wrote:
> > >
> > > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > >
> > > This add support to mirror vma which is an mmap of a file which is on
> > > a filesystem that using a DAX block device. There is no reason not to
> > > support that case.
> > >
> >
> > The reason not to support it would be if it gets in the way of future
> > DAX development. How does this interact with MAP_SYNC? I'm also
> > concerned if this complicates DAX reflink support. In general I'd
> > rather prioritize fixing the places where DAX is broken today before
> > adding more cross-subsystem entanglements. The unit tests for
> > filesystems (xfstests) are readily accessible. How would I go about
> > regression testing DAX + HMM interactions?
>
> HMM mirror CPU page table so anything you do to CPU page table will
> be reflected to all HMM mirror user. So MAP_SYNC has no bearing here
> whatsoever as all HMM mirror user must do cache coherent access to
> range they mirror so from DAX point of view this is just _exactly_
> the same as CPU access.
>
> Note that you can not migrate DAX memory to GPU memory and thus for a
> mmap of a file on a filesystem that use a DAX block device then you can
> not do migration to device memory. Also at this time migration of file
> back page is only supported for cache coherent device memory so for
> instance on OpenCAPI platform.

Ok, this addresses the primary concern about maintenance burden. Thanks.

However the changelog still amounts to a justification of "change
this, because we can". At least, that's how it reads to me. Is there
any positive benefit to merging this patch? Can you spell that out in
the changelog?

> Bottom line is you just have to worry about the CPU page table. What
> ever you do there will be reflected properly. It does not add any
> burden to people working on DAX. Unless you want to modify CPU page
> table without calling mmu notifier but in that case you would not
> only break HMM mirror user but other thing like KVM ...
>
>
> For testing the issue is what do you want to test ? Do you want to test
> that a device properly mirror some mmap of a file back by DAX ? ie
> device driver which use HMM mirror keep working after changes made to
> DAX.
>
> Or do you want to run filesystem test suite using the GPU to access
> mmap of the file (read or write) instead of the CPU ? In that case any
> such test suite would need to be updated to be able to use something
> like OpenCL for. At this time i do not see much need for that but maybe
> this is something people would like to see.

In general, as HMM grows intercept points throughout the mm it would
be helpful to be able to sanity check the implementation.

