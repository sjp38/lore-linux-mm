Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A91256B01C6
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 17:00:00 -0400 (EDT)
Date: Thu, 1 Jul 2010 14:59:59 -0600 (MDT)
From: Paul Walmsley <paul@pwsan.com>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
In-Reply-To: <20100701101746.3810cc3b.randy.dunlap@oracle.com>
Message-ID: <alpine.DEB.2.00.1007011450130.13691@utopia.booyaka.com>
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <1277877350-2147-3-git-send-email-zpfeffer@codeaurora.org> <20100701101746.3810cc3b.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Zach Pfeffer <zpfeffer@codeaurora.org>, mel@csn.ul.ie, andi@firstfloor.org, dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Randy,

On Thu, 1 Jul 2010, Randy Dunlap wrote:

> > + * @start_addr	The starting address of the VCM region.
> > + * @len 	The len of the VCM region. This must be at least
> > + *		vcm_min() bytes.
> 
> and missing lots of struct members here.
> If some of them are private, you can use:
> 
> 	/* private: */
> ...
> 	/* public: */
> comments in the struct below and then don't add the private ones to the
> kernel-doc notation above.

To avoid wasting space in structures, it makes sense to place fields 
smaller than the alignment width together in the structure definition.  
If one were to do this and follow your proposal, some structures may need 
multiple "private" and "public" comments, which seems undesirable.  The 
alternative, wasting memory, also seems undesirable.  Perhaps you might 
have a proposal for a way to resolve this?


- Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
