Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4GKEPpv000626
	for <linux-mm@kvack.org>; Mon, 16 May 2005 16:14:25 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4GKEPV8135770
	for <linux-mm@kvack.org>; Mon, 16 May 2005 16:14:25 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4GKEPkj023057
	for <linux-mm@kvack.org>; Mon, 16 May 2005 16:14:25 -0400
Subject: Re: [PATCH] Factor in buddy allocator alignment requirements in
	node memory alignment
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0505161204540.4977@ScMPusgw>
References: <Pine.LNX.4.62.0505161204540.4977@ScMPusgw>
Content-Type: text/plain
Date: Mon, 16 May 2005 13:14:11 -0700
Message-Id: <1116274451.1005.106.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: christoph <christoph@scalex86.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-05-16 at 12:05 -0700, christoph wrote:
> Memory for nodes on i386 is currently aligned on 2 MB boundaries.
> However, the buddy allocator needs pages to be aligned on
> PAGE_SIZE << MAX_ORDER which is 8MB if MAX_ORDER = 11.

Why do you need this?  Are you planning on allowing NUMA KVA remap pages
to be handed over to the buddy allocator?  That would be a major
departure from what we do now, and I'd be very interested in seeing how
that is implemented before a infrastructure for it goes in.

BTW, how sure are you that those alignment restrictions really still
exist?  Some of them went away when we got rid of the buddy bitmap.  You
might want to check that you definitely need this.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
