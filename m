Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 904756006F7
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 14:02:54 -0400 (EDT)
Date: Thu, 1 Jul 2010 20:02:41 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100701180241.GA3594@basil.fritz.box>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org>
 <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org>
 <20100701101746.3810cc3b.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100701101746.3810cc3b.randy.dunlap@oracle.com>
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Zach Pfeffer <zpfeffer@codeaurora.org>, mel@csn.ul.ie, andi@firstfloor.org, dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

> What license (name/type) is this?

IANAL, but AFAIK standard wisdom is that "disclaimer in the documentation
and/or other materials provided" is generally not acceptable for Linux
because it's an excessive burden for all distributors.

Also for me it's still quite unclear why we would want this code at all...
It doesn't seem to do anything you couldn't do with the existing interfaces.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
