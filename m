Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2006C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:49:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8053321773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:49:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8053321773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E22908E0016; Tue, 12 Feb 2019 03:49:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA8B78E0011; Tue, 12 Feb 2019 03:49:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C72A98E0016; Tue, 12 Feb 2019 03:49:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 98C4B8E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:49:25 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id v199so760316vsc.21
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 00:49:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=LtRRWFVm+oQ3i7IAQxflrpeG6M0+4OA1KFTwJbKv1B0=;
        b=MQUR4zseUb3ZMt0fRbqZ3D3PlLABoPeMxJQ/kZaddFOcPQ8MsaxrcRNppwTvMJ1RZu
         fi7gsYZSYjMvAIYEMDKr0rFTVEndiPCwTA+GjCGrzzlJFaczVaRWuFSMtPUDX7YSRqg0
         iy/PXFE2w2i64IVaewEmFucmJ2scrxywKRzqMll2ISxGdH15/8wKjyXQ1Tle9GbNIO/4
         vLzM/cRRBRfBPm7rgdnv0t5uw/mHiWyqebng90HToWQ9mJM6N/TOB7e9y/Jvf+NNsnhy
         Pi0PU++v0KZhiA6ks3yFPttcNSgamKqCPw/jw+PV0fnunbQc4wpgfRzDtdJVrJOkkqok
         UArQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAubW+JpfkojOBotZBQpA8ox8cIfCy6P2TbtNrV/R/RWW5kijiN50
	PG9ocayRSBWc6w2h/DxsAgzqmfQVsT18R1/bNURKI/PyKlzneqA+P5/GcOLusF1bsmjMK7hkBIn
	UX1ReSk0SdI88DfZuigF1hRGqcYVgifKDWdKQw/wU1Lkg9BU1FIhywJ1DtnB0XAaT8w==
X-Received: by 2002:a67:858c:: with SMTP id h134mr1054051vsd.109.1549961365288;
        Tue, 12 Feb 2019 00:49:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZTEG1c3cmpjKzBqnxaH/lZ/amBN514/+ZioRcJHlQUQ9ulT/YxE+UxXAAOcEb5c8DrhJqv
X-Received: by 2002:a67:858c:: with SMTP id h134mr1054033vsd.109.1549961364413;
        Tue, 12 Feb 2019 00:49:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549961364; cv=none;
        d=google.com; s=arc-20160816;
        b=LijyQ8vOCWqQAYcIixFQLmGDrn7b1SpKmT4ecfU9fZnd/v++JYeLT7WPgH3jq/nE4B
         TEL1R+AzEmCKZp9/Hf5FAPvLKlLluqSibhdU4L+Ml7Toxaiarr3MPZ87SBgyEpafCGxs
         RZqtgpb8kY/tYgFU254uGiJEvtNRiIYP/uaoqaVBZUkBNxLCkmzn7LEHQl6y1ZbcJjLd
         gmAOAqWlfwbFFDvxFro/mfSTyYhoZbgCmHHupMejYwRBfzQ7Q/rDcua6JtuK/3Kzl1KA
         RyZBKno4PleAYQvVn0yn071/rANJrNLDIg3lYT1sxc+9ZcDuix6dy/v81YZKibN4ubvO
         Vejw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=LtRRWFVm+oQ3i7IAQxflrpeG6M0+4OA1KFTwJbKv1B0=;
        b=YjlDzIc7WpM2QH4Jj84WnujQ7PjavG5jDl1LHF2AYnH0M1bRkftddYqMnVwtzDLeKV
         BweYrqv71xyTO+3ahobvDE6LjDD6ehZIHnTO9vyFvpKaQ8zN2rgJlh0ybfFJkFPJ9CzR
         6qTo9GbCBAGT4gNnh8VYiHye2YddJ2guTuqGSNCfxSeLWzBQtleJ7YC9op+xoeCVD8eD
         i1u2R5t7hQMZdwBXIKXhev2/ZDgRsH1mknrvFx1DCnCu9647NksnVqGfXTnL6Hk+8tu9
         Xoo8wNDzKCDRJLd9M6mhnrkssr3jHfhSIKokt6r/Q3WZ+hu8ytPFzqWLIGdCZ0rcQ/fj
         +glg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id e4si2676048vso.136.2019.02.12.00.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 00:49:24 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 088157E31536FC437CC1;
	Tue, 12 Feb 2019 16:49:19 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS408-HUB.china.huawei.com
 (10.3.19.208) with Microsoft SMTP Server id 14.3.408.0; Tue, 12 Feb 2019
 16:49:13 +0800
Date: Tue, 12 Feb 2019 08:49:03 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: Brice Goglin <Brice.Goglin@inria.fr>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org"
	<linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>, Rafael Wysocki
	<rafael@kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Williams, Dan
 J" <dan.j.williams@intel.com>
Subject: Re: [PATCHv4 10/13] node: Add memory caching attributes
Message-ID: <20190212084903.00003ff5@huawei.com>
In-Reply-To: <20190211152303.GA4525@localhost.localdomain>
References: <20190116175804.30196-1-keith.busch@intel.com>
	<20190116175804.30196-11-keith.busch@intel.com>
	<4a7d1c0c-c269-d7b2-11cb-88ad62b70a06@inria.fr>
	<20190210171958.00003ab2@huawei.com>
	<20190211152303.GA4525@localhost.localdomain>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019 08:23:04 -0700
Keith Busch <keith.busch@intel.com> wrote:

> On Sun, Feb 10, 2019 at 09:19:58AM -0800, Jonathan Cameron wrote:
> > On Sat, 9 Feb 2019 09:20:53 +0100
> > Brice Goglin <Brice.Goglin@inria.fr> wrote:
> >   
> > > Hello Keith
> > > 
> > > Could we ever have a single side cache in front of two NUMA nodes ? I
> > > don't see a way to find that out in the current implementation. Would we
> > > have an "id" and/or "nodemap" bitmask in the sidecache structure ?  
> > 
> > This is certainly a possible thing for hardware to do.
> >
> > ACPI IIRC doesn't provide any means of representing that - your best
> > option is to represent it as two different entries, one for each of the
> > memory nodes.  Interesting question of whether you would then claim
> > they were half as big each, or the full size.  Of course, there are
> > other possible ways to get this info beyond HMAT, so perhaps the interface
> > should allow it to be exposed if available?  
> 
> HMAT doesn't do this, but I want this interface abstracted enough from
> HMAT to express whatever is necessary.
> 
> The CPU cache is the closest existing exported attributes to this,
> and they provide "shared_cpu_list". To that end, I can export a
> "shared_node_list", though previous reviews strongly disliked multi-value
> sysfs entries. :(
> 
> Would shared-node symlinks capture the need, and more acceptable?

My inclination is that it's better to follow an existing pattern than
invent a new one that breaks people's expectations.

However, don't feel that strongly about it as long as the interface
is functional and intuitive.


>  
> > Also, don't know if it's just me, but calling these sidecaches is
> > downright confusing.  In ACPI at least they are always
> > specifically referred to as Memory Side Caches.
> > I'd argue there should even by a hyphen Memory-Side Caches, the point
> > being that that they are on the memory side of the interconnected
> > rather than the processor side.  Of course an implementation
> > choice might be to put them off to the side (as implied by sidecaches)
> > in some sense, but it's not the only one.
> > 
> > </terminology rant> :)  
> 
> Now that you mention it, I agree "side" is ambiguous.  Maybe call it
> "numa_cache" or "node_cache"?
I'm not sure any of the options work well.  My inclination would be to
use the full name and keep the somewhat redundant memory there.

The other two feel like they could just as easily be coherent caches
at accelerators for example...

memory_side_cache?

The fun of naming ;)

Jonathan

