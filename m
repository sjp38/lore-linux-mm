Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1SGCb6w020042
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 11:12:37 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1SGCX9m240792
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 11:12:37 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1SGCXu6019528
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 11:12:33 -0500
Subject: Re: [PATCH] 0/2 Buddy allocator with placement policy + prezeroing
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050227134219.B4346ECE4@skynet.csn.ul.ie>
References: <20050227134219.B4346ECE4@skynet.csn.ul.ie>
Content-Type: text/plain
Date: Mon, 28 Feb 2005 08:12:07 -0800
Message-Id: <1109607127.6921.14.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2005-02-27 at 13:42 +0000, Mel Gorman wrote:
> In the two following emails are the latest version of the placement policy
> for the binary buddy allocator to reduce fragmentation and the prezeroing
> patch. The changelogs are with the patches although the most significant change
> to the placement policy is a fix for a bug in the usemap size calculation
> (pointed out by Mike Kravetz). 
> 
> The placement policy is Even Better than previous versions and can allocate
> over 100 2**10 blocks of pages under loads in excess of 30 so I still
> consider it ready for inclusion to the mainline.
...

This patch does some important things for memory hotplug: it explicitly
marks the different types of kernel allocations, and it separates those
different types in the allocator.  When it comes to memory hot-remove
this is certainly something we were going to have to do anyway.  Plus, I
believe there are already at least two prototype patches that do this.  

Anything that makes future memory hotplug work easier is good in my
book. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
