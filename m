Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAHMgfAD128098
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 17:42:41 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAHMgfQC158954
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 15:42:41 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iAHMgfI4029908
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 15:42:41 -0700
Subject: Re: [Lhms-devel] [RFC] fix for hot-add enabled SRAT/BIOS and numa
	KVA areas
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20041117133315.92B7.YGOTO@us.fujitsu.com>
References: <1100659057.26335.125.camel@knk>
	 <20041117133315.92B7.YGOTO@us.fujitsu.com>
Content-Type: text/plain
Message-Id: <1100731354.12373.224.camel@localhost>
Mime-Version: 1.0
Date: Wed, 17 Nov 2004 14:42:34 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: keith <kmannth@us.ibm.com>, external hotplug mem list <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-11-17 at 14:33, Yasunori Goto wrote:
> But e820 probably indicates just memory areas which 
> are already connected on the board, right?

It's more than that.  It indicates which were connected the first time
that the machine was powered on.  If you suspend or hibernate the system
for some reason, it has to always present the e820 as it initially
appeared.  

> BTW, I have a question.
>   - Can x445 be attached memory without removing the node?
>     In my concern machine, there is no physical space to
>     hot add or exchange memory without physical removing
>     the node. But, this SRAT table indicate that
>     all of proximity is 0x01....
>     Or is it just logical attachment?

You can't remove nodes, just DIMMs.  The x440 hotplug is more like the
SMP case that I've always been concerned with.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
