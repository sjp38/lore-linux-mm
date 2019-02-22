Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE669C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 13:49:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66D5720665
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 13:49:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66D5720665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFC8E8E0107; Fri, 22 Feb 2019 08:49:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAE108E0105; Fri, 22 Feb 2019 08:49:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9BCC8E0107; Fri, 22 Feb 2019 08:49:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id AAD448E0105
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 08:49:16 -0500 (EST)
Received: by mail-ua1-f69.google.com with SMTP id z11so635360uao.9
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 05:49:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=cn5fRNlUwovtOwgP8qT+hOXDksTbW3bQXSFgIciwB1U=;
        b=phNmqOZcouLTfiZG0iQKccqW4VKNSXMmHbOij4elZRXpxZzM09EAiocAGs9DcJriyB
         yi2rJ8SaFZktWatg/fFmJ1g80rTS/64/l0zgU21hkLEPAPFVKk+mJQfXWOeCORzh9CeG
         Ai+EQb7BpbLYUZ8eSvanedzgFflcoKTfQ4Kbc6WlyX8wzq7vDTEfhq7tmOYpxrDk7/eT
         BOvcWobADTCDAME6ZICL5Ac4Bb5aZ7SVXlQS3KtY9xfIECk8hyh8AcH2xCVxEBcYSxTb
         5TOKc8Cs5D6v0SIVw1YBvk80TBfo94hbvNHNUmFM4pBqvumt0apYstSMgEUB9p+rnbY0
         uhTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuZc8e6fDeRnyRLCyqEnTUl3ijIJfpAtyUOpKzXIADBsk1inkk4S
	ygrnoPXBI8rK7SsBRKoPldS9qjF54YXZx1DZa3FrxO2D4s1tlaLJdE9PnAW0d0Uf4MNodJyIsAt
	0jSMKeO/RwRg0cqlauJIjNY+anHFBPAAZ6Wf0A0Y1nPce/Kbe24f/IPEdyJmrhd+vsQ==
X-Received: by 2002:a1f:df84:: with SMTP id w126mr2157859vkg.54.1550843356318;
        Fri, 22 Feb 2019 05:49:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaCtp6IB1Q/lBivmGdzuHI+oAYb2g5dVxwI9L6eUChktgUPX0fRvdIHMV9Z1mRfA+2zXAnM
X-Received: by 2002:a1f:df84:: with SMTP id w126mr2157815vkg.54.1550843355157;
        Fri, 22 Feb 2019 05:49:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550843355; cv=none;
        d=google.com; s=arc-20160816;
        b=TarLb9p6VhZ8ZsBYDt1L+25RvJG10sXM8Yu+P7nciewhntJ603oD0G+lEWNcslPpJ+
         9rA3AbofROo02PbMxReLEUvJ4N5S8F3xffEB2cMgY4iCbSzYsrQ6k2e/+DKKTuWzo5B0
         GIvTigKaeEhDB2BGPiH2n1tW1yc/hiScjMp6xx52X03nCJ2RxYJi5baj/fNgeOeQmAG1
         hAb+p6QW9qRLy/A28WTVgLDqw+xC/xbJulMNCiKm14jxIpUz7DirutMvoUkvXyyGThqN
         xzbR22Wje/Q/2sWhXHocmydS1TzKd/p6blH/LBUDNyYNisGqJeIU1GOh/lLuhhk7VImS
         0oJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=cn5fRNlUwovtOwgP8qT+hOXDksTbW3bQXSFgIciwB1U=;
        b=yGub/SAFGEj9dPST9tmB7XQmsIlLI0U+GJYC0jqylX0am0OguVVVdGhaSfAzrtrsI/
         oj4nhR3BMAAiJaCco9IQsebJ5//b8rkvdRP8GljztUVKMcrfhgu9VOy9gjvXbunOLpOb
         rS+nvlpZNk7qRBjOU78El/wfFKEnv5EPLnLPQzLJr3xjvCzVanEmYW9cdaZ25QozLXd3
         uHJJmGb4QLMc1SpxbELYK7Pqn3w44qeVbnSErF3jJO9scRnQrkSzS87O7wMjFrfCGxYL
         tfGWhqY/p7teHlrXWt9cHOv5bjn13tlXyZqnHjtG90Oll1n97tHfRnmy1fHu1OTmY/0E
         cDYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id n5si271792vsp.264.2019.02.22.05.49.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 05:49:15 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 57B29FA2F21DE5B50E3F;
	Fri, 22 Feb 2019 21:49:09 +0800 (CST)
Received: from localhost (10.47.85.38) by DGGEMS407-HUB.china.huawei.com
 (10.3.19.207) with Microsoft SMTP Server id 14.3.408.0; Fri, 22 Feb 2019
 21:49:06 +0800
Date: Fri, 22 Feb 2019 13:48:54 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Christopher Lameter <cl@linux.com>
CC: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Michal Hocko
	<mhocko@kernel.org>, <lsf-pc@lists.linux-foundation.org>,
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	<linux-nvme@lists.infradead.org>
Subject: Re: [LSF/MM ATTEND ] memory reclaim with NUMA rebalancing
Message-ID: <20190222134854.000039f7@huawei.com>
In-Reply-To: <01000168c431dbc5-65c68c0c-e853-4dda-9eef-8a9346834e59-000000@email.amazonses.com>
References: <20190130174847.GD18811@dhcp22.suse.cz>
	<87h8dpnwxg.fsf@linux.ibm.com>
	<01000168c431dbc5-65c68c0c-e853-4dda-9eef-8a9346834e59-000000@email.amazonses.com>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.47.85.38]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2019 19:03:48 +0000
Christopher Lameter <cl@linux.com> wrote:

> On Thu, 31 Jan 2019, Aneesh Kumar K.V wrote:
> 
> > I would be interested in this topic too. I would like to
> > understand the API and how it can help exploit the different type of
> > devices we have on OpenCAPI.  

I'll second this from CCIX as well ;)  We get more crazy with topologies than
even OpenCAPI but thankfully it'll probably be a little while before full plug
in and play topology building occurs, so we have time to get this right.

> 
> So am I. We may want to rethink the whole NUMA API and the way we handle
> different types of memory with their divergent performance
> characteristics.
> 
> We need some way to allow a better selection of memory from the kernel
> without creating too much complexity. We have new characteristics to
> cover:
> 
> 1. Persistence (NVRAM) or generally a storage device that allows access to
>    the medium via a RAM like interface.

We definitely have this one, with all the usecases that turn up anywhere
including importantly the cheap extremely large ram option.

> 
> 2. Coprocessor memory that can be shuffled back and forth to a device
>    (HMM).

I'm not sure how this applies to fully coherent device memory.  In those
cases you 'might' want to shuffle the memory to the device, but it is
incredibly usecase dependent on whether that makes more sense than
simply relying on your coherent caches at the device to deal with it.

One key thing here is access to the information on who is using
the memory.  NUMA balancing is fine, but often much finer, or more
long term statistical data info is needed.  So basically similar
to the hot page tracking work, but with tracking of 'who' accessed
it (needs hardware support to avoid the cost of current NUMA
balancing?)

Performance measurement units can help with this where present, but we
need a means to poke that information into what ever is handling placement
/migration decisions.
(I do like the user space aspect of the Intel hot page migration patch
as it lets us play a lot more in this area - particularly prior to any
standards being defined.)

For us (allowing for hardware tracking of ATCs) etc the recent
migration of hot / cold pages set in and out of NVDIMMs only covers
the simplest of cases (expansion memory) where the topology if really
straight forward. It's a good step, but perhaps only a first one...

> 
> 3. On Device memory (important since PCIe limitations are currently a
>    problem and Intel is stuck on PCIe3 and devices start to bypass the
>    processor to gain performance)

Whilst it's not so bad on CCIX or our platforms in general, PCIe 5.0+ is
still some way off and I'm sure there are already applications that
are bandwidth limited at 64GBit/S.  However, having said that, we are
interested in peer 2 peer migration of memory between devices
(probably all still coherent but in theory doesn't have to be).
Once we get complex accelerator interactions on large Fabrics, knowing
what to do here gets really tricky.  You can do some of this with aware
user space code and current NUMA interfaces.  There are also fun side
decisions such as where to put your pagetables in such a system as
the walker and the translation user may not be anywhere near each other
or anywhere near the memory being used.

> 
> 4. High Density RAM (GDDR f.e.) with different caching behavior
>    and/or different cacheline sizes.

That is an interesting one, particularly when we have caches out
in the interconnect. Gets really interesting if those caches are
shared by multiple memories and you may or may not have partitioning +
really complex cache implementations and hardware trickery.

Basically it's more memory heterogeneity, just wrt to caches in the
path.

> 
> 5. Modifying access characteristics by reserving slice of a cache (f.e.
>    L3) for a specific memory region.

A possible complexity, as is reservations for particular process groups.

> 
> 6. SRAM support (high speed memory on the processor itself or by using
>    the processor cache to persist a cacheline)
> 
> And then the old NUMA stuff where only the latency to memory varies. But
> that was a particular solution targeted at scaling SMP system through
> interconnects. This was a mostly symmetric approach. The use of
> accellerators etc etc and the above characteristics lead to more complex
> assymmetric memory approaches that may be difficult to manage and use from
> kernel space.
> 

Agreed entirely on this last point.  This stuff is getting really complex,
and people have an annoying habit of just expecting it to work well.  Moving
the burden of memory placement to user space (with enough description
of the hardware for it to make a good decision) seems a good idea to me.

This is particularly true whilst some of the hardware design decisions
are still up in the air.  Clearly there are aspects that we want to 'just
work' that make sense in kernel, but how do we ensure we have enough hooks
to allow smart userspace code to make the decisions without having to work
around the the in kernel management?

It's worth noting the hardware people are often open to suggestions for what
info software will actually used.  Some of the complexity of that decision
space could definitely be reduced if we get some agreement on what the kernel
needs to know, so we can push for hardware that can self describe.
There are also cases where specifications wait on the kernel community coming to
some consensus so to ensure the hardware matches the requirements.

It is also worth noting that the kernel community has various paths (including
some on this list) to feedback into the firmware specifications etc.  If
there are things the kernel needs to magically know, then we propose
changes at all levels: Hardware specs, firmware, (kernel obviously), user space.

It has been raised before in a number of related threads, but it is worth
keeping in mind the questions:

1) How much effort will userspace put into using any controls we give it?
   HPC people might well, but their platforms tend to be repeated a lot,
   so they will sometimes take the time to hand tune to a particular hardware
   configuration.

2) Does the 'normal' user need this complexity soon?  We need to make sure
   things work well with defaults, if this heterogeneous hardware starts
   turning up in highly varied configurations in workstations / servers.

While I'm highly interested in this area, I'm not an mm specialist. I want
solutions, but I'm sure most of the ideas I have are crazy ;)  Seeing the
hardware coming down the line, crazy may be needed.

Jonathan

