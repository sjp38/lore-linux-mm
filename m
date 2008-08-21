Date: Wed, 20 Aug 2008 20:08:52 -0700 (PDT)
Message-Id: <20080820.200852.193706487.davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/2] Quicklist is slighly problematic.
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080821021332.GA23397@sgi.com>
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<48AC25E7.4090005@linux-foundation.org>
	<20080821021332.GA23397@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Robin Holt <holt@sgi.com>
Date: Wed, 20 Aug 2008 21:13:32 -0500
Return-Path: <owner-linux-mm@kvack.org>
To: holt@sgi.com
Cc: cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> One problem I see is somebody got rid of the node awareness.  We used
> to not put pages onto a quicklist when they were being released from a
> different node than the cpu is on.  Not sure where that went.  It was
> done because of the trap page problem described here.

NUMA awareness is one of the reasons I keep thinking about dropping
quicklist usage on sparc64.

Using SLAB/SLUB for the page table bits with appropriate constructor
and destructor bits ought to be able to approximate the gains
from avoiding the initialization for cached objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
