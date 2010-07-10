Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B058E6B024D
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 10:56:41 -0400 (EDT)
Date: Sat, 10 Jul 2010 16:56:39 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100710145639.GC10080@8bytes.org>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org> <20100701101746.3810cc3b.randy.dunlap@oracle.com> <20100701180241.GA3594@basil.fritz.box> <1278021944.7738.43.camel@c-dwalke-linux.qualcomm.com> <4C2D965F.5000206@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C2D965F.5000206@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: Daniel Walker <dwalker@codeaurora.org>, Andi Kleen <andi@firstfloor.org>, Randy Dunlap <randy.dunlap@oracle.com>, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 02, 2010 at 12:33:51AM -0700, Zach Pfeffer wrote:
> Daniel Walker wrote:

> > So if we include this code which "map implementations" could you
> > collapse into this implementations ? Generally , what currently existing
> > code can VCMM help to eliminate?
> 
> In theory, it can eliminate all code the interoperates between IOMMU,
> CPU and non-IOMMU based devices and all the mapping code, alignment,
> mapping attribute and special block size support that's been
> implemented.

Thats a very abstract statement. Can you point to particular code files
and give a rough sketch how it could be improved using VCMM?

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
