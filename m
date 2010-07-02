Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B783D6B01B6
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 03:00:42 -0400 (EDT)
Date: Fri, 2 Jul 2010 16:00:01 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC 1/3] mm: iommu: An API to unify IOMMU, CPU and device memory management
Message-ID: <20100702070001.GA25679@linux-sh.org>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <20100630164058.aa6aa3a2.randy.dunlap@oracle.com> <4C2C40C2.50106@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C2C40C2.50106@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: Randy Dunlap <randy.dunlap@Oracle.COM>, mel@csn.ul.ie, andi@firstfloor.org, dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 01, 2010 at 12:16:18AM -0700, Zach Pfeffer wrote:
> Thank you for the corrections. I'm correcting them now. Some responses:
> 
> Randy Dunlap wrote:
> >> +    struct vcm *vcm_create(size_t start_addr, size_t len);
> > 
> > Seems odd to use size_t for start_addr.
> 
> I used size_t because I wanted to allow the start_addr the same range
> as len. Is there a better type to use? I see 'unsigned long' used
> throughout the mm code. Perhaps that's better for both the start_addr
> and len.
> 
phys_addr_t or resource_size_t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
