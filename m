Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE1C6B0071
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 15:42:10 -0400 (EDT)
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
From: Daniel Walker <dwalker@codeaurora.org>
In-Reply-To: <20100701193850.GB3594@basil.fritz.box>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org>
	 <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org>
	 <20100701101746.3810cc3b.randy.dunlap@oracle.com>
	 <20100701180241.GA3594@basil.fritz.box>
	 <1278012503.7738.17.camel@c-dwalke-linux.qualcomm.com>
	 <20100701193850.GB3594@basil.fritz.box>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 01 Jul 2010 12:42:00 -0700
Message-ID: <1278013320.7738.19.camel@c-dwalke-linux.qualcomm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-01 at 21:38 +0200, Andi Kleen wrote:
> > 
> > > Also for me it's still quite unclear why we would want this code at all...
> > > It doesn't seem to do anything you couldn't do with the existing interfaces.
> > 
> > I don't know all that much about what Zach's done here, but from what
> > he's said so far it looks like this help to manage lots of IOMMUs on a
> > single system.. On x86 it seems like there's not all that many IOMMUs in
> > comparison .. Zach mentioned 10 to 100 IOMMUs ..
> 
> The current code can manage multiple IOMMUs fine.

He demonstrated the usage of his code in one of the emails he sent out
initially. Did you go over that, and what (or how many) step would you
use with the current code to do the same thing?

Daniel

-- 
Sent by a consultant of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
