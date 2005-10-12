Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9CHSZrs027478
	for <linux-mm@kvack.org>; Wed, 12 Oct 2005 13:28:35 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9CHTh8H475446
	for <linux-mm@kvack.org>; Wed, 12 Oct 2005 11:29:43 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9CHTg3Z000789
	for <linux-mm@kvack.org>; Wed, 12 Oct 2005 11:29:43 -0600
Message-ID: <434D47FF.1000602@austin.ibm.com>
Date: Wed, 12 Oct 2005 12:29:35 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 5/8] Fragmentation Avoidance V17: 005_fallback
References: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie> <20051011151246.16178.40148.sendpatchset@skynet.csn.ul.ie> <20051012164353.GA9425@w-mikek2.ibm.com> <Pine.LNX.4.58.0510121806550.9602@skynet>
In-Reply-To: <Pine.LNX.4.58.0510121806550.9602@skynet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: mike kravetz <kravetz@us.ibm.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> In reality, no and it would only happen if a caller had specified both
> __GFP_USER and __GFP_KERNRCLM in the call to alloc_pages() or friends. It
> makes *no* sense for someone to do this, but if they did, an oops would be
> thrown during an interrupt. The alternative is to get rid of this last
> element and put a BUG_ON() check before the spinlock is taken.
> 
> This way, a stupid caller will damage the fragmentation strategy (which is
> bad). The alternative, the kernel will call BUG() (which is bad). The
> question is, which is worse?
> 

If in the future we hypothetically have code that damages the fragmentation 
strategy we want to find it sooner rather than never.  I'd rather some kernels 
BUG() than we have bugs which go unnoticed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
