Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACE2EC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:23:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 521272175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:23:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="NaEYMsl8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 521272175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFE2D8E0018; Thu,  7 Feb 2019 00:23:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAE738E0002; Thu,  7 Feb 2019 00:23:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9E808E0018; Thu,  7 Feb 2019 00:23:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 843478E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 00:23:14 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id q20so6669689pls.4
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 21:23:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cVshJtSjVKCwFurHTQmQfI0T2s1YmLUjpm/MFByl6Xc=;
        b=kaf5fZZc9Gas958oGsXT1U9d4DOj6/ouo1gnzdnaZaMHuoto61wdiyivyFk1iVJ4kV
         Mv3fxq8aIxXLIBBH1t3tsBzIp2A9+nXa/PC0QykCmGPpAVzHHB/Odiy6sbSQiIIpjY7K
         gNEG3ooEfHc23qV1a8KnIVyQmXSi12IRBOHr6TSBNyRwF37paWu+kvAu9tq8RWai8M8v
         MoWzP4XdNsgsgoWp97eHKRVsqhdJvRHazzVY5UauPI+YBh3oGr/wRxUxKpzMmssjg1rH
         bpJH6gpasGHGcOXgKO++feCtmVp/VlvJHWnntPJfsGlqXkSsUK+8LAZMf85Lob0YC4Zf
         oq8w==
X-Gm-Message-State: AHQUAuY4vUbTyqNPoh1Wv8S3u0bESgXDHF+nNcxF+wm+p+G3l8G5ndlA
	E/WsJT1uHJVXsem6pZXFrbfamocDpC8N36psfAlUypktWxElaXMKWkX22a+2VdugkA3ULXPrzmN
	y+GHKzLq/0RzAFgyLx0zqFLmxq/I90X+7edPYyOe2kH6Y7p4fweg6j5Lmn4vUr9kOHCvm9RiolV
	7nbul86DBjEPB2M8sff635N3fg+SZ/ap3VJDjYlsZSKazydjzbhW8YMAlkVW4v/MpqpKXCbShtJ
	Qy72mfR7XGtLhqrSklmBwej3DsCTy8R8UrzXYCvvWWUiMZQnGKmzEqYLQGhMrpi48ALS+UkLPHG
	2RJIksu60nAFh6bHNZM4y8AyB1rJKe6fmEuhXE+5ekMN52XthexvKGfR/ELJVmsSyaMpeWSa/3X
	d
X-Received: by 2002:a17:902:2a0a:: with SMTP id i10mr14472972plb.323.1549516994050;
        Wed, 06 Feb 2019 21:23:14 -0800 (PST)
X-Received: by 2002:a17:902:2a0a:: with SMTP id i10mr14472917plb.323.1549516993057;
        Wed, 06 Feb 2019 21:23:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549516993; cv=none;
        d=google.com; s=arc-20160816;
        b=QuO7G4so2TZQGrGfUP2BFGwkatE8v+IQ+qxemPLwRG3JUuX7B/58drWj2DuK2njBam
         dyoQeR/VMPjZNvT78mittsS9M6zqm3OOj611BXvsMs+3+WubzhlAu2zZC++QBo4J7ZmE
         EmgqIR4ESbH3AWiI08r2eqj29lDWZrBg9/d0vlgvkdaNZUmaZubGkNvToYAnSPm9fOkc
         avI/PaMgm6Bp0+LlwfOSee9DkSYt9ialxoj+Ov45y3gJRKfuP1EDfSBhwSJwUIvgTu4U
         PdO2qd8+3fV6I/rTI1TmckWv2RFc0Bxb9Bq3PcRk3OpxR+hIMPlETVB8lkSdgGpehjoK
         yAyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cVshJtSjVKCwFurHTQmQfI0T2s1YmLUjpm/MFByl6Xc=;
        b=wxVoaQewdwTNylc4H36KuVBI9duVU0r9kZ202hdmV0CFgy1RJmoTKBEBhx3Wuhe3GZ
         tMdoWsTN88PN6R63foVEQPxNanc2VLrQOCzrdAwLcGLtfoE1wsgbvTBxq3wDDpmJTzmE
         UC3EhAaw9JcDCiuhFr1+gnItHDZPaBQs/Bam+hty5uXdpODqGXpBxUBmZ0Z4FufkkDxX
         K1yr4SLhuz861suZ2fJlqXQJjooZDR0nM11bQ5vUeNzqftRoKEA8aGENwRYNVciRpxHu
         3NU5xRIB1ua58ILqRcHxmV04LNrf6sF2ZPW3LtqmxO8LsNEC93WDmZ+eOcwPKQQ/SRRA
         VLtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=NaEYMsl8;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j38sor12455650pgm.3.2019.02.06.21.23.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 21:23:12 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=NaEYMsl8;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cVshJtSjVKCwFurHTQmQfI0T2s1YmLUjpm/MFByl6Xc=;
        b=NaEYMsl87u3ORqBgER+itikw003v+6AgT0DQysbxQDtN5NRBF5ISInNc97LEIPOm8w
         D/AabwySQ8Cfg/NBjZannqsDe6ff24623NLybIHvuio0nMUmcUTuS+BErL4z3sCljXOH
         pKf0eju5wun1elgUF4K+6n3Hk8lC+KoMqooOMhB9sMr998UzoxemylAzxifxfY/TIvGW
         jOkz8m84kWc1Ll7CPVYpmFIch/Eg8iy6hGZVgTyTO8viWrmkMRYI2+ATD6/vjudD9yJu
         2ocmWm8aFBEjQ+YQ9vPUzvkRcwiSdYPR4LjEctF/UmVsK8qzk1MyiQurF5xUoS8xcBC4
         GNaA==
X-Google-Smtp-Source: AHgI3IaFGqEWDTZBOyca0OXwnJLZY99n8scdwfgpYK2e9wV/+kFI2lKkM+lM5AEGIF6XkupZ6b5MBg==
X-Received: by 2002:a63:e20a:: with SMTP id q10mr12757021pgh.206.1549516992455;
        Wed, 06 Feb 2019 21:23:12 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id k63sm13207261pfc.76.2019.02.06.21.23.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 21:23:11 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1grc9W-000646-Nt; Wed, 06 Feb 2019 22:23:10 -0700
Date: Wed, 6 Feb 2019 22:23:10 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dave Chinner <david@fromorbit.com>
Cc: Doug Ledford <dledford@redhat.com>, Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190207052310.GA22726@ziepe.ca>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207035258.GD6173@dastard>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 02:52:58PM +1100, Dave Chinner wrote:
> On Wed, Feb 06, 2019 at 05:24:50PM -0500, Doug Ledford wrote:
> > On Wed, 2019-02-06 at 15:08 -0700, Jason Gunthorpe wrote:
> > > On Thu, Feb 07, 2019 at 08:03:56AM +1100, Dave Chinner wrote:
> > > > On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> > > > > On Wed, 6 Feb 2019, Doug Ledford wrote:
> > > > > 
> > > > > > > Most of the cases we want revoke for are things like truncate().
> > > > > > > Shouldn't happen with a sane system, but we're trying to avoid users
> > > > > > > doing awful things like being able to DMA to pages that are now part of
> > > > > > > a different file.
> > > > > > 
> > > > > > Why is the solution revoke then?  Is there something besides truncate
> > > > > > that we have to worry about?  I ask because EBUSY is not currently
> > > > > > listed as a return value of truncate, so extending the API to include
> > > > > > EBUSY to mean "this file has pinned pages that can not be freed" is not
> > > > > > (or should not be) totally out of the question.
> > > > > > 
> > > > > > Admittedly, I'm coming in late to this conversation, but did I miss the
> > > > > > portion where that alternative was ruled out?
> > > > > 
> > > > > Coming in late here too but isnt the only DAX case that we are concerned
> > > > > about where there was an mmap with the O_DAX option to do direct write
> > > > > though? If we only allow this use case then we may not have to worry about
> > > > > long term GUP because DAX mapped files will stay in the physical location
> > > > > regardless.
> > > > 
> > > > No, that is not guaranteed. Soon as we have reflink support on XFS,
> > > > writes will physically move the data to a new physical location.
> > > > This is non-negotiatiable, and cannot be blocked forever by a gup
> > > > pin.
> > > > 
> > > > IOWs, DAX on RDMA requires a) page fault capable hardware so that
> > > > the filesystem can move data physically on write access, and b)
> > > > revokable file leases so that the filesystem can kick userspace out
> > > > of the way when it needs to.
> > > 
> > > Why do we need both? You want to have leases for normal CPU mmaps too?
> 
> We don't need them for normal CPU mmaps because that's locally
> addressable page fault capable hardware. i.e. if we need to
> serialise something, we just use kernel locks, etc. When it's a
> remote entity (such as RDMA) we have to get that remote entity to
> release it's reference/access so the kernel has exclusive access
> to the resource it needs to act on.

Why can't DAX follow the path of GPU? Jerome has been working on
patches that let GPU do page migrations and other activities and
maintain full sync with ODP MRs.

I don't know of a reason why DAX migration would be different from GPU
migration.

The ODP RDMA HW does support halting RDMA access and interrupting the
CPU to re-establish access, so you can get your locks/etc as. With
today's implemetnation DAX has to trigger all the needed MM notifier
call backs to make this work. Tomorrow it will have to interact with
the HMM mirror API.

Jerome is already demoing this for the GPU case, so the RDMA ODP HW is
fine.

Is DAX migration different in some way from GPU's migration that it
can't use this flow and needs a lease to??? This would be a big
surprise to me.

> If your argument is that "existing RDMA apps don't have a recall
> mechanism" then that's what they are going to need to implement to
> work with DAX+RDMA. Reliable remote access arbitration is required
> for DAX+RDMA, regardless of what filesysetm the data is hosted on.

My argument is that is a toy configuration that no production user
would use. It either has the ability to wait for the lease to revoke
'forever' without consequence or the application will be critically
de-stablized by the kernel's escalation to time bound the response.
(or production systems never get revoke)

> Anything less is a potential security hole.

How does it get to a security hole? Obviously the pages under DMA
can't be re-used for anything..

> Once we have reflink on DAX, somebody is going to ask for
> no-compromise RDMA support on these filesystems (e.g. NFSv4 file
> server on pmem/FS-DAX that allows server side clones and clients use
> RDMA access) and we're going to have to work out how to support it.
> Rather than shouting at the messenger (XFS) that reports the hard
> problems we have to solve, how about we work out exactly what we
> need to do to support this functionality because it is coming and
> people want it.

I've thought this was basically solved - use ODP and you get full
functionality.  Until you just now brought up the idea that ODP is
not enough..

The arguing here is that there is certainly a subset of people that
don't want to use ODP. If we tell them a hard 'no' then the
conversation is done.

Otherwise, I like the idea of telling them to use a less featureful
XFS configuration that is 'safe' for non-ODP cases. The kernel has a
long history of catering to certain configurations by limiting
functionality or performance.

I don't like the idea of building toy leases just for this one,
arguably baroque, case.

> Requiring ODP capable hardware and applications that control RDMA
> access to use file leases and be able to cancel/recall client side
> delegations (like NFS is already able to do!) seems like a pretty

So, what happens on NFS if the revoke takes too long?

Jason

