Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86B0CC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:30:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C76E218B0
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:30:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C76E218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D34D98E00DA; Wed,  6 Feb 2019 12:30:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE3398E00D9; Wed,  6 Feb 2019 12:30:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD3FD8E00DA; Wed,  6 Feb 2019 12:30:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0228E00D9
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 12:30:52 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id z189so3119929vsc.16
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 09:30:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=GCtai/em14hjePYVVW7GMlAbDQUy6x/CDDg1jcvPuJE=;
        b=ryNJ1iZ5baVzt4V/6LS9NNb8sYIY8URMLwsbu1yzX+qRKg//v2idbVwjhoDpW/xznm
         qFxDZ2tpRkq61NCNC4PUPoPtUAUQDqBb/rcGv2oACRo6yPFPKUNuHyvjMUFI3Af3gUSs
         7Rm6feALRRpDQcLdUb34shGb+kQUKXSbZKir03yMTcUHLYxZA0Ni8xW62LqU0ZC11R8R
         8qzzTk2aaXQmTaG/LGGNE4Dl0oTFekP0nEvurzBX9ZXcwtl4cIMnfN5lJnJfQ89Bf42W
         83Ee1GRnOacKZLJa/juf2J0DzeYWQy+pgNLopPN+vEd9XuOq8iqD6oA4N1iddZtZkxRR
         3nBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuadOY53adOwzsWH+8I34o+rmcuRwfCvL48Yd85oRicVgYeW/VtB
	e+E54M0zUDSNIeZ7yrCmnzhZ/LJFkpRH4HaOG9ThjpF2UGQT46Rt5LEX3t78Q/h06YKcXMK1OWK
	2TemMaXcKILcWPfnvgUu3zYbqoyeG4KQAursXLLu/sdkpZoFEOrlrlzTg5n20OQNeCA==
X-Received: by 2002:a67:7106:: with SMTP id m6mr5067731vsc.67.1549474252300;
        Wed, 06 Feb 2019 09:30:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJkKq8q1EvMK2L6zM2jSCdtFERPTNzrvUPfdyJdCmdOsjCVLe1DAlQPnF+wtfiRbA7Wozt
X-Received: by 2002:a67:7106:: with SMTP id m6mr5067700vsc.67.1549474251423;
        Wed, 06 Feb 2019 09:30:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549474251; cv=none;
        d=google.com; s=arc-20160816;
        b=RMt6nIkEKwuEkE4ZvfOl4XBIQVyWIs5aPPZApeet5JHtVAHC9kHVTpqGJAMwkZl61v
         99TgR5r9pIwVBrBYoe9wfJk2WhIoMlBCdn77ZP7WcCTc3fODpXJOBjq8WJunjJTH8AOA
         FtP2wUzDQS174xUPMWK+37EXpg4ihp+8PNOAqvCI6sa4b55yA0klT4xw8uHbVe+zQIuS
         qbpK09kVfQxuPvNa1BxD+sDyQ/o+3I/jR/j6QoSgsCMWC/aou5X4BTmsORii7rFZzUbW
         Myo3alZPv4N7ihsRoFirLVZQmVLldnJvrqgLo7kBuT9+GK1a1pKo6lg9X7C0615KRfQc
         MG8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=GCtai/em14hjePYVVW7GMlAbDQUy6x/CDDg1jcvPuJE=;
        b=hTAkH4jRHK8WHy3JSJAcP/wr09ajsOSjjgUSOOxT0jibK9X/57l7NiZ/wsIH5oK8p+
         KohCtwK2wvg4VM5JevcS7dsL9Hl2XWSdF8JUtuNAJXycPSeaRjtRHS5iWdUDJZEO5AD5
         x/Cp5Fbnc4apBmC1V5fVDJmSCESevCbi4NGfs+sxtGi5Y7lnFqjGe6kuSRclqu+Yr3v+
         /GEvFIZeXkO8nfyHuP7iFORiqij22eAJlPNcR3Qt2Sj3xC1CgaY2n6VrWAp8p1CwY9eK
         yOR25Z4MxNHzdkGwTwhTQUcDe8xGYHLpACP+hcqpZoqMBVGAaM4IcYQnYuEBgfK61BMA
         LsoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id q11si5060831vsc.45.2019.02.06.09.30.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 09:30:51 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS404-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id B25B56B7394A149B462B;
	Thu,  7 Feb 2019 01:30:47 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS404-HUB.china.huawei.com
 (10.3.19.204) with Microsoft SMTP Server id 14.3.408.0; Thu, 7 Feb 2019
 01:30:37 +0800
Date: Wed, 6 Feb 2019 17:30:27 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>, <linuxarm@huawei.com>
Subject: Re: [PATCHv5 00/10] Heterogeneuos memory node attributes
Message-ID: <20190206173027.0000195c@huawei.com>
In-Reply-To: <20190206171935.GJ28064@localhost.localdomain>
References: <20190124230724.10022-1-keith.busch@intel.com>
	<20190206123100.0000094a@huawei.com>
	<20190206171935.GJ28064@localhost.localdomain>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
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

On Wed, 6 Feb 2019 10:19:37 -0700
Keith Busch <keith.busch@intel.com> wrote:

> On Wed, Feb 06, 2019 at 12:31:00PM +0000, Jonathan Cameron wrote:
> > On Thu, 24 Jan 2019 16:07:14 -0700
> > Keith Busch <keith.busch@intel.com> wrote:
> > 
> > 1) It seems this version added a hard dependence on having the memory node
> >    listed in the Memory Proximity Domain attribute structures.  I'm not 100%
> >    sure there is actually any requirement to have those structures. If you aren't
> >    using the hint bit, they don't convey any information.  It could be argued
> >    that they provide info on what is found in the other hmat entries, but there
> >    is little purpose as those entries are explicit in what the provide.
> >    (Given I didn't have any of these structures and things  worked fine with
> >     v4 it seems this is a new check).  
> 
> Right, v4 just used the node(s) with the highest performance. You mentioned
> systems having nodes with different performance, but no winner across all
> attributes, so there's no clear way to rank these for access class linkage.
> Requiring an initiator PXM present clears that up.
> 
> Maybe we can fallback to performance if the initiator pxm isn't provided,
> but the ranking is going to require an arbitrary decision, like prioritize
> latency over bandwidth.

I'd certainly prefer to see that fall back and would argue it is
the only valid route.  What is 'best' if we don't put a preference on
one parameter over the other.

Perfectly fine to have another access class that does bandwidth preferred
if that is of sufficient use to people.

>  
> >    This is also somewhat inconsistent.
> >    a) If a given entry isn't there, we still get for example
> >       node4/access0/initiators/[read|write]_* but all values are 0.
> >       If we want to do the check you have it needs to not create the files in
> >       this case.  Whilst they have no meaning as there are no initiators, it
> >       is inconsistent to my mind.
> > 
> >    b) Having one "Memory Proximity Domain attribute structure" for node 4 linking
> >       it to node0 is sufficient to allow
> >       node4/access0/initiators/node0
> >       node4/access0/initiators/node1
> >       node4/access0/initiators/node2
> >       node4/access0/initiators/node3
> >       I think if we are going to enforce the presence of that structure then only
> >       the node0 link should exist.  
> 
> We'd link the initiator pxm in the Address Range Structure, and also any
> other nodes with identical performance access. I think that makes sense.

I disagree on this. It is either / or, it seem really illogical to build
all of them if only one initiator is specified for the target.

If someone deliberately only specified one initiator for this target then they
meant to do that (hopefully).  Probably because they wanted to set one
of the flags.

>  
> > 2) Error handling could perhaps do to spit out some nasty warnings.
> >    If we have an entry for nodes that don't exist we shouldn't just fail silently,
> >    that's just one example I managed to trigger with minor table tweaking.
> > 
> > Personally I would just get rid of enforcing anything based on the presence of
> > that structure.  

Thanks,

Jonathan

