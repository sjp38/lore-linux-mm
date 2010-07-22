Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C42746B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 00:48:23 -0400 (EDT)
Date: Thu, 22 Jul 2010 13:47:36 +0900
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20100722035026.GB14176@codeaurora.org>
References: <20100713090223.GB20590@n2100.arm.linux.org.uk>
	<20100714105922D.fujita.tomonori@lab.ntt.co.jp>
	<20100722035026.GB14176@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20100722134708I.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: zpfeffer@codeaurora.org
Cc: fujita.tomonori@lab.ntt.co.jp, linux@arm.linux.org.uk, alan@lxorguk.ukuu.org.uk, randy.dunlap@oracle.com, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, joro@8bytes.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010 20:50:26 -0700
Zach Pfeffer <zpfeffer@codeaurora.org> wrote:

> On Wed, Jul 14, 2010 at 10:59:43AM +0900, FUJITA Tomonori wrote:
> > On Tue, 13 Jul 2010 10:02:23 +0100
> > 
> > Zach Pfeffer said this new VCM infrastructure can be useful for
> > video4linux. However, I don't think we need 3,000-lines another
> > abstraction layer to solve video4linux's issue nicely.
> 
> Its only 3000 lines because I haven't converted the code to use
> function pointers.

The main point is adding a new abstraction that don't provide the huge
benefit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
