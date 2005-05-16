Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4GKlWH0010799
	for <linux-mm@kvack.org>; Mon, 16 May 2005 16:47:33 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4GKlWXn090064
	for <linux-mm@kvack.org>; Mon, 16 May 2005 16:47:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4GKlW4v021287
	for <linux-mm@kvack.org>; Mon, 16 May 2005 16:47:32 -0400
Subject: Re: [PATCH] Factor in buddy allocator alignment requirements in
	node memory alignment
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0505161240240.13692@ScMPusgw>
References: <Pine.LNX.4.62.0505161204540.4977@ScMPusgw>
	 <1116274451.1005.106.camel@localhost>
	 <Pine.LNX.4.62.0505161240240.13692@ScMPusgw>
Content-Type: text/plain
Date: Mon, 16 May 2005 13:47:19 -0700
Message-Id: <1116276439.1005.110.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: christoph <christoph@scalex86.org>
Cc: linux-mm <linux-mm@kvack.org>, shai@scalex86.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-05-16 at 12:43 -0700, christoph wrote:
> On Mon, 16 May 2005, Dave Hansen wrote:
> > On Mon, 2005-05-16 at 12:05 -0700, christoph wrote:
> > > Memory for nodes on i386 is currently aligned on 2 MB boundaries.
> > > However, the buddy allocator needs pages to be aligned on
> > > PAGE_SIZE << MAX_ORDER which is 8MB if MAX_ORDER = 11.
> > 
> > Why do you need this?  Are you planning on allowing NUMA KVA remap pages
> > to be handed over to the buddy allocator?  That would be a major
> > departure from what we do now, and I'd be very interested in seeing how
> > that is implemented before a infrastructure for it goes in.
> 
> Because the buddy allocator is complaining about wrongly allocated zones!

Just because it complains doesn't mean that anything is actually
wrong :)

Do you know which pieces of code actually break if the alignment doesn't
meet what that warning says?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
