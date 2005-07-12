Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6CJTdeR074724
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 15:29:39 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j6CJTdvb120584
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 13:29:39 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6CJTSU6021244
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 13:29:28 -0600
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low()
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050712183021.GC3987@w-mikek2.ibm.com>
References: <20050712152715.44CD.Y-GOTO@jp.fujitsu.com>
	 <20050712183021.GC3987@w-mikek2.ibm.com>
Content-Type: text/plain
Date: Tue, 12 Jul 2005 12:29:25 -0700
Message-Id: <1121196565.5992.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "Luck, Tony" <tony.luck@intel.com>, ia64 list <linux-ia64@vger.kernel.org>, "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-07-12 at 11:30 -0700, Mike Kravetz wrote:
> FYI - While hacking on the memory hotplug code, I added a special
> '#define MAX_DMA_PHYSADDR' to get around this issue on such architectures.
> Most likely, this isn't elegant enough as a real solution.  But it does
> point out that __pa(MAX_DMA_ADDRESS) doesn't always give you what you
> expect.

Didn't we create a MAX_DMA_PHYSADDR or something, so that people could
do this if they want?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
