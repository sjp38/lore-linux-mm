Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AF97F6B01D4
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 18:51:02 -0400 (EDT)
Received: by gyf1 with SMTP id 1so1719370gyf.14
        for <linux-mm@kvack.org>; Thu, 01 Jul 2010 15:51:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4C2D0FF1.6010206@codeaurora.org>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org>
	<1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org>
	<20100701101746.3810cc3b.randy.dunlap@oracle.com>
	<20100701180241.GA3594@basil.fritz.box>
	<1278012503.7738.17.camel@c-dwalke-linux.qualcomm.com>
	<20100701193850.GB3594@basil.fritz.box>
	<4C2D0FF1.6010206@codeaurora.org>
Date: Thu, 1 Jul 2010 17:51:01 -0500
Message-ID: <AANLkTilQnopqrS-KrR3btOIkH68fIEdipWFF6fkO6fNA@mail.gmail.com>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
From: Hari Kanigeri <hari.kanigeri@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: Andi Kleen <andi@firstfloor.org>, Daniel Walker <dwalker@codeaurora.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

> The VCMM takes the long view. Its designed for a future in which the
> number of IOMMUs will go up and the ways in which these IOMMUs are
> composed will vary from system to system, and may vary at
> runtime. Already, there are ~20 different IOMMU map implementations in
> the kernel. Had the Linux kernel had the VCMM, many of those
> implementations could have leveraged the mapping and topology management
> of a VCMM, while focusing on a few key hardware specific functions (map
> this physical address, program the page table base register).
>

-- Sounds good.
Did you think of a way to handle the cases where one of the Device
that is using the mapped address crashed ?
How is the physical address unbacked in this case ?

Hari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
