Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88B82C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 22:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34B70218D9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 22:44:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="de2N2G/e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34B70218D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5BAF8E0106; Wed,  6 Feb 2019 17:44:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2DD38E0103; Wed,  6 Feb 2019 17:44:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1E6B8E0106; Wed,  6 Feb 2019 17:44:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7229D8E0103
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 17:44:58 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id w24so7424712otk.22
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 14:44:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XFjuZa9EThrf5IvV1ixPwSd23JzyLsLNT9vnOAew2W4=;
        b=oHiysrI/j82J1sy7i+qzFg1aqI+li9NAfQA8S6fnnmtVWPAVyNQSQtFjylbKfN4N+i
         smFUP4S+HsszMq/7tX1KEqRGf7rhuA5gs7H6CRfBuVtN2bl2QC1wKu4xmjx+zKnw7L/T
         AjbHwymB3rnlSD1GEvfUKJdXjHUUwEgYbiT9iCSw/WQAje47h0YbAeElkhDi1f3kyMXI
         h6bVfeR68sPyBag/HoHsnncCkLN01VbPvNrRu6cpYsXydW4cX3rt9R5+BSn276AvHgKO
         jjdBvyrENk4qF/u72gohOonJPI8AHgRGeDrql3ryuNtNPxVfRN+qXLv5VEl/53HA6Viz
         QInA==
X-Gm-Message-State: AHQUAuaX0/ASl7hAhwrCrEScDCHH00D2Uu5NJGDuGpWQ/UsfzbD+PRCp
	dZfJZBPeU9ONngnsv/pS6aDDCfCSuf0v8+wLycK0xGyYxN+eAxnfioCx7AeUcVo67M47YU5ahJV
	sIkY94yIXRy8P1mIwBt3k6UFk2RpLbXWKAHlPTo1r0NVU2PFlY8TxH3Skt1SlpV8fGiYL90nq/w
	Q6BsbUAewhyjGGH53uNANIr+nJJ/VH1nux7kRsV/au1xLEx9RKIRxgHSzrWn2zjrlJ3+CTbhXBw
	JBYZHXYZQS+yyvff0aVZiLClgkR0zI/v3SG7WgFMxvtmKYomfFrv+prEgPedy5+C6165lCPxmwP
	/CnycP8RZHvdvXKVs+98iADUNE1SIY61g00OQCwk3i27C6xmory9HR105N0th4kuANSq1+kJwrj
	s
X-Received: by 2002:a9d:39f7:: with SMTP id y110mr6558794otb.240.1549493098139;
        Wed, 06 Feb 2019 14:44:58 -0800 (PST)
X-Received: by 2002:a9d:39f7:: with SMTP id y110mr6558772otb.240.1549493097160;
        Wed, 06 Feb 2019 14:44:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549493097; cv=none;
        d=google.com; s=arc-20160816;
        b=vU/AJOxK+e+wGuF09sTfGjjIu3Na0PXKK2HIiCEliZz4qx42vE6DbKihwcmpXNAFkF
         T4Y0NMJVF5e0dGPIJs0f0MduntlPwKmSin4SKaHp+8C40BKaapcfA4bbX+yPS57I8sne
         NvfiG4Nw91ikzZAAjtU0t55nTBmkd2bHi5CfXGlm5WSIlxj7bVZzL9nYccjfj+r5OpSU
         zGyK62bz65GnifRDIj2/mG8ZOwaMgiIsBkkvnMZ4xWlT3VLjQTLqhXRP6X6rOcmQlu70
         L9EqMPtPJRNFFD+xWcAZqEJsFBRBBnXuubn1J1yjTcXYlqO6uau6voiDVOQMeRzhA1Y2
         fQig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XFjuZa9EThrf5IvV1ixPwSd23JzyLsLNT9vnOAew2W4=;
        b=Z3tXBfAHFzlP7CXlWYalRQUp3KCWImie9DRuqdB6+FjfVvUXt/GunH4gbIzxlXO5j8
         tyt0YVk7KHwui7ZXFTHkpOKhJx3qLKb1F4iBKTijVpkdXLt/i/97NY5Lu4LQNEUSQUix
         /qMD9Jorclyz8EE7qHQH21WB2VpuhCY9eI0YABU1EHG4uDp/Q3aFw8dMzqFTM5gLix9n
         zU6XVAu3oqUr0G8kmGk2QFWJs5xJbu7hJVviOnLankT2AG4z5kWoV5xx93nGCXoxrjBk
         iahFTjBT5hHS0Hdz9DaF5Zv0cqjY33GOqayo31+I7BBNeiYl5WPnnap6X/gOyEo/u/US
         CYpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="de2N2G/e";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w13sor12491623oif.35.2019.02.06.14.44.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 14:44:57 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="de2N2G/e";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XFjuZa9EThrf5IvV1ixPwSd23JzyLsLNT9vnOAew2W4=;
        b=de2N2G/e5D0ca+8pvHpuRPjzFS+xczhbc4gjFlLDeG+zHj5jeybV5BI2FThr9cCOi+
         Es8lMPUqE3qO/Q+rfdxbneHCzSbtUOSbUKNEfBjFqUsM1xil9/ghFzFuuO/XreIj/B0O
         /xJPF4t+KhQtfooLNJm8u04S3FyUIsPdEz9QZMk+K1Ac7i7vDyXSCPpLh70pWfglQ0Vc
         vpbwFExoR7z9gG16NCYq26SmTV/YYq4/xh6l0ucsxxw/qqx0GXu3ruoRdbpvwE30Za9Q
         mUTouzI2T5XXN/omdeUmJb5MuSINfEaySOrDJZ9LPhIKljIm4NzFe4ETNRC7fK6Rt+m4
         JAjQ==
X-Google-Smtp-Source: AHgI3IZ1IoWGhI2GcwS/xdNJ+ERSkJIEi64BzN6fZt2VHpDtwTv+/PUM2OnQJC74i1O2ufPzFTXDcK9IOXicacFZeMg=
X-Received: by 2002:aca:ecc7:: with SMTP id k190mr935462oih.0.1549493096761;
 Wed, 06 Feb 2019 14:44:56 -0800 (PST)
MIME-Version: 1.0
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca> <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
In-Reply-To: <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 6 Feb 2019 14:44:45 -0800
Message-ID: <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Doug Ledford <dledford@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dave Chinner <david@fromorbit.com>, 
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

On Wed, Feb 6, 2019 at 2:25 PM Doug Ledford <dledford@redhat.com> wrote:
>
> On Wed, 2019-02-06 at 15:08 -0700, Jason Gunthorpe wrote:
> > On Thu, Feb 07, 2019 at 08:03:56AM +1100, Dave Chinner wrote:
> > > On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> > > > On Wed, 6 Feb 2019, Doug Ledford wrote:
> > > >
> > > > > > Most of the cases we want revoke for are things like truncate().
> > > > > > Shouldn't happen with a sane system, but we're trying to avoid users
> > > > > > doing awful things like being able to DMA to pages that are now part of
> > > > > > a different file.
> > > > >
> > > > > Why is the solution revoke then?  Is there something besides truncate
> > > > > that we have to worry about?  I ask because EBUSY is not currently
> > > > > listed as a return value of truncate, so extending the API to include
> > > > > EBUSY to mean "this file has pinned pages that can not be freed" is not
> > > > > (or should not be) totally out of the question.
> > > > >
> > > > > Admittedly, I'm coming in late to this conversation, but did I miss the
> > > > > portion where that alternative was ruled out?
> > > >
> > > > Coming in late here too but isnt the only DAX case that we are concerned
> > > > about where there was an mmap with the O_DAX option to do direct write
> > > > though? If we only allow this use case then we may not have to worry about
> > > > long term GUP because DAX mapped files will stay in the physical location
> > > > regardless.
> > >
> > > No, that is not guaranteed. Soon as we have reflink support on XFS,
> > > writes will physically move the data to a new physical location.
> > > This is non-negotiatiable, and cannot be blocked forever by a gup
> > > pin.
> > >
> > > IOWs, DAX on RDMA requires a) page fault capable hardware so that
> > > the filesystem can move data physically on write access, and b)
> > > revokable file leases so that the filesystem can kick userspace out
> > > of the way when it needs to.
> >
> > Why do we need both? You want to have leases for normal CPU mmaps too?
> >
> > > Truncate is a red herring. It's definitely a case for revokable
> > > leases, but it's the rare case rather than the one we actually care
> > > about. We really care about making copy-on-write capable filesystems like
> > > XFS work with DAX (we've got people asking for it to be supported
> > > yesterday!), and that means DAX+RDMA needs to work with storage that
> > > can change physical location at any time.
> >
> > Then we must continue to ban longterm pin with DAX..
> >
> > Nobody is going to want to deploy a system where revoke can happen at
> > any time and if you don't respond fast enough your system either locks
> > with some kind of FS meltdown or your process gets SIGKILL.
> >
> > I don't really see a reason to invest so much design work into
> > something that isn't production worthy.
> >
> > It *almost* made sense with ftruncate, because you could architect to
> > avoid ftruncate.. But just any FS op might reallocate? Naw.
> >
> > Dave, you said the FS is responsible to arbitrate access to the
> > physical pages..
> >
> > Is it possible to have a filesystem for DAX that is more suited to
> > this environment? Ie designed to not require block reallocation (no
> > COW, no reflinks, different approach to ftruncate, etc)
>
> Can someone give me a real world scenario that someone is *actually*
> asking for with this?

I'll point to this example. At the 6:35 mark Kodi talks about the
Oracle use case for DAX + RDMA.

https://youtu.be/ywKPPIE8JfQ?t=395

Currently the only way to get this to work is to use ODP capable
hardware, or Device-DAX. Device-DAX is a facility to map persistent
memory statically through device-file. It's great for statically
allocated use cases, but loses all the nice things (provisioning,
permissions, naming) that a filesystem gives you. This debate is what
to do about non-ODP capable hardware and Filesystem-DAX facility. The
current answer is "no RDMA for you".

> Are DAX users demanding xfs, or is it just the
> filesystem of convenience?

xfs is the only Linux filesystem that supports DAX and reflink.

> Do they need to stick with xfs?

Can you clarify the motivation for that question? This problem exists
for any filesystem that implements an mmap that where the physical
page backing the mapping is identical to the physical storage location
for the file data. I don't see it as an xfs specific problem. Rather,
xfs is taking the lead in this space because it has already deployed
and demonstrated that leases work for the pnfs4 block-server case, so
it seems logical to attempt to extend that case for non-ODP-RDMA.

> Are they
> really trying to do COW backed mappings for the RDMA targets?  Or do
> they want a COW backed FS but are perfectly happy if the specific RDMA
> targets are *not* COW and are statically allocated?

I would expect the COW to be broken at registration time. Only ODP
could possibly support reflink + RDMA. So I think this devolves the
problem back to just the "what to do about truncate/punch-hole"
problem in the specific case of non-ODP hardware combined with the
Filesystem-DAX facility.

