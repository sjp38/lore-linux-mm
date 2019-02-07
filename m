Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7C24C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 06:00:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 836A72175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 06:00:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="oQHOz0Tn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 836A72175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AC1B8E001E; Thu,  7 Feb 2019 01:00:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15EC98E0002; Thu,  7 Feb 2019 01:00:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 025648E001E; Thu,  7 Feb 2019 01:00:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3C6B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 01:00:41 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id c26so8416045otl.19
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 22:00:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=t9UI+A00WyCBHTuJak4tgcvwsNu71LzDt60tTRTPY0A=;
        b=ZXehqLuWqYJwrGNevaHc8cWvDTjGHP3YNBItrg7hTwqUaDx9wLbfJfER6Bbn0TFyZX
         cMZnZEb9bNKNaNsPl1Se0EAC7rpx1Wxv1aLgscktXgr0fMiBYwEzIGfovLmt3Y4Jdtmh
         sghrjbMK5KghxoOh0sbRtwaEsUWtYyfe6B1k7yY4/ozHwgJnED1rlBy0tnGJGIZI1Hwu
         QIIBFqReTvctVO8LWmeYAgFWmaIDeCMYeBqLPwyeSbPk6hLkLLXPFfhnv4uAUQgLCGJY
         h1xDX++50v3Z0nvob0VIKTDDcIePOLlH7Nz06qq0Gi7nAOJbdu70ga1ve6Gz8vwDVCBh
         ar6g==
X-Gm-Message-State: AHQUAuaC04Ti8aXjyIjVhj5uZzl81V8I8+ch1wsh5dNlejK/JRa04xQl
	wioM5sZJJ0Mam5mJR5Pexhd1X9SGU7OaOq8mh3/UcGFrrbXfnwv8dOsDOHinjE4sJJy9OogT0ft
	AajvCNpgz6chY67YtHK6q1ex6/Bpc0340sojyfRTG/p+piGpJtEJHwpSW8lgE2r+LjcOaI5rSeM
	tFksYmwv6v4+HB4E8qnypEjUfbKXlbxhM+aPsfgkx335NkBCUy/AkBan8t4JA4Ekr/L7ZWS0oN1
	j+El7G95Px1x7q582fDdx33Wjca4kVgXtD8eehuxr5GKZeHkhmxv8Qa8YQZpP0VphUDJa8+wzhS
	jriNXsJNE/BrfGQKQHN+3qfkzTL4gvTsckr1qGKZah4jsdZXy7frgSL6HClR5y4wyRAOGX13yn+
	8
X-Received: by 2002:a05:6830:2101:: with SMTP id i1mr4061143otc.289.1549519241294;
        Wed, 06 Feb 2019 22:00:41 -0800 (PST)
X-Received: by 2002:a05:6830:2101:: with SMTP id i1mr4061092otc.289.1549519240198;
        Wed, 06 Feb 2019 22:00:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549519240; cv=none;
        d=google.com; s=arc-20160816;
        b=RdXUuCU9AlG2womzPCdaVs2GJ3yjH6qvi4s0QpZl3Nsj7RdkMNi0gFxqCvkPZVgpCA
         R3LbsZLFS0DGpjXeNgUGJdrQOZmU/sZ50L+tdJOo+kBnmxmonh42ccAoTRWMwe/3BAtE
         aYshLHa/42xQKHFHDgHa730fXBQIbPQCVEU/evOBg5ututL5stthB4A7ab+Qi4CiBLxe
         tKrc0V0GzBfMKJttsP4mfN9QZXRUcXHFjhlhM5a3qHKfsGcLZOZEhFoFzvIqF9m+8lzS
         c4YUB/Ik9Mztt5W1Zyzxw4WbVdq85JUW61FdUuktt7D0t6wE9gb5USCn6Bxc7yC75FY9
         WeWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=t9UI+A00WyCBHTuJak4tgcvwsNu71LzDt60tTRTPY0A=;
        b=okmHi5xDwHBULj/8mgb7kAmJjRS/IVElOGdkEiQZyZ7pmC8KeolOsYSrBYg/7v2L8U
         vlXeD3Jdghk6OZdsp/vrhP9s0Z0wI23MwTKXkP2tN8QF7733GRXCXTaY2S3tlsdKgAAw
         goWURbuKTLwK55SHKdu8U3UlU/9WI56Wt59natsIw4EtMeXrRSDcTFpbzDYKjXGE4QW3
         OduUm+2TCXaG1M2vxerWiqP+dUbj4986ep/YY6yk9kd28kQQEvzkUe5BCnsxQmRejN/k
         ioUWWOvxu0R7IrEOn28NJVgvUczdS3twAEJLWGsDBEaP4GzVBUJyrtp/cV/Q7J4naMMy
         fzOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=oQHOz0Tn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8sor13612045ots.158.2019.02.06.22.00.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 22:00:40 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=oQHOz0Tn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=t9UI+A00WyCBHTuJak4tgcvwsNu71LzDt60tTRTPY0A=;
        b=oQHOz0Tnlril3AwK5Unqi0VM6aPU9bTLvHWpWghCYBwK/OJrCtGFj1Wvim7OFpDg+e
         bV8KSViCCSqTSTstJPAI1X2yucKNMhPKWwMqM9fCFdC6pP7lf7+Lqk9TRX3G4fq1eaxX
         FlP0n5eOElFNVno82wUYgzzyZCiatHllVlcAjAg34ITBSwkhc6+5M6MSVmlpFWPFTFNj
         ezoUQ+TwcUmcnzO/zOLfV4XAjhHpbeVt5H00sabPDgLrdcLHDF8NtVgdhr015eSU1Y1K
         41DodgHK68xC6QMboiqvxuXYRvAa8ND3ZbwTu0I7SJjCndqMHYdq95JqOMM5gy3lEpgx
         QmqQ==
X-Google-Smtp-Source: AHgI3Ibz0usX0602tfRkv65vvYAyNDRgDuO1huqythSJRGlFE4EHhd5l9sJPZMNUtcteuZQRKCt93W27liyqGJ+I8cc=
X-Received: by 2002:a9d:7493:: with SMTP id t19mr3917392otk.98.1549519239700;
 Wed, 06 Feb 2019 22:00:39 -0800 (PST)
MIME-Version: 1.0
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard> <20190207052310.GA22726@ziepe.ca>
In-Reply-To: <20190207052310.GA22726@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 6 Feb 2019 22:00:28 -0800
Message-ID: <CAPcyv4jd4gxvt3faYYRbv5gkc6NGOKjY_Z-P0Ph=ss=gWZw7sA@mail.gmail.com>
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

On Wed, Feb 6, 2019 at 9:23 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Thu, Feb 07, 2019 at 02:52:58PM +1100, Dave Chinner wrote:
> > On Wed, Feb 06, 2019 at 05:24:50PM -0500, Doug Ledford wrote:
> > > On Wed, 2019-02-06 at 15:08 -0700, Jason Gunthorpe wrote:
> > > > On Thu, Feb 07, 2019 at 08:03:56AM +1100, Dave Chinner wrote:
> > > > > On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> > > > > > On Wed, 6 Feb 2019, Doug Ledford wrote:
> > > > > >
> > > > > > > > Most of the cases we want revoke for are things like truncate().
> > > > > > > > Shouldn't happen with a sane system, but we're trying to avoid users
> > > > > > > > doing awful things like being able to DMA to pages that are now part of
> > > > > > > > a different file.
> > > > > > >
> > > > > > > Why is the solution revoke then?  Is there something besides truncate
> > > > > > > that we have to worry about?  I ask because EBUSY is not currently
> > > > > > > listed as a return value of truncate, so extending the API to include
> > > > > > > EBUSY to mean "this file has pinned pages that can not be freed" is not
> > > > > > > (or should not be) totally out of the question.
> > > > > > >
> > > > > > > Admittedly, I'm coming in late to this conversation, but did I miss the
> > > > > > > portion where that alternative was ruled out?
> > > > > >
> > > > > > Coming in late here too but isnt the only DAX case that we are concerned
> > > > > > about where there was an mmap with the O_DAX option to do direct write
> > > > > > though? If we only allow this use case then we may not have to worry about
> > > > > > long term GUP because DAX mapped files will stay in the physical location
> > > > > > regardless.
> > > > >
> > > > > No, that is not guaranteed. Soon as we have reflink support on XFS,
> > > > > writes will physically move the data to a new physical location.
> > > > > This is non-negotiatiable, and cannot be blocked forever by a gup
> > > > > pin.
> > > > >
> > > > > IOWs, DAX on RDMA requires a) page fault capable hardware so that
> > > > > the filesystem can move data physically on write access, and b)
> > > > > revokable file leases so that the filesystem can kick userspace out
> > > > > of the way when it needs to.
> > > >
> > > > Why do we need both? You want to have leases for normal CPU mmaps too?
> >
> > We don't need them for normal CPU mmaps because that's locally
> > addressable page fault capable hardware. i.e. if we need to
> > serialise something, we just use kernel locks, etc. When it's a
> > remote entity (such as RDMA) we have to get that remote entity to
> > release it's reference/access so the kernel has exclusive access
> > to the resource it needs to act on.
>
> Why can't DAX follow the path of GPU? Jerome has been working on
> patches that let GPU do page migrations and other activities and
> maintain full sync with ODP MRs.
>
> I don't know of a reason why DAX migration would be different from GPU
> migration.

I don't think we need leases in the ODP case.

> The ODP RDMA HW does support halting RDMA access and interrupting the
> CPU to re-establish access, so you can get your locks/etc as. With
> today's implemetnation DAX has to trigger all the needed MM notifier
> call backs to make this work. Tomorrow it will have to interact with
> the HMM mirror API.
>
> Jerome is already demoing this for the GPU case, so the RDMA ODP HW is
> fine.
>
> Is DAX migration different in some way from GPU's migration that it
> can't use this flow and needs a lease to??? This would be a big
> surprise to me.

Agree, I see no need for leases in the ODP case the mmu_notifier is
already fulfilling the same role as a lease notification.

> > If your argument is that "existing RDMA apps don't have a recall
> > mechanism" then that's what they are going to need to implement to
> > work with DAX+RDMA. Reliable remote access arbitration is required
> > for DAX+RDMA, regardless of what filesysetm the data is hosted on.
>
> My argument is that is a toy configuration that no production user
> would use. It either has the ability to wait for the lease to revoke
> 'forever' without consequence or the application will be critically
> de-stablized by the kernel's escalation to time bound the response.
> (or production systems never get revoke)

I think we're off track on the need for leases for anything other than
non-ODP hardware.

Otherwise this argument seems to be saying there is absolutely no safe
way to recall a memory registration from hardware, which does not make
sense because SIGKILL needs to work as a last resort.

> > Anything less is a potential security hole.
>
> How does it get to a security hole? Obviously the pages under DMA
> can't be re-used for anything..

Writes to storage outside the security domain they were intended due
to the filesystem reallocating the physical blocks.

> > Once we have reflink on DAX, somebody is going to ask for
> > no-compromise RDMA support on these filesystems (e.g. NFSv4 file
> > server on pmem/FS-DAX that allows server side clones and clients use
> > RDMA access) and we're going to have to work out how to support it.
> > Rather than shouting at the messenger (XFS) that reports the hard
> > problems we have to solve, how about we work out exactly what we
> > need to do to support this functionality because it is coming and
> > people want it.
>
> I've thought this was basically solved - use ODP and you get full
> functionality.  Until you just now brought up the idea that ODP is
> not enough..

I think that was a misunderstanding, I struggle to see how a driver
that agrees to be bound by mmu notifications (ODP) has any problems
with anything the filesystem wants to do with the mapping. My
assumption is that ODP == filesystem can invalidate mappings at will
and all is good.

> The arguing here is that there is certainly a subset of people that
> don't want to use ODP. If we tell them a hard 'no' then the
> conversation is done.

Again, SIGKILL must work the RDMA target can't survive that, so it's
not impossible, or are you saying not even SIGKILL can guarantee an
RDMA registration goes idle? Then I can see that "hard no" having real
teeth otherwise it's a matter of software.

> Otherwise, I like the idea of telling them to use a less featureful
> XFS configuration that is 'safe' for non-ODP cases. The kernel has a
> long history of catering to certain configurations by limiting
> functionality or performance.

That's an unsustainable maintenance burden for the filesystem, just
keep the status quo of failing the registration at that point or
requiring a filesystem to not be used.

> I don't like the idea of building toy leases just for this one,
> arguably baroque, case.

What makes it a toy and baroque? Outside of RDMA registrations being
irretrievable I have a gap in my understanding of what makes this
pointless to even attempt?

> > Requiring ODP capable hardware and applications that control RDMA
> > access to use file leases and be able to cancel/recall client side
> > delegations (like NFS is already able to do!) seems like a pretty
>
> So, what happens on NFS if the revoke takes too long?
>
> Jason

