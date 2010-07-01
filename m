Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3551F6B01D3
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 18:15:29 -0400 (EDT)
Received: by gxk4 with SMTP id 4so438808gxk.14
        for <linux-mm@kvack.org>; Thu, 01 Jul 2010 15:15:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1278013320.7738.19.camel@c-dwalke-linux.qualcomm.com>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org>
	<1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org>
	<20100701101746.3810cc3b.randy.dunlap@oracle.com>
	<20100701180241.GA3594@basil.fritz.box>
	<1278012503.7738.17.camel@c-dwalke-linux.qualcomm.com>
	<20100701193850.GB3594@basil.fritz.box>
	<1278013320.7738.19.camel@c-dwalke-linux.qualcomm.com>
Date: Thu, 1 Jul 2010 17:15:27 -0500
Message-ID: <AANLkTinABCSdN6hnXVOvVZ12f1QBMR_UAi62qW8GmlkL@mail.gmail.com>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
From: Hari Kanigeri <hari.kanigeri@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Daniel Walker <dwalker@codeaurora.org>, Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: Andi Kleen <andi@firstfloor.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

>
> He demonstrated the usage of his code in one of the emails he sent out
> initially. Did you go over that, and what (or how many) step would you
> use with the current code to do the same thing?

-- So is this patch set adding layers and abstractions to help the User ?

If the idea is to share some memory across multiple devices, I guess
you can achieve the same by calling the map function provided by iommu
module and sharing the mapped address to the 10's or 100's of devices
to access the buffers. You would only need a dedicated virtual pool
per IOMMU device to manage its virtual memory allocations.

Hari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
