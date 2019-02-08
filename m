Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E1F2C282CB
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 15:43:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2FBA20863
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 15:43:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="BHrq0QLK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2FBA20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61FF28E0092; Fri,  8 Feb 2019 10:43:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CF3D8E0002; Fri,  8 Feb 2019 10:43:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4736D8E0092; Fri,  8 Feb 2019 10:43:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 00CB38E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 10:42:59 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 3so2896992pfn.16
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 07:42:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ddQxupTFAevHfaAh0hqzJoxLrcUdGB63YejynzV9HiU=;
        b=JUjwzw0SCJZQ7cyTWJvlxQinTmRENlqQJQHJvZuJYumOUsyzCppdFj2Eu+rYML3KCg
         VRnya68Wv9hHlHXujUC4EsDEjctpVmfAvCQh76VeYi/l4/MVeTbTklEIFLGqWJt1xIpc
         kY2iFPA6gLtXvY6lcTd1NftvLlsEW6a/q8mhJr8uwRQ+RarkOSN8cA7NsNcURPqbxopD
         ols5Oqqu8lhX56fEvZ8mDjFu6c8xMSOfPOIlsZ447/HeWPYW7xj9lZqUY5qh03gM8EsT
         Sp8p9t+2nwhgKfBa7BQSC6wV8J208UiDc0rHORTzA89/c/I74rl7D++0kWoWFoxtw/OK
         vahw==
X-Gm-Message-State: AHQUAuYbtgp55dhasm8P15H9tjvcOjjf4Jm2I8AfkQVmuh6gvMaMVxzX
	F0Xvjo79n/R3KI9I8CwIM8c9ZWItN8oSMVemZAJsd3FLnH3kNDcCblxQcuL9rz/iSQdWtqwjUb9
	BYsCBzICoAwus6kdQGjowtOSC6/QGaTM3A2sHMQP3gzdwGwYR0L4prsNdU0bmpX9fLvV5ksarIs
	vbI9EdHrWEuW7lLy//UmR/48rwk2dSwOlOoL1sPeZeWV0OuD/5CYlDRS7SmpTZtJfr346S5m8w5
	NsdEqL9etM40k7/R1E0Blsckx6SBlcCsERt8yYj6sJyBj/H3MtyCMEsGgUbGpLMAA42hh3azWhc
	3QsbCCrQpkVvZtUiHVWZKuvLocuRjyY+lJ6Nnj04xXUdXmfLlCwDPClh/v3eVLPXGotfGqiteY2
	p
X-Received: by 2002:a65:628e:: with SMTP id f14mr4001538pgv.193.1549640579606;
        Fri, 08 Feb 2019 07:42:59 -0800 (PST)
X-Received: by 2002:a65:628e:: with SMTP id f14mr4001490pgv.193.1549640578708;
        Fri, 08 Feb 2019 07:42:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549640578; cv=none;
        d=google.com; s=arc-20160816;
        b=qEQKO9cu9hAPTXBAhKhhu5ahlVLO/pQ7A5NAAM3BNBD4uf5xYGsdrqK/Q8/m1GLZ3E
         ZWeDy9fo0846SDeZJJTOcA3Yyk4zO6v4fphaIqrsoKR7/GIAIQsA/j2eWgmh25BV8J2F
         DP+ayCqyjMSPhZWxRLkaac2W0CqA4VdsS/o1B5LhsyP1ovdomVa6M06HdiNs2xh4ftU6
         BQo728TM6+OI0kfJpDLASLyilZo5ms7mYKZQxMB+/2z/O3cUol3zk17+bbB0ak8kHzHI
         +jI6Zr8QD6zc/lxOA+fCUpds659GIQOvWzmerDTtoCGWo+7WWeJR+P+r+0KbL5E6oEKT
         c8hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ddQxupTFAevHfaAh0hqzJoxLrcUdGB63YejynzV9HiU=;
        b=t9z2OmV5jzp5W7FYmjc4DSkhnaVyHN33MagWuXkxdzWf1VXmYhhnYSoGQgiMy9nIAH
         y8LT6L68WqZinXbWHXrVcLt2KQ7vSd2K4PwNjOkDyekP7eJzCClI+rdFfVqFpCKmKdIq
         zpu8UHF/83L0ypEwGvQEKvP82xwPfYbO2dloxVEc6JQFe5RnUsYBU+WUQy2kkHqB/Ind
         FF3AFBXY+buVCU4W3mhxPcTpZBpAgpQDe81SdYIRTjaFe7i3HWe8XSusOHtEel+p1cez
         RvbpNYLtgLj9DvwIItdOAAu5q/EnypbZkLd1COU7gDVDKkzogNUQvsQS7Quch60At98m
         +LFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=BHrq0QLK;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor3362451pgv.77.2019.02.08.07.42.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Feb 2019 07:42:58 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=BHrq0QLK;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ddQxupTFAevHfaAh0hqzJoxLrcUdGB63YejynzV9HiU=;
        b=BHrq0QLKY5n1Y5aDZ7iMo33tOtA3g2Vi7KZ7uZdzJH13IN2HrjwFaOgsgSrE61NBaq
         oobQPmZ9NmuDgcQAZ8+Gr056X53wyKf6IsgNzu/1L/4ds3UBXdpUYp6vboylmxtzYdtW
         p0seYcN4YSQzmY+PJybUbvwlbkA7m3zT6cjGU1HPshw8/xybC55FaVzL4vQHG2jgIUjn
         vRK0mwQVlKUen8TXhuOwa0lD7tl83VA8S4gV6qVMqLYVO7MOTdpHaS5xYWQR94tYzc1x
         wsXLNj9T/cUvWOV/Mk1m7DyoaWLXcisB8lJ7AOnNL+TLXr3ZQVkAYUd+UZrjV0NHbv/r
         bZKg==
X-Google-Smtp-Source: AHgI3IYYNXcBGCuA3MjCFUqgpYJMzmKD2xQN2tI7pDUdvgLeHQRTXlmLbBhdILjWxskz9qKt6jsHAw==
X-Received: by 2002:a63:5723:: with SMTP id l35mr20308156pgb.228.1549640577944;
        Fri, 08 Feb 2019 07:42:57 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id r3sm10383048pgn.48.2019.02.08.07.42.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Feb 2019 07:42:57 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gs8Iq-0006eE-M1; Fri, 08 Feb 2019 08:42:56 -0700
Date: Fri, 8 Feb 2019 08:42:56 -0700
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
Message-ID: <20190208154256.GA25156@ziepe.ca>
References: <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard>
 <20190207052310.GA22726@ziepe.ca>
 <CAPcyv4jd4gxvt3faYYRbv5gkc6NGOKjY_Z-P0Ph=ss=gWZw7sA@mail.gmail.com>
 <20190207171736.GD22726@ziepe.ca>
 <CAPcyv4hsHeCGjcJNEmMg_6FYEsQ_8Z=bvx+WmO1v_LmoXbJrxA@mail.gmail.com>
 <20190208051950.GA4283@ziepe.ca>
 <CAPcyv4jWnkHxBcU2_Pz99wM02RYab4y25hu_qUE8KCVArYxCeg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jWnkHxBcU2_Pz99wM02RYab4y25hu_qUE8KCVArYxCeg@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 11:20:37PM -0800, Dan Williams wrote:
> On Thu, Feb 7, 2019 at 9:19 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > On Thu, Feb 07, 2019 at 03:54:58PM -0800, Dan Williams wrote:
> >
> > > > The only production worthy way is to have the FS be a partner in
> > > > making this work without requiring revoke, so the critical RDMA
> > > > traffic can operate safely.
> > >
> > > ...belies a path forward. Just swap out "FS be a partner" with "system
> > > administrator be a partner". In other words, If the RDMA stack can't
> > > tolerate an MR being disabled then the administrator needs to actively
> > > disable the paths that would trigger it. Turn off reflink, don't
> > > truncate, avoid any future FS feature that might generate unwanted
> > > lease breaks.
> >
> > This is what I suggested already, except with explicit kernel aid, not
> > left as some gordian riddle for the administrator to unravel.
> 
> It's a riddle either way. "Why is my truncate failing?"

At least that riddle errs on the side of system safety and will not be
hit anyhow. Doug is right, we already allow ftruncate to fail with
PROT_EXEC maps (ETXTBUSY) so this isn't even abnormal.

Or do as CL says and succeed the ftruncate but nothing happens (the
continuous write philosophy)

> > You already said it is too hard for expert FS developers to maintain a
> > mode switch
> 
> I do disagree with a truncate behavior switch, but reflink already has
> a mkfs switch so it's obviously possible for any future feature that
> might run afoul of the RDMA restrictions to have fs-feature control.

More precedent that this is the right path..

> > It makes much more sense for the admin to flip some kind of bit and
> > the FS guarentees the safety that you are asking the admin to create.
> 
> Flipping the bit changes the ABI contract in backwards incompatible
> ways. I'm saying go the other way, audit the configuration for legacy
> RDMA safety.

We have precedent for this too. Lots of FSs don't support hole punch,
reflink or in some rare cases ftruncate. It is not exactly new ground.
 
> > > In any event, this lets end users pick their filesystem
> > > (modulo RDMA incompatible features), provides an enumeration of
> > > lease break sources in the kernel, and opens up FS-DAX to a wider
> > > array of RDMA adapters. In general this is what Linux has
> > > historically done, give end users technology freedom.
> >
> > I think this is not the Linux model. The kernel should not allow
> > unpriv user space to do an operation that could be unsafe.
> 
> There's permission to block unprivileged writes/truncates to a file,
> otherwise I'm missing what hole is being opened? That said, the horse
> already left the barn. Linux has already shipped in the page-cache
> case "punch hole in the middle of a MR succeeds and leaves the state
> of the file relative to ongoing RDMA inconsistent". Now that we know
> about the bug the question is how do we do better than the current
> status quo of taking all of the functionality away.

I've always felt this is a bug in RDMA - but we have no path to fix
it. The best I can say is that it doesn't cause any security or
corruption problem today.

> > I continue to think this is is the best idea that has come up - but
> > only if the filesystem is involved and expressly tells the kernel
> > layers that this combination of DAX & filesystem is safe.
> 
> I think we're getting into "need to discuss at LSF/MM territory",
> because the concept of "DAX safety", or even DAX as an explicit FS
> capability has been a point of contention since day one. We're trying
> change DAX to be defined by mmap API flags like MAP_SYNC and maybe
> MAP_DIRECT in the future.
> 
> For example, if the MR was not established to a MAP_SYNC vma then the
> kernel should be free to indirect the RDMA through the page-cache like
> the typical non-DAX case. DAX as a global setting is too coarse.

Whatever this flag is would be is linked to the mmap, and maybe you
could make it a per-file flag instead of some mount option, I don't
know. Kind of up to the FS.

I'm just advocating for the idea that the FS itself can reject/deny the
longterm pin request based on its internal status.  If the FS meets
the defined contract then it can allow long term to proceed. Otherwise
it fails.

I feel this is what people actually want here, and is a far more
maintainable overall system than some sketchy lease revoke SIGKILL.

Jason

