Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4GKv8mD657436
	for <linux-mm@kvack.org>; Mon, 16 May 2005 16:57:08 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4GKv8Gc235946
	for <linux-mm@kvack.org>; Mon, 16 May 2005 14:57:08 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4GKv7Qf018294
	for <linux-mm@kvack.org>; Mon, 16 May 2005 14:57:07 -0600
Subject: Re: [PATCH] Factor in buddy allocator alignment requirements in
	node memory alignment
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0505161253090.20839@ScMPusgw>
References: <Pine.LNX.4.62.0505161204540.4977@ScMPusgw>
	 <1116274451.1005.106.camel@localhost>
	 <Pine.LNX.4.62.0505161240240.13692@ScMPusgw>
	 <1116276439.1005.110.camel@localhost>
	 <Pine.LNX.4.62.0505161253090.20839@ScMPusgw>
Content-Type: text/plain
Date: Mon, 16 May 2005 13:56:54 -0700
Message-Id: <1116277014.1005.113.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: christoph <christoph@scalex86.org>
Cc: linux-mm <linux-mm@kvack.org>, shai@scalex86.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-05-16 at 12:55 -0700, christoph wrote:
> On Mon, 16 May 2005, Dave Hansen wrote:
> > > Because the buddy allocator is complaining about wrongly allocated zones!
> > 
> > Just because it complains doesn't mean that anything is actually
> > wrong :)
> > 
> > Do you know which pieces of code actually break if the alignment doesn't
> > meet what that warning says?
> 
> I have seen nothing break but 4 MB allocations f.e. will not be allocated 
> on a 4MB boundary with a 2 MB zone alignment. The page allocator always 
> returnes properly aligned pages but 4MB allocations are an exception? 

I wasn't aware there was an alignment exception in the allocator for 4MB
pages.  Could you provide some examples?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
