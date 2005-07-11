Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j6BHn6fG003850
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 13:49:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6BHn6wY227142
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 13:49:06 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j6BHn6X6013464
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 13:49:06 -0400
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <42D2AE0F.8020809@austin.ibm.com>
References: <1121101013.15095.19.camel@localhost>
	 <42D2AE0F.8020809@austin.ibm.com>
Content-Type: text/plain
Date: Mon, 11 Jul 2005 10:49:02 -0700
Message-Id: <1121104142.15095.30.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: Paul Jackson <pj@sgi.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-07-11 at 12:36 -0500, Joel Schopp wrote:
> Dave Hansen brought this to my attention.  I've attached the bit of the 
> memory fragmentation avoidance you conflict with (I'm working with Mel 
> on his patches).  I think we share similar goals, and I wouldn't mind 
> changing __GFP_USERRCLM to __GFP_USERALLOC or some neutral name we could 
> share.  Anything to increase the chances of fragmentation avoidance 
> getting merged is good in my book.

The nice part about using __GFP_USER as the name is that it describes
how it's going to be used rather than how the kernel is going to treat
it.  Somebody making a random allocator call is much more likely to know
how they're going to use it than how the kernel _should_.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
