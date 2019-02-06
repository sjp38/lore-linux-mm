Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C604C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 22:08:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1B28218EA
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 22:08:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="UjACPc/7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1B28218EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15EA38E0104; Wed,  6 Feb 2019 17:08:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10F008E0103; Wed,  6 Feb 2019 17:08:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF3138E0104; Wed,  6 Feb 2019 17:08:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A85CA8E0103
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 17:08:31 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a26so1931302pff.15
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 14:08:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KJwz5D7Q6Dz66NllUORQ/Snomm0KllaaPa/yLCdCQ6s=;
        b=OGcOFPRe58sSE3MOEAKAaTfoYvfuy5RlPazmUjoPkUW0Vv6zPPdiiPNnttR+KowsqK
         kyKklAEqDSqB95ENsKqPtb3dmCHGS8GfMZlDIc4tXWe2ioh4SnGcHA2omJWdMOHUyHnc
         zDGeppzm+NZVbxuu93FrO0cSkaawxAF4nVjIGbPdg8PtzmKVYPfUVAjZ4lVN20OkAaXe
         /Euu4heSYcsvXa0uIqmHWtq3hUtRGfpBTpF75ntrWwz8wvSerN62ADySpzubgpqeWZRR
         pUgJ1NS4pzCiBa7CNZFXKk5+zLznGFcHayYWsoa1sG89JRiW9Ju0ojlPOGWum82rzcpp
         OYBA==
X-Gm-Message-State: AHQUAubnzv1D0Zejsympa8CrrK6S/OVBoSZlOxT5kThhhBQ6XYwClQMg
	5i8hM7pVTJP/JFn2UmPVvv7LVcBe2GNPVlQ5tbrRlCNSeZ0jyse5uliISLWF1PgE3KHwdm3ZqqS
	1+4jcMdvbfTAxxC548i84iVmz2ZYewg4p+iWPQTVYmzpawa1QDuoZgvOcRGNTOXiK+BpyiPOq6M
	CyVyo9mh9HF+GBQb0QjCK3AtjofTaWHw2SupCZxcawO36OrOOqk5Rcwf/8rvWHfEY//ZIZ7BR4s
	eGSV/zZYr9vllxvditfx/gbSx5Q64b7zzKUzF48hu/dEqBtu4fcPJgjFB1jNeQMrGxShRPMwuZ6
	WnbeI1BiUhhs8qsFsIvg1BQhuCLEePWLkzp8X0JZT4b8oasbEcDQdOPGc5g/XGU1bYNXSL6IgV6
	A
X-Received: by 2002:a63:d104:: with SMTP id k4mr11435136pgg.227.1549490911352;
        Wed, 06 Feb 2019 14:08:31 -0800 (PST)
X-Received: by 2002:a63:d104:: with SMTP id k4mr11435064pgg.227.1549490910347;
        Wed, 06 Feb 2019 14:08:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549490910; cv=none;
        d=google.com; s=arc-20160816;
        b=wHnQl+fTlopNhm5ZasdGJKsc1tVcjDChAPAiMQ9cDbvSlXY6nVfOZsYCLS+tOksqb5
         6EgUuudmvbyWNj8JwbOTZvO2oMxwpmGHy86OosXufUwCTgKj0+FDAnrZJYvmBZfEEBNT
         yoShBFY47PiNigXOnsCfkx/2eiw80slwgPa12RJL9M4v+hSCIWoYibsk+7PSw8L29kyg
         XZphm7321KklXUJv/NhKdbXqwzDP3sOIpk3U6lt5xK4HrqarCLM97bNt6EyH1Po0CJeX
         1+I935Xong2Q5QhhygF/fVmF4btsY8sbqPNJWhEtkxoGl30TTheS7tojQfGfwYGyqbh8
         1Eug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KJwz5D7Q6Dz66NllUORQ/Snomm0KllaaPa/yLCdCQ6s=;
        b=TQ3tX51DZDy4UiTFs4ZvgP2J0MujcoTv8BDRbv5F7ow76rWjIJksd2lYUGL0PBKZVz
         ImvFYt9w0FYgR1RzGWdIBDb3ej8o3Bfzh/S+QZsHp1OcmDA4RznrZW3GRMhjw9cBQJmU
         arW4MH4zEYbfHzcjKDKVGvjWm5QwSv5bKFsncmdgW+RqqJvWxMM7kpaBLMFNKSfiMfZt
         mtVE/xM63bIbDt7rrruVNH8btCFLeY9Iz926ImbnyDowF6NsFFj7qEl6Dsa5WB5ezx7b
         ix71DgUDkqpRM29Js1cbLk+4hvruOpacId+fvYQ7omBnECSVlr+HR4suJVORq6o2iUti
         6zqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="UjACPc/7";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w17sor11469691pga.2.2019.02.06.14.08.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 14:08:30 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="UjACPc/7";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KJwz5D7Q6Dz66NllUORQ/Snomm0KllaaPa/yLCdCQ6s=;
        b=UjACPc/7YocMeD76XYauB6nZ6RDa63UossHuaJ+0TIiKgho/ArpyBlacPPqsZLrNnT
         KnHqLhX8P3aJV8864C9Tt9DI58/184m0jfEFnmLrRvW40Nd86trk3aJ53qkD/bG6gYfh
         IJNio6AyjA6beSbJRPDCSPJ3tMdw7zgulCBAcso4hIw5ocsapg0AumKahiqQVn9xRJYZ
         JQnQLAE5mrdKolFzsQNwfnkQmj4pz6yIiPtguPt+v8g1qFK7im9gyqoQU/XE4iHnxnR7
         YDF4R60zWNu45I8qSRhVYXW0+h+NNHSoJDCLQ4cciOYgXWXrt7gBPQVyio/gcxVZZQaZ
         OrNg==
X-Google-Smtp-Source: AHgI3IZ9sM2NemHPkXJcEytXog4mo9/7nqUOfJbzWrMCoEPFEnffuZ1BU2oh+A0ce2olQXr6DG07vw==
X-Received: by 2002:a63:ed03:: with SMTP id d3mr11531445pgi.275.1549490909681;
        Wed, 06 Feb 2019 14:08:29 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id p24sm144065pfj.72.2019.02.06.14.08.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 14:08:28 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1grVMq-0004ip-7P; Wed, 06 Feb 2019 15:08:28 -0700
Date: Wed, 6 Feb 2019 15:08:28 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dave Chinner <david@fromorbit.com>
Cc: Christopher Lameter <cl@linux.com>, Doug Ledford <dledford@redhat.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206220828.GJ12227@ziepe.ca>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206210356.GZ6173@dastard>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 08:03:56AM +1100, Dave Chinner wrote:
> On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> > On Wed, 6 Feb 2019, Doug Ledford wrote:
> > 
> > > > Most of the cases we want revoke for are things like truncate().
> > > > Shouldn't happen with a sane system, but we're trying to avoid users
> > > > doing awful things like being able to DMA to pages that are now part of
> > > > a different file.
> > >
> > > Why is the solution revoke then?  Is there something besides truncate
> > > that we have to worry about?  I ask because EBUSY is not currently
> > > listed as a return value of truncate, so extending the API to include
> > > EBUSY to mean "this file has pinned pages that can not be freed" is not
> > > (or should not be) totally out of the question.
> > >
> > > Admittedly, I'm coming in late to this conversation, but did I miss the
> > > portion where that alternative was ruled out?
> > 
> > Coming in late here too but isnt the only DAX case that we are concerned
> > about where there was an mmap with the O_DAX option to do direct write
> > though? If we only allow this use case then we may not have to worry about
> > long term GUP because DAX mapped files will stay in the physical location
> > regardless.
> 
> No, that is not guaranteed. Soon as we have reflink support on XFS,
> writes will physically move the data to a new physical location.
> This is non-negotiatiable, and cannot be blocked forever by a gup
> pin.
> 
> IOWs, DAX on RDMA requires a) page fault capable hardware so that
> the filesystem can move data physically on write access, and b)
> revokable file leases so that the filesystem can kick userspace out
> of the way when it needs to.

Why do we need both? You want to have leases for normal CPU mmaps too?

> Truncate is a red herring. It's definitely a case for revokable
> leases, but it's the rare case rather than the one we actually care
> about. We really care about making copy-on-write capable filesystems like
> XFS work with DAX (we've got people asking for it to be supported
> yesterday!), and that means DAX+RDMA needs to work with storage that
> can change physical location at any time.

Then we must continue to ban longterm pin with DAX..

Nobody is going to want to deploy a system where revoke can happen at
any time and if you don't respond fast enough your system either locks
with some kind of FS meltdown or your process gets SIGKILL. 

I don't really see a reason to invest so much design work into
something that isn't production worthy.

It *almost* made sense with ftruncate, because you could architect to
avoid ftruncate.. But just any FS op might reallocate? Naw.

Dave, you said the FS is responsible to arbitrate access to the
physical pages..

Is it possible to have a filesystem for DAX that is more suited to
this environment? Ie designed to not require block reallocation (no
COW, no reflinks, different approach to ftruncate, etc)

> And that's the real problem we need to solve here. RDMA has no trust
> model other than "I'm userspace, I pinned you, trust me!". That's
> not good enough for FS-DAX+RDMA....

It is baked into the silicon, and I don't see much motion on this
front right now. My best hope is that IOMMU PASID will get widely
deployed and RDMA silicon will arrive that can use it. Seems to be
years away, if at all.

At least we have one chip design that can work in a page faulting mode
..

Jason

