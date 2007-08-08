Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l78IlrG7025884
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 14:47:53 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l78Ill8F214714
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 12:47:48 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l78IlkSq015184
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 12:47:46 -0600
Subject: [Documentation] Page Table Layout diagrams
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Wed, 08 Aug 2007 13:47:45 -0500
Message-Id: <1186598865.23817.76.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: linuxppc-dev@ozlabs.org, linux-kernel <linux-kernel@vger.kernel.org>, "ADAM G. LITKE [imap]" <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello all.  In an effort to understand how the page tables are laid out
across various architectures I put together some diagrams.  I have
posted them on the linux-mm wiki: http://linux-mm.org/PageTableStructure
and I hope they will be useful to others.  

Just to make sure I am not spreading misinformation, could a few of you
experts take a quick look at the three diagrams I've got finished so far
and point out any errors I have made?  Thanks.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
