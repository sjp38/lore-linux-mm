Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E250D6006F7
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 15:38:53 -0400 (EDT)
Date: Thu, 1 Jul 2010 21:38:50 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100701193850.GB3594@basil.fritz.box>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org>
 <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org>
 <20100701101746.3810cc3b.randy.dunlap@oracle.com>
 <20100701180241.GA3594@basil.fritz.box>
 <1278012503.7738.17.camel@c-dwalke-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278012503.7738.17.camel@c-dwalke-linux.qualcomm.com>
Sender: owner-linux-mm@kvack.org
To: Daniel Walker <dwalker@codeaurora.org>
Cc: Andi Kleen <andi@firstfloor.org>, Randy Dunlap <randy.dunlap@oracle.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 01, 2010 at 12:28:23PM -0700, Daniel Walker wrote:
> On Thu, 2010-07-01 at 20:02 +0200, Andi Kleen wrote:
> > > What license (name/type) is this?
> > 
> > IANAL, but AFAIK standard wisdom is that "disclaimer in the documentation
> > and/or other materials provided" is generally not acceptable for Linux
> > because it's an excessive burden for all distributors.
> 
> It's the BSD license ..

It's the old version of the BSD license that noone uses anymore because of its ]
problems: it's really a unreasonable burden to include hundreds or thousands of 
attributions for every contributor in every printed manual you ship.

The BSDs have all switched to the "Clause 2" (without this one) because 
of this.

> 
> > Also for me it's still quite unclear why we would want this code at all...
> > It doesn't seem to do anything you couldn't do with the existing interfaces.
> 
> I don't know all that much about what Zach's done here, but from what
> he's said so far it looks like this help to manage lots of IOMMUs on a
> single system.. On x86 it seems like there's not all that many IOMMUs in
> comparison .. Zach mentioned 10 to 100 IOMMUs ..

The current code can manage multiple IOMMUs fine.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
