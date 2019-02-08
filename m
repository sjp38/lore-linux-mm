Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 387A0C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 20:50:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCF5C218DA
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 20:50:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="i/4TQT+f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCF5C218DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DA548E009C; Fri,  8 Feb 2019 15:50:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38C288E009B; Fri,  8 Feb 2019 15:50:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A2D48E009C; Fri,  8 Feb 2019 15:50:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFFE48E009B
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 15:50:51 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id d5so4226611otl.21
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 12:50:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JYemvo/5t1MOtWOwE583j782fTMXN2hNeBA7xbWMF9U=;
        b=kYo1PtNGls57onkOGN3TGFVYegpI4mIAPewcX4W60uCf67BVc4uWNXUcAYG2DahFs2
         LgGJxivgxG4xeCgSOfC2QqR0ZzAhy40MunPMXcChcx9PsI75TNNTCyxEI509rxL5R4+W
         +AUy3nK/r4v2IDY7BaYO/hqN1xVcYNQWZh6msKtzeh0LfCTq9TtPM4PosHq51GsEPG7m
         L0Alc57KCSHkJ+xC1QWBrEvBoDw6Ys5iNe4UzIat+H7tGMxflwE5N+08VKYUm+spCxsX
         o+nJgPRHzEWQYPOtjLqY1Arsb7MU4ZBHIkn+wzAFE7rHwtKGWlQD/zzG3hk44RrOYp1c
         kuag==
X-Gm-Message-State: AHQUAuZHsnYQLaWAQw9TD/KhCGzFNGjm3B9qpyQeLMNbCcIJNyH0DRZc
	MojGB0PxtzoMr2KjMR3FAJHvXk8uGDIbebozHXWqc50XRBcmwC2vh0LcnrNM4XjK0ZphOBJv2EZ
	4m4cH7K4kWiXiUXo/3v2yWZ9yOnRR3jxYVI7IEXTjEdXoaKzFn40+w/B/lUutYjtl80oQjjWSV1
	A9L4wEs6S/w8yqUY9XULpMe7PPukC1zuewruZvfWPAOCQGPE59guDSURKVx9Uo8+obUZqaSCDbX
	S/PYPC9UwF437L7HHoQ3ky3Klinac+uV9dwtj1YIHLM/sdBLWvGbfuZovKStWSZ0rxl3wvy2YUA
	yDCKpT1s5uVtWrVkXmsc3+eaC0FXFMP1qfTGNMglGJ/GbXlTpymqksh27tSYXjUQ03dVf1a6ims
	0
X-Received: by 2002:a9d:490:: with SMTP id 16mr15182739otm.306.1549659051601;
        Fri, 08 Feb 2019 12:50:51 -0800 (PST)
X-Received: by 2002:a9d:490:: with SMTP id 16mr15182682otm.306.1549659050746;
        Fri, 08 Feb 2019 12:50:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549659050; cv=none;
        d=google.com; s=arc-20160816;
        b=vA4gpbFegQO19uw9m3EqgCa4hFtC0O2XhXImp/LNuF+oCDAr3fGS3LUUuyz1N1tkD4
         5SH05e42YkJqCkLfewEAgzKeoPidG1xAg9K8PLd8iNzWRrP24gWe5+C5a60jpDoV9ZZ2
         qPxoyd8ju4QF7A6xK3NCnxfU6UTbQUxeG8xu4yjVxnuB5GBauVXFIYKMSXppI+/wLhrY
         BvRwN0veVgkBROCspzGs0YN2jWDU0IMMUERodtfh+vO2FiX3zJBija0PD6t/IjfFsS0H
         rkSEc2cl6wq35zRnR7LbubG+SRvZ9n/7QUlCZtGrPM/pLKoKxcp9oPyn4q+1grv6NFtu
         BS8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JYemvo/5t1MOtWOwE583j782fTMXN2hNeBA7xbWMF9U=;
        b=LRKin01yzWVDftpWUUw1D79FvtraA3px6pdW+a6yXRJkQRCb21PA4BRXFTcTHNWsdF
         GV7boHEbVOls19uVMmLHVY+P2Nh/K2oItIb8TenmkKlHSNO2LkZ+TRVzr8vSIExTIT1a
         0gZKDLurUdnQp8N3quOraUj5Nml5aISbCwF85VcCs2yHyqRNf2UqI2MSJgl6l7krPxnu
         Kw1g/MFGl6OxdXhCCe1HkqXGwbRctWhRIqLaZetu/sSKbp6SDv/JJBxt1EzQdrEYvBtt
         lpfYHclMnpz/mvWpb3dPcDRt4SCVvxqrezgUMUsVsl30zBnFpRNEaYhVXNx2LUpvGsYf
         mVBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="i/4TQT+f";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i17sor1768029otp.65.2019.02.08.12.50.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Feb 2019 12:50:50 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="i/4TQT+f";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JYemvo/5t1MOtWOwE583j782fTMXN2hNeBA7xbWMF9U=;
        b=i/4TQT+fwabfyYsgo4Y5jOfGloT5rDwGaQAM9q/H5WwL1kSOYwzM/fG80v41weOUET
         yGlkmPrCpte1BDtX9n+RGFLkxO2cjNpKmlVD7cLnuhSQPIHtBVcYrCv0wF0G/F8JHdpU
         dY2XKodFBG8KVdIDKnt/xPACAh3MKMN+JNyTXuXCmeX+gsjJKmj05dvwbIbfsxwQU8iI
         4KQPyj3LrmdqJVdLR6GtQs0wgV+T6LQU8knkGBbiTxOlPDsB8BT7DgMoJFNsNqMmr6xq
         W1dNc+d9fw8jBMbCncMn3ZMSjaMpucCe6dRKdPaRo6VRtMPsA7gSpwVirMECn1iEtb4p
         C4uA==
X-Google-Smtp-Source: AHgI3IbxNCM6UhOk1OpWVxUvg07ioYW6oEVU3RYmPPPgAPOzHZ5LzJxfPbfmWzPOBTLnXOjr7fkjaTid6gn1yz3bEHM=
X-Received: by 2002:a9d:6ac2:: with SMTP id m2mr6527340otq.353.1549659050034;
 Fri, 08 Feb 2019 12:50:50 -0800 (PST)
MIME-Version: 1.0
References: <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz>
In-Reply-To: <20190208111028.GD6353@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 8 Feb 2019 12:50:37 -0800
Message-ID: <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Christopher Lameter <cl@linux.com>, 
	Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, 
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

On Fri, Feb 8, 2019 at 3:11 AM Jan Kara <jack@suse.cz> wrote:
>
> On Fri 08-02-19 15:43:02, Dave Chinner wrote:
> > On Thu, Feb 07, 2019 at 04:55:37PM +0000, Christopher Lameter wrote:
> > > One approach that may be a clean way to solve this:
> > > 3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
> > >    provide the virtual mapping when the PIN is done and DO NO OPERATIONS
> > >    on the longterm pinned range until the long term pin is removed.
> >
> > So, ummm, how do we do block allocation then, which is done on
> > demand during writes?
> >
> > IOWs, this requires the application to set up the file in the
> > correct state for the filesystem to lock it down so somebody else
> > can write to it.  That means the file can't be sparse, it can't be
> > preallocated (i.e. can't contain unwritten extents), it must have zeroes
> > written to it's full size before being shared because otherwise it
> > exposes stale data to the remote client (secure sites are going to
> > love that!), they can't be extended, etc.
> >
> > IOWs, once the file is prepped and leased out for RDMA, it becomes
> > an immutable for the purposes of local access.
> >
> > Which, essentially we can already do. Prep the file, map it
> > read/write, mark it immutable, then pin it via the longterm gup
> > interface which can do the necessary checks.
>
> Hum, and what will you do if the immutable file that is target for RDMA
> will be a source of reflink? That seems to be currently allowed for
> immutable files but RDMA store would be effectively corrupting the data of
> the target inode. But we could treat it similarly as swapfiles - those also
> have to deal with writes to blocks beyond filesystem control. In fact the
> similarity seems to be quite large there. What do you think?

This sounds so familiar...

    https://lwn.net/Articles/726481/

I'm not opposed to trying again, but leases was what crawled out
smoking crater when this last proposal was nuked.

