Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB089C282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:17:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8011F21916
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:17:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="bF6lvl3O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8011F21916
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA70A8E0051; Thu,  7 Feb 2019 12:17:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2F998E0002; Thu,  7 Feb 2019 12:17:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD1608E0051; Thu,  7 Feb 2019 12:17:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 89C4C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 12:17:41 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q64so359198pfa.18
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 09:17:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PqlMHd6xLDlAcNc8B30K9u3FyPa4y27/C9zdAZrVqEA=;
        b=Ui92sZPErxExr7TlJUZFsj8D3TtE+TMJU34RTgKnMAeRbuJ3jHcl6y8R9hnaC+Z09t
         h98UhNijxNScRpLlfIQmbODsCT7aqnNq1/bT7/7R7PMZHQqxSgv75foTjQ5rF9LsutDA
         6L3ymQa0RdwcZy+KwxSlDi+9nctEEAliJCH306L9VudcfOvsVMikL8dtgyu76j1j+QwH
         y5EGJ31EyWomt5rdBoM6CFYoOaSKdVLC6Gr2X9oJRc8D2BzcRqhE3cLx4PkoNXeUbSN7
         X28OwUYAohTtHmzDXBTbHH3QkkeM/xxTL31HJN9rS3jBvmyWGIpsqrIj/hcsUYv3hQep
         LvDw==
X-Gm-Message-State: AHQUAuYZpJcJ8ipaxEonan2a7WIMMhUVR5hAadlr/FfZ5zVsr4oBqxwR
	neY9M8H6CuGh3Zixmg+HJ2rhO19YbSvm8uOPxv8c/55DAkrCgWYDxPgFU48wU0otoRhzzGDLzS7
	l3H/20TUjU0EhHZ8JJyBbvGc8pn9fn4eAabsoP5555clfObzJRkIXBIsAoaHJ2OrZ+fTYZdpIM+
	cvXSCwdNRm8sN2OybNUUAcVihlQvIMrIAD7s7w5pM4WaJYG51TeZ0HmL0elPR5I/o5NWuaVAZWF
	yioyxm25QUNiKTQ8Bbq/0khWWUpiSv7MfH/EuAuoCq8tZf3zU7yrhzCAIebBSqeT8fAqh0GYMAe
	BRSC/teJkkwqOft/+xB6FE70l2hP3CUJ7ff7jhILwY3y2pVGmsmAP+DJz6WIwXdcgueFoVJXe85
	s
X-Received: by 2002:a63:5962:: with SMTP id j34mr740977pgm.297.1549559861043;
        Thu, 07 Feb 2019 09:17:41 -0800 (PST)
X-Received: by 2002:a63:5962:: with SMTP id j34mr740855pgm.297.1549559859495;
        Thu, 07 Feb 2019 09:17:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549559859; cv=none;
        d=google.com; s=arc-20160816;
        b=xt0ah0Yc3oqKLBVoWTLYiANrpwBWfD0XKn//bTnwP0U3LWEXTLiW8kJA0mptHFb4Zf
         9G+slFdpJgy+KabydEo+CsdS13nJ+8YaTyqLfsk4Jlo2OJEWgmm3lfgw4o09Ir7sKbmh
         2hNSYhGHnPz4iwvGREldM7zcg6Ryba45UYUJPXuEHIA/NrtwtpjnXak++XRq7ozwrFnu
         1Ijcv4enOtc6WtE70xB34xgo6ff1eM53Azb6Pjq7fjG+rYP0E2Qgh3kledkA0gMcCfMI
         UkQCLLbxKmyv66nkJ+M9ya9xhK5Fg/00VlPZlpOF8KxUQp22KWW8jQIgKm1pN+YroL73
         +A2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PqlMHd6xLDlAcNc8B30K9u3FyPa4y27/C9zdAZrVqEA=;
        b=SnJ9L/ax8Y/JFjc/alHgSMCHOo2+MbN5amqFrn/hPW85ZamN5xAihcX/4l+Y/quGhH
         A1GmzY8LQmDWcWMoTPU9TZgGqfJAapvwkcvxRTxlP8oIZiDyMCGo0u3TFNN8/weCBGxe
         r+cYLWIfYha+m+sausH3dQq/C2+XJWuqkaQ8vz5moh0rh0wpqP+33+X24kzDwyux1jRV
         CpEYu0wSl9WKUVRouATw4jkqzPiMkcJOwQCJRIdMKNzpEd5/OG8Nz5Nk7TmJ/ieesi+y
         Yk9d9zv0WykKj+nblT7HsixLwolQUXIzhmqn9DOgwaw9g1vH4hgsf3+bDe7G+/S3MEMB
         XICw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=bF6lvl3O;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a16sor12323905pgw.48.2019.02.07.09.17.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 09:17:39 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=bF6lvl3O;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PqlMHd6xLDlAcNc8B30K9u3FyPa4y27/C9zdAZrVqEA=;
        b=bF6lvl3OIEJ4mNLeHShgdKndstBHIdZ+678WDi7EJO7vLsb/hKdw7Ja0/uy1/lHSDk
         qDpWQH/ReJvGv7F6Vdt0JqCz+89mzCy37JNqoCOYJmMOKZYtGaba6kfrZZw62kadSlf8
         vGO4eYUG5o8fsb0QQCAThBbFzdTjhFeRzRKBfHxpgeptKev92+187E03kgKzrFQJvNxQ
         RyUF0akf8yOM9IinzYaUQmqTAAXHiI50T3P5aGMwG5eQT2qZqoQdlm02Pg0D2GR5AKZP
         KKDNrvdkJr+bwk57YsYtJ/tm+0IfhklIEhX6oXXoKva7a/dOUbc6RX+WUNkA9X/OgQUb
         coeA==
X-Google-Smtp-Source: AHgI3IYr+OpwrNiUTeYSdY/v8ElKyIb+GxbENEW6Q/NCm5CooT4Qqmf9VKbCvH+1cb7V0xRsxI466g==
X-Received: by 2002:a63:6ac5:: with SMTP id f188mr15925675pgc.165.1549559858718;
        Thu, 07 Feb 2019 09:17:38 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id k15sm16852694pfb.147.2019.02.07.09.17.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 09:17:37 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1grnIu-0001lq-SV; Thu, 07 Feb 2019 10:17:36 -0700
Date: Thu, 7 Feb 2019 10:17:36 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Doug Ledford <dledford@redhat.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190207171736.GD22726@ziepe.ca>
References: <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard>
 <20190207052310.GA22726@ziepe.ca>
 <CAPcyv4jd4gxvt3faYYRbv5gkc6NGOKjY_Z-P0Ph=ss=gWZw7sA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jd4gxvt3faYYRbv5gkc6NGOKjY_Z-P0Ph=ss=gWZw7sA@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 10:00:28PM -0800, Dan Williams wrote:

> > > If your argument is that "existing RDMA apps don't have a recall
> > > mechanism" then that's what they are going to need to implement to
> > > work with DAX+RDMA. Reliable remote access arbitration is required
> > > for DAX+RDMA, regardless of what filesysetm the data is hosted on.
> >
> > My argument is that is a toy configuration that no production user
> > would use. It either has the ability to wait for the lease to revoke
> > 'forever' without consequence or the application will be critically
> > de-stablized by the kernel's escalation to time bound the response.
> > (or production systems never get revoke)
> 
> I think we're off track on the need for leases for anything other than
> non-ODP hardware.
> 
> Otherwise this argument seems to be saying there is absolutely no safe
> way to recall a memory registration from hardware, which does not make
> sense because SIGKILL needs to work as a last resort.

SIGKILL destroys all the process's resources. This is supported.

You are asking for some way to do a targeted *disablement* (we can't
do destroy) of a single resource.

There is an optional operation that could do what you want
'rereg_user_mr'- however only 3 out of 17 drivers implement it, one of
those drivers supports ODP, and one is supporting old hardware nearing
its end of life.

Of the two that are left, it looks like you might be able to use
IB_MR_REREG_PD to basically disable the MR. Maybe. The spec for this
API is not as a fence - the application is supposed to quiet traffic
before invoking it. So even if it did work, it may not be synchronous
enough to be safe for DAX.

But lets imagine the one driver where this is relavents gets updated
FW that makes this into a fence..

Then the application's communication would more or less explode in a
very strange and unexpected way, but perhaps it could learn to put the
pieces back together, reconnect and restart from scratch.

So, we could imagine doing something here, but it requires things we
don't have, more standardization, and drivers to implement new
functionality. This is not likely to happen.

Thus any lease mechanism is essentially stuck with SIGKILL as the
escalation.

> > The arguing here is that there is certainly a subset of people that
> > don't want to use ODP. If we tell them a hard 'no' then the
> > conversation is done.
> 
> Again, SIGKILL must work the RDMA target can't survive that, so it's
> not impossible, or are you saying not even SIGKILL can guarantee an
> RDMA registration goes idle? Then I can see that "hard no" having real
> teeth otherwise it's a matter of software.

Resorting to SIGKILL makes this into a toy, no real production user
would operate in that world.

> > I don't like the idea of building toy leases just for this one,
> > arguably baroque, case.
> 
> What makes it a toy and baroque? Outside of RDMA registrations being
> irretrievable I have a gap in my understanding of what makes this
> pointless to even attempt?

Insisting to run RDMA & DAX without ODP and building an elaborate
revoke mechanism to support non-ODP HW is inherently baroque. 

Use the HW that supports ODP.

Since no HW can do disable of a MR, the escalation path is SIGKILL
which makes it a non-production toy.

What you keep missing is that for people doing this - the RDMA is a
critical compoment of the system, you can't just say the kernel will
randomly degrade/kill RDMA processes - that is a 'toy' configuration
that is not production worthy.

Especially since this revoke idea is basically a DOS engine for the
RDMA protocol if another process can do actions to trigger revoke. Now
we have a new class of security problems. (again, screams non
production toy)

The only production worthy way is to have the FS be a partner in
making this work without requiring revoke, so the critical RDMA
traffic can operate safely.

Otherwise we need to stick to ODP.

Jason

